# Night Image Enhancement using Deep Learning (MIRNet)

This repository contains the code and resources for a Deep Learning project focused on enhancing low-light and night images. The core model architecture used is **MIRNet**, specifically trained and tested on the **LOL-v2** dataset.

## 🚀 Project Overview

The project is structured into two main parts:
1. **Model Development & Training:** A set of Jupyter Notebooks for training the MIRNet model, evaluating its performance, and testing the inference pipeline.
2. **Web Backend:** A Flask-based backend API built to serve the trained deep learning model, allowing for easy integration with a frontend or for processing images via HTTP requests.

## 📁 Repository Structure

```text
├── MIRNet_Inference.ipynb          # Notebook for running inference on custom images using trained models
├── MIRNet_LOLv2 Version 2.ipynb    # Main notebook for MIRNet training and validation on the LOL-v2 dataset
├── Pipeline_MIRNet_CV.ipynb        # Computer Vision pipeline processing and evaluation notebook
├── backend/                        # Flask application serving the enhancement model
│   ├── app.py                      # Main entry point for the Flask backend
│   ├── pipeline.py                 # Inference pipeline scripts
│   ├── requirements.txt            # Python dependencies for the backend
│   ├── models/                     # Directory storing PyTorch model checkpoints (*.pth, etc.)
│   └── templates/                  # HTML templates (if any frontend is served via Flask)
├── LOL-v2/                         # (Ignored) The Low-Light dataset directory
└── checkpoints_mirnet/             # (Ignored) Saved model weights and training checkpoints
```

## 🛠️ Setup & Installation

### Backend (Flask App)

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Create a virtual environment (optional but recommended):**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application:**
   ```bash
   python app.py
   ```
   The Flask server should now be running (typically at `http://127.0.0.1:5000/`).

### Jupyter Notebooks

To run the training or inference notebooks, ensure you have Jupyter installed along with the necessary deep learning libraries (PyTorch, Torchvision, OpenCV, etc.). 

```bash
pip install jupyterlab torch torchvision opencv-python matplotlib
jupyter lab
```

## 🧠 Model Details

- **Architecture:** MIRNet (Learning Enriched Features for Real Image Restoration and Enhancement)
- **Framework:** PyTorch
- **Dataset:** LOL-v2 (Low-Light dataset)

## 📄 License
*Specify your license here (e.g., MIT, Apache 2.0)*
