import os
import argparse
import sys
import urllib.request
import zipfile
from pathlib import Path
from .utils import resolve_fuse_path
from .data import load_data

from ultralytics import YOLO



def train_model(config_path: str, data_config: Path, model_name: str):
    """
    Executes the Ultralytics model training within a Vertex AI Custom Training environment.
    """
    # Vertex AI sets AIP_MODEL_DIR to a gs:// URI.
    # We use Vertex's automatic Cloud Storage FUSE to write directly to the bucket.
    aip_model_dir = os.getenv("AIP_MODEL_DIR")
    
    output_dir = resolve_fuse_path(aip_model_dir)

    print(f"Target Output Directory (FUSE): {output_dir}")
    print(f"Initializing Model: {model_name}")
    model = YOLO(model_name)

    # Base arguments required for our Vertex AI environment
    train_args = {
        "data": data_config,
        "project": output_dir, 
        "name": "vertex_train", # Run name will be appended to project path
        "exist_ok": True, # Overwrite existing run directory if it exists
        "cfg": config_path # Let Ultralytics handle the YAML parsing natively!
    }

    print("Starting training with arguments...")
    print(train_args)
    
    results = model.train(**train_args)

    print("Vertex AI Custom Training Job script finished.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train an Ultralytics YOLO model on Vertex AI.")
    
    parser.add_argument(
        "--config-uri",
        type=str,
        required=True,
        help="URI to the training configuration YAML file (e.g., gs://my-bucket/training_config.yaml)."
    )
    parser.add_argument(
        "--model",
        type=str,
        default="yolov8n.pt",
        help="Base model architecture to initialize (e.g., yolov8n.pt, yolov8s.pt)."
    )
    
    args = parser.parse_args()

    # Pass the parsed arguments into the training method
    train_model(
        config_path=resolve_fuse_path(args.config_uri),
        data_config=load_data(),
        model_name=args.model
    )
