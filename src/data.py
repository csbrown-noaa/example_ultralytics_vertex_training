from pathlib import Path
import urllib.request
import zipfile

def load_data():
    """
    Downloads and orchestrates the dataset before training.
    
    This method abstracts the data fetching mechanism (e.g., downloading from an external 
    source, extracting zips) away from the training loop. It ensures the data is present 
    on the local file system and returns the path to the dataset configuration YAML.
    """
    print("Executing data orchestration...")
    
    dataset_dir = Path("./datasets")
    zip_path = dataset_dir / "coco8.zip"

    print("Downloading example coco8 dataset...")
    dataset_dir.mkdir(parents=True, exist_ok=True)
    
    # Download the example dataset
    url = "https://ultralytics.com/assets/coco8.zip"
    urllib.request.urlretrieve(url, zip_path)
    
    # Extract it
    print("Extracting dataset...")
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(dataset_dir)
        
    print(f"Dataset extracted to {dataset_dir / 'coco8'}")

    return Path("./datasets/coco8.yaml")
