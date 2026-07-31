"""
Utility helpers for the Flask backend.
"""

import os
import base64
import torch

from models.mirnet import MIRNet
import config


def allowed_file(filename):
    """Check if a filename has an allowed image extension."""
    return (
        "." in filename
        and filename.rsplit(".", 1)[1].lower() in config.ALLOWED_EXTENSIONS
    )


def load_mirnet_model():
    """
    Instantiate MIRNet and load the checkpoint weights.

    Returns:
        model (MIRNet): The loaded model in eval mode on the configured device.
    """
    model = MIRNet(
        in_channels=config.MIRNET_IN_CHANNELS,
        out_channels=config.MIRNET_OUT_CHANNELS,
        n_features=config.MIRNET_N_FEATURES,
        n_rrg=config.MIRNET_N_RRG,
        n_mrb=config.MIRNET_N_MRB,
        reduction=config.MIRNET_REDUCTION,
    ).to(config.DEVICE)

    checkpoint_path = config.MIRNET_CHECKPOINT
    if os.path.exists(checkpoint_path):
        ckpt = torch.load(checkpoint_path, map_location=config.DEVICE, weights_only=False)
        model.load_state_dict(ckpt["model_state_dict"])
        epoch = ckpt.get("epoch", "?")
        psnr = ckpt.get("best_psnr", "?")
        psnr_str = f"{psnr:.2f} dB" if isinstance(psnr, (int, float)) else str(psnr)
        print(f"  [OK] MIRNet loaded (epoch {epoch}, PSNR: {psnr_str})")
    else:
        print(f"  [WARNING] MIRNet checkpoint not found at {checkpoint_path}")

    model.eval()
    param_count = sum(p.numel() for p in model.parameters())
    print(f"  Parameters: {param_count:,}")
    return model


def image_to_base64(image_path):
    """Read an image file and return its base64-encoded string with data URI prefix."""
    ext = os.path.splitext(image_path)[1].lower()
    mime_map = {
        ".png": "image/png",
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".bmp": "image/bmp",
        ".tif": "image/tiff",
        ".tiff": "image/tiff",
    }
    mime = mime_map.get(ext, "image/png")

    with open(image_path, "rb") as f:
        encoded = base64.b64encode(f.read()).decode("utf-8")
    return f"data:{mime};base64,{encoded}"
