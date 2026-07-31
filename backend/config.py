"""
Centralized configuration for the Flask backend.
"""

import os
import torch

# ═══════════════════════════════════════════════════════════════════════════════
#  Paths
# ═══════════════════════════════════════════════════════════════════════════════

# Base directory is the backend folder itself
BASE_DIR = os.path.abspath(os.path.dirname(__file__))

# Model checkpoint (inside backend/checkpoints_mirnet/)
MIRNET_CHECKPOINT = os.path.join(BASE_DIR, "checkpoints_mirnet", "mirnet_best.pth")

# Directories for uploaded images and pipeline outputs
UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "uploads")
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "outputs")

# Ensure directories exist
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ═══════════════════════════════════════════════════════════════════════════════
#  Device
# ═══════════════════════════════════════════════════════════════════════════════

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# ── GPU Diagnostics ──
print(f"  PyTorch version  : {torch.__version__}")
print(f"  CUDA available   : {torch.cuda.is_available()}")
print(f"  CUDA built with  : {torch.version.cuda if torch.version.cuda else 'N/A (CPU-only build)'}")
if torch.cuda.is_available():
    print(f"  GPU name         : {torch.cuda.get_device_name(0)}")
    print(f"  GPU memory       : {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB")
else:
    print("  [!] Running on CPU. To use GPU, install PyTorch with CUDA:")
    print("     pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121")

# ═══════════════════════════════════════════════════════════════════════════════
#  MIRNet Hyperparameters
# ═══════════════════════════════════════════════════════════════════════════════

MIRNET_IN_CHANNELS = 3
MIRNET_OUT_CHANNELS = 3
MIRNET_N_FEATURES = 64
MIRNET_N_RRG = 3
MIRNET_N_MRB = 2
MIRNET_REDUCTION = 4

# ═══════════════════════════════════════════════════════════════════════════════
#  File Upload
# ═══════════════════════════════════════════════════════════════════════════════

ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "bmp", "tif", "tiff"}
MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16 MB max upload size

# ═══════════════════════════════════════════════════════════════════════════════
#  OpenCV Denoising Parameters
# ═══════════════════════════════════════════════════════════════════════════════

DENOISE_H = 5
DENOISE_H_COLOR = 5
DENOISE_TEMPLATE_WINDOW = 7
DENOISE_SEARCH_WINDOW = 21
