#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Initialize empty variables
PROJECT_ID=""
REGION=""
IMAGE_URI=""
CONFIG_URI=""
MODEL_ARCH=""

# Hardcoded hardware configuration for YOLOv8
MACHINE_TYPE="n1-standard-4"
ACCELERATOR_TYPE="NVIDIA_TESLA_T4"
ACCELERATOR_COUNT="1"

# Function to display help menu
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Submits a Custom Training Job to Vertex AI."
  echo ""
  echo "Options (All are REQUIRED):"
  echo "  -p, --project      Google Cloud Project ID"
  echo "  -r, --region       GCP Region (e.g., us-central1)"
  echo "  -i, --image-uri    Full Artifact Registry URI of the training container"
  echo "  -c, --config-uri   GCS URI to the hyperparams.yaml file"
  echo "  -m, --model-arch   Base model architecture (e.g., yolov8n.pt)"
  echo "  -h, --help         Display this help message and exit"
  echo ""
  echo "Note: The output directory is now configured in vertex_config.yaml"
  echo ""
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--project)
      PROJECT_ID="$2"
      shift 2
      ;;
    -r|--region)
      REGION="$2"
      shift 2
      ;;
    -i|--image-uri)
      IMAGE_URI="$2"
      shift 2
      ;;
    -c|--config-uri)
      CONFIG_URI="$2"
      shift 2
      ;;
    -m|--model-arch)
      MODEL_ARCH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# Ensure all required variables are set
MISSING_ARGS=0

if [[ -z "$PROJECT_ID" ]]; then echo "Error: --project is required."; MISSING_ARGS=1; fi
if [[ -z "$REGION" ]]; then echo "Error: --region is required."; MISSING_ARGS=1; fi
if [[ -z "$IMAGE_URI" ]]; then echo "Error: --image-uri is required."; MISSING_ARGS=1; fi
if [[ -z "$CONFIG_URI" ]]; then echo "Error: --config-uri is required."; MISSING_ARGS=1; fi
if [[ -z "$MODEL_ARCH" ]]; then echo "Error: --model-arch is required."; MISSING_ARGS=1; fi

if [[ $MISSING_ARGS -eq 1 ]]; then
  echo ""
  usage
  exit 1
fi

# Ensure the config file exists
if [[ ! -f "vertex_config.yaml" ]]; then
  echo "Error: vertex_config.yaml not found in the current directory."
  exit 1
fi

JOB_NAME="yolo-train-$(date +%Y%m%d-%H%M%S)"

echo ""
echo "Submitting Custom Training Job: ${JOB_NAME}..."
echo "Project:      ${PROJECT_ID}"
echo "Region:       ${REGION}"
echo "Config URI:   ${CONFIG_URI}"
echo "Model:        ${MODEL_ARCH}"
echo "Image:        ${IMAGE_URI}"
echo "Hardware:     ${MACHINE_TYPE} w/ ${ACCELERATOR_COUNT}x ${ACCELERATOR_TYPE}"
echo "--------------------------------------------------------"

# Submit the job to Vertex AI
gcloud ai custom-jobs create \
  --project="${PROJECT_ID}" \
  --region="${REGION}" \
  --display-name="${JOB_NAME}" \
  --config="vertex_config.yaml" \
  --worker-pool-spec="machine-type=${MACHINE_TYPE},replica-count=1,accelerator-type=${ACCELERATOR_TYPE},accelerator-count=${ACCELERATOR_COUNT},container-image-uri=${IMAGE_URI}" \
  --args="--config-uri=${CONFIG_URI}","--model=${MODEL_ARCH}"

echo ""
echo "Job submitted successfully! Monitor logs in the GCP Console under Vertex AI -> Training."
echo ""

