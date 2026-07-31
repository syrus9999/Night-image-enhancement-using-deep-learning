"""
Flask Backend — Low-Light Image Enhancement API.

Endpoints:
    GET  /api/health           →  Server & model health check
    POST /api/enhance          →  Upload image → run pipeline → return original + enhanced as base64
"""

import os
import uuid
import time
from datetime import datetime

from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from werkzeug.utils import secure_filename

import config
from utils import allowed_file, load_mirnet_model, image_to_base64
from pipeline import full_pipeline


# ═══════════════════════════════════════════════════════════════════════════════
#  App Initialization
# ═══════════════════════════════════════════════════════════════════════════════

app = Flask(__name__)
CORS(app)  # Allow cross-origin requests from any frontend

app.config["MAX_CONTENT_LENGTH"] = config.MAX_CONTENT_LENGTH

# ── Load the MIRNet model once at startup ──
print("=" * 60)
print("  Loading MIRNet model...")
print(f"  Device: {config.DEVICE}")
mirnet_model = load_mirnet_model()
print("=" * 60)


# ═══════════════════════════════════════════════════════════════════════════════
#  Routes
# ═══════════════════════════════════════════════════════════════════════════════

@app.route("/")
def index():
    """Serve the test UI page."""
    return render_template("test.html")


# ═══════════════════════════════════════════════════════════════════════════════
#  API Routes
# ═══════════════════════════════════════════════════════════════════════════════

@app.route("/api/health", methods=["GET"])
def health():
    """Health check — returns server status, device, and model info."""
    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] <- REQUEST  : GET /api/health")
    response = jsonify({
        "status": "ok",
        "device": str(config.DEVICE),
        "model": "MIRNet",
        "checkpoint": os.path.basename(config.MIRNET_CHECKPOINT),
        "checkpoint_exists": os.path.exists(config.MIRNET_CHECKPOINT),
        "parameters": sum(p.numel() for p in mirnet_model.parameters()),
    })
    print(f"[{datetime.now().strftime('%H:%M:%S')}] -> RESPONSE : GET /api/health - 200 OK")
    return response


@app.route("/api/enhance", methods=["POST"])
def enhance():
    """
    Upload an image and run the full enhancement pipeline.

    Expects:
        multipart/form-data with field name "image".

    Returns:
        JSON with:
            - original_image:   base64-encoded original image (data URI)
            - enhanced_image:   base64-encoded enhanced image (data URI)
            - original_filename: name of the uploaded file
            - input_size:       { width, height }
            - output_size:      { width, height }
            - mirnet_time_ms:   MIRNet stage timing
            - denoise_time_ms:  Denoising stage timing
            - total_time_ms:    Total pipeline timing
    """
    # ── Log incoming request ──
    req_time = time.time()
    print(f"\n{'=' * 60}")
    print(f"[{datetime.now().strftime('%H:%M:%S')}] <- REQUEST  : POST /api/enhance")
    print(f"  File: {request.files.get('image', 'N/A')}")

    # ── Validate request ──
    if "image" not in request.files:
        print(f"[{datetime.now().strftime('%H:%M:%S')}] -> RESPONSE : 400 - No 'image' field")
        return jsonify({"error": "No 'image' field in the request. Send a file with field name 'image'."}), 400

    file = request.files["image"]

    if file.filename == "":
        print(f"[{datetime.now().strftime('%H:%M:%S')}] -> RESPONSE : 400 - No file selected")
        return jsonify({"error": "No file selected."}), 400

    if not allowed_file(file.filename):
        print(f"[{datetime.now().strftime('%H:%M:%S')}] -> RESPONSE : 400 - File type not allowed")
        return jsonify({
            "error": f"File type not allowed. Accepted: {', '.join(config.ALLOWED_EXTENSIONS)}"
        }), 400

    # ── Save uploaded file ──
    original_filename = secure_filename(file.filename)
    name, ext = os.path.splitext(original_filename)
    # Add a unique id to avoid filename collisions
    unique_name = f"{name}_{uuid.uuid4().hex[:8]}{ext}"
    upload_path = os.path.join(config.UPLOAD_DIR, unique_name)
    file.save(upload_path)

    print(f"\n{'-' * 60}")
    print(f"  Processing: {original_filename}")
    print(f"{'-' * 60}")

    # ── Run the pipeline ──
    try:
        result = full_pipeline(
            image_path=upload_path,
            mirnet_model=mirnet_model,
            device=config.DEVICE,
            save_dir=config.OUTPUT_DIR,
        )
    except Exception as e:
        print(f"[{datetime.now().strftime('%H:%M:%S')}] -> RESPONSE : 500 - Pipeline failed: {e}")
        return jsonify({"error": f"Pipeline failed: {str(e)}"}), 500

    # ── Build response with base64-encoded images ──
    original_base64 = image_to_base64(result["original_path"])
    enhanced_base64 = image_to_base64(result["output_path"])

    total_ms = (time.time() - req_time) * 1000
    print(f"[{datetime.now().strftime('%H:%M:%S')}] -> RESPONSE : 200 OK - {original_filename}")
    print(f"  MIRNet: {result['mirnet_time_ms']:.0f}ms | Denoise: {result['denoise_time_ms']:.0f}ms | Total: {total_ms:.0f}ms")
    print(f"{'=' * 60}")

    return jsonify({
        "original_image": original_base64,
        "enhanced_image": enhanced_base64,
        "original_filename": original_filename,
        "input_size": {
            "width": result["input_size"][0],
            "height": result["input_size"][1],
        },
        "output_size": {
            "width": result["output_size"][0],
            "height": result["output_size"][1],
        },
        "mirnet_time_ms": result["mirnet_time_ms"],
        "denoise_time_ms": result["denoise_time_ms"],
        "total_time_ms": result["total_time_ms"],
    })


# ═══════════════════════════════════════════════════════════════════════════════
#  Entry Point
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
