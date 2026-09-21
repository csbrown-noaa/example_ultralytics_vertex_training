#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Initialize empty variables
PROJECT_ID=""
REGION=""
REPO_NAME=""
IMAGE_NAME=""
IMAGE_TAG=""

# Function to display help menu
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Builds and pushes a Docker container to Google Cloud Artifact Registry."
  echo ""
  echo "Options (All are REQUIRED):"
  echo "  -p, --project   Google Cloud Project ID"
  echo "  -r, --region    GCP Region (e.g., us-central1)"
  echo "  -R, --repo      Artifact Registry Repository Name"
  echo "  -i, --image     Docker Image Name"
  echo "  -t, --tag       Docker Image Tag (e.g., latest, v1.0)"
  echo "  -h, --help      Display this help message and exit"
  echo ""
  echo "Example:"
  echo "  $0 --project my-gcp-project --region us-east1 --repo ml-containers --image yolov8-trainer --tag v1.0.0"
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
    -R|--repo)
      REPO_NAME="$2"
      shift 2
      ;;
    -i|--image)
      IMAGE_NAME="$2"
      shift 2
      ;;
    -t|--tag)
      IMAGE_TAG="$2"
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

if [[ -z "$PROJECT_ID" ]]; then
  echo "Error: --project is required."
  MISSING_ARGS=1
fi
if [[ -z "$REGION" ]]; then
  echo "Error: --region is required."
  MISSING_ARGS=1
fi
if [[ -z "$REPO_NAME" ]]; then
  echo "Error: --repo is required."
  MISSING_ARGS=1
fi
if [[ -z "$IMAGE_NAME" ]]; then
  echo "Error: --image is required."
  MISSING_ARGS=1
fi
if [[ -z "$IMAGE_TAG" ]]; then
  echo "Error: --tag is required."
  MISSING_ARGS=1
fi

if [[ $MISSING_ARGS -eq 1 ]]; then
  echo ""
  usage
  exit 1
fi

# Construct the full Artifact Registry URI
IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"

echo ""
echo "1. Authenticating Docker to Artifact Registry..."
echo ""

# This configures your local Docker daemon to use gcloud for authentication
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

echo ""
echo "2. Building the Docker image..."
echo ""

# Build the image using the Dockerfile in the current directory
docker build -t ${IMAGE_URI} .

echo ""
echo "3. Pushing the image to Artifact Registry..."
echo ""
docker push ${IMAGE_URI}

echo ""
echo "======================================================="
echo "Container successfully built and pushed to:"
echo "${IMAGE_URI}"
echo "======================================================="
echo ""
