# Vertex AI Custom Container: YOLOv8 Training

This repository contains the code to package and deploy an Ultralytics YOLO object detection model as a custom training container, fully compliant with the Google Cloud Vertex AI Custom Training API.

## Overview

This project provides a robust wrapper around the standard Ultralytics YOLO training loop. It handles automatic dataset orchestration (downloading and extracting the COCO8 dataset) and seamlessly integrates with Google Cloud Storage for reading configurations and writing training artifacts.

## The Vertex AI Contract

To ensure seamless operation within Vertex AI (or any environment emulating it), this code adheres to the standard Vertex AI Custom Job contract:

*   **`AIP_MODEL_DIR`:** Vertex AI automatically injects this environment variable, specifying a Google Cloud Storage (GCS) URI (e.g., `gs://my-bucket/output/`).
*   **Cloud Storage FUSE:** Vertex natively mounts the GCS bucket to the local filesystem using FUSE. Our `utils.py` contains a helper function (`resolve_fuse_path`) that safely translates the `gs://` URI into the corresponding local `/gcs/` path, allowing the model to write directly to the cloud in real-time as if it were a local hard drive.

## Hyperparameters (CLI Arguments)

The `train.py` script acts as the entry point and accepts custom hyperparameters via standard command-line flags using `argparse`. 

When launching a job, you can pass the following arguments:

*   `--config-uri` **(Required)**: The GCS URI pointing to your specific Ultralytics YAML training configuration (e.g., `gs://my-bucket/hyperparams.yaml`).
*   `--model` *(Optional)*: The base YOLO architecture to use (default: `yolov8n.pt`).

## Deployment

To execute this training code in the cloud, you must package it into a Docker image and push it to Google Artifact Registry.

1. **Build the Docker Image:**
   Run the following command from the root of this repository:
   ```bash
   export IMAGE_URI="us-central1-docker.pkg.dev/YOUR_PROJECT_ID/YOUR_REPO/yolo-vertex-trainer:latest"
   docker build -t $IMAGE_URI .
   ```

2. **Push to Artifact Registry:**
   ```bash
   gcloud auth configure-docker us-central1-docker.pkg.dev
   docker push $IMAGE_URI
   ```

## Adapting to Your Own Model Family

This repository is designed to be a reusable boilerplate. If you want to train a HuggingFace Transformer, a scikit-learn random forest, or a custom PyTorch model instead of YOLO, you can easily adapt this wrapper:

1.  **Keep the Plumbing:** Retain the `Dockerfile`, `utils.py`, and the `argparse` setup in `train.py`.
2.  **Swap the Logic:** Replace the `YOLO(model_name)` initialization and `model.train()` calls with your own framework's training loop.  Also, the `load_data` logic if you'd like to train a model on a different dataset. 
3.  **Route the Output:** Ensure your new framework saves its final weights, checkpoints, and logs to the directory returned by `resolve_fuse_path(os.getenv("AIP_MODEL_DIR"))`.


# Contributing

We would love to have your contributions that improve current functionality, fix bugs, or add new features.  See [the contributing guidelines](CONTRIBUTING.md) for more info.

# Disclaimer

This repository is a scientific product and is not official communication of the National Oceanic and
Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project
code is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the
Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub
project will be governed by all applicable Federal law. Any reference to specific commercial products,
processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or
imply their endorsement, recommendation or favoring by the Department of Commerce. The Department
of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to
imply endorsement of any commercial product or activity by DOC or the United States Government.
