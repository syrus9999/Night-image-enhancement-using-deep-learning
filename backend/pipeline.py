"""
Image Enhancement Pipeline — MIRNet + OpenCV Denoising.

Pipeline flow:
    Input image → MIRNet (low-light enhancement) → OpenCV FastNlMeansDenoisingColored → Output
"""

import os
import time

import cv2
import numpy as np
import torch
import torch.nn.functional as F
import torchvision.transforms.functional as TF
from PIL import Image

import config


def mirnet_enhance(img_tensor, model, device):
    """
    Run MIRNet low-light enhancement on a single image tensor.

    Args:
        img_tensor: [3, H, W] float tensor in [0, 1].
        model:      Loaded MIRNet model.
        device:     torch.device.

    Returns:
        Enhanced [3, H, W] float tensor in [0, 1] on CPU.
    """
    model.eval()
    with torch.no_grad():
        _, H, W = img_tensor.shape

        # Pad to multiples of 8 (required by architecture)
        pad_h = (8 - H % 8) % 8
        pad_w = (8 - W % 8) % 8
        x = img_tensor.unsqueeze(0).to(device)
        if pad_h > 0 or pad_w > 0:
            x = F.pad(x, (0, pad_w, 0, pad_h), mode="reflect")

        out = model(x)

        # Remove padding
        if pad_h > 0 or pad_w > 0:
            out = out[:, :, :H, :W]

        return out.squeeze(0).clamp(0, 1).cpu()


def cv_denoise(mirnet_output_tensor):
    """
    Apply OpenCV FastNlMeansDenoisingColored to the MIRNet output.

    Args:
        mirnet_output_tensor: [3, H, W] float tensor in [0, 1].

    Returns:
        Denoised RGB numpy array, dtype uint8, shape [H, W, 3].
    """
    # Convert tensor → numpy uint8 [H, W, 3]
    img_np = mirnet_output_tensor.permute(1, 2, 0).numpy()
    img_np = (img_np * 255).clip(0, 255).astype(np.uint8)

    # OpenCV expects BGR
    img_bgr = cv2.cvtColor(img_np, cv2.COLOR_RGB2BGR)

    # Denoise
    denoised = cv2.fastNlMeansDenoisingColored(
        img_bgr,
        None,
        h=config.DENOISE_H,
        hColor=config.DENOISE_H_COLOR,
        templateWindowSize=config.DENOISE_TEMPLATE_WINDOW,
        searchWindowSize=config.DENOISE_SEARCH_WINDOW,
    )

    # Convert back to RGB
    return cv2.cvtColor(denoised, cv2.COLOR_BGR2RGB)


def full_pipeline(image_path, mirnet_model, device, save_dir=None):
    """
    Full two-stage enhancement pipeline.

    Stage 1: MIRNet — low-light enhancement
    Stage 2: OpenCV — FastNlMeansDenoisingColored

    Args:
        image_path:   Path to input image.
        mirnet_model: Loaded MIRNet model.
        device:       torch.device.
        save_dir:     Directory to save outputs (optional).

    Returns:
        dict with keys:
            - original_path:  path to saved copy of original image
            - output_path:    path to final enhanced image
            - input_size:     (width, height) of input
            - output_size:    (width, height) of output
            - mirnet_time_ms: MIRNet inference time in ms
            - denoise_time_ms: Denoising time in ms
            - total_time_ms:  Total pipeline time in ms
    """
    img = Image.open(image_path).convert("RGB")
    img_tensor = TF.to_tensor(img)
    img_name = os.path.basename(image_path)
    name, ext = os.path.splitext(img_name)

    input_w, input_h = img.size
    print(f"  Input: {img_name} ({input_w}x{input_h})")

    # ── Stage 1: MIRNet Enhancement ──
    t1 = time.time()
    mirnet_out = mirnet_enhance(img_tensor, mirnet_model, device)
    t_mirnet = (time.time() - t1) * 1000
    _, mH, mW = mirnet_out.shape
    print(f"  Stage 1 (MIRNet Enhance): {t_mirnet:.0f}ms -> {mW}x{mH}")

    # ── Stage 2: OpenCV Denoising ──
    t2 = time.time()
    final_out = cv_denoise(mirnet_out)
    t_denoise = (time.time() - t2) * 1000
    fH, fW, _ = final_out.shape
    print(f"  Stage 2 (CV Denoise):     {t_denoise:.0f}ms -> {fW}x{fH}")

    total_ms = t_mirnet + t_denoise

    # ── Save outputs ──
    original_save_path = None
    output_save_path = None

    if save_dir:
        os.makedirs(save_dir, exist_ok=True)

        # Save copy of original
        original_save_path = os.path.join(save_dir, f"{name}_original{ext}")
        img.save(original_save_path)

        # Save final enhanced output
        output_save_path = os.path.join(save_dir, f"{name}_enhanced{ext}")
        Image.fromarray(final_out).save(output_save_path)

        print(f"  Saved to {save_dir}/")

    return {
        "original_path": original_save_path,
        "output_path": output_save_path,
        "input_size": (input_w, input_h),
        "output_size": (fW, fH),
        "mirnet_time_ms": round(t_mirnet, 1),
        "denoise_time_ms": round(t_denoise, 1),
        "total_time_ms": round(total_ms, 1),
    }
