#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Variables with default values, which can be overridden by environment variables
IMAGE_NAME="${IMAGE_NAME:-hello-web3-js-image}"
TAG="${TAG:-latest}"
DOCKERFILE_PATH="${DOCKERFILE_PATH:-.}"
REGISTRY="${REGISTRY:-your_registry_url}" # e.g., docker.io or gcr.io

# Flags to control the steps
BUILD=false
TAG=false
PUSH=false

# Function to display usage
usage() {
  echo "Usage: $0 [-i IMAGE_NAME] [-t TAG] [-d DOCKERFILE_PATH] [-r REGISTRY] [-b] [-g] [-p]"
  echo "  -i IMAGE_NAME      Name of the Docker image (default: your_image_name)"
  echo "  -t TAG             Tag for the Docker image (default: latest)"
  echo "  -d DOCKERFILE_PATH Path to the Dockerfile (default: current directory)"
  echo "  -r REGISTRY        Docker registry URL (default: your_registry_url)"
  echo "  -b                 Build the Docker image"
  echo "  -g                 Tag the Docker image"
  echo "  -p                 Push the Docker image"
  exit 1
}

# Function to parse command-line arguments
parse_args() {
  while getopts "i:t:d:r:bgp" opt; do
    case ${opt} in
      i )
        IMAGE_NAME=$OPTARG
        ;;
      t )
        TAG=$OPTARG
        ;;
      d )
        DOCKERFILE_PATH=$OPTARG
        ;;
      r )
        REGISTRY=$OPTARG
        ;;
      b )
        BUILD=true
        ;;
      g )
        TAG=true
        ;;
      p )
        PUSH=true
        ;;
      * )
        usage
        ;;
    esac
  done
}

# Function to build the Docker image
build_image() {
  echo "Building Docker image ${IMAGE_NAME}:${TAG} from ${DOCKERFILE_PATH}"
  docker build -t ${IMAGE_NAME}:${TAG} ${DOCKERFILE_PATH}
}

# Function to tag the Docker image
tag_image() {
  if [ -n "${REGISTRY}" ]; then
    FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${TAG}"
    echo "Tagging Docker image as ${FULL_IMAGE_NAME}"
    docker tag ${IMAGE_NAME}:${TAG} ${FULL_IMAGE_NAME}
  fi
}

# Function to push the Docker image to the registry
push_image() {
  if [ -n "${REGISTRY}" ]; then
    echo "Pushing Docker image to ${REGISTRY}"
    docker push ${FULL_IMAGE_NAME}
  fi
}

# Main function to orchestrate the build, tag, and push process
main() {
  parse_args "$@"

  if [ "$BUILD" = true ]; then
    build_image
  fi

  if [ "$TAG" = true ]; then
    tag_image
  fi

  if [ "$PUSH" = true ]; then
    push_image
  fi

  if [ "$BUILD" = false ] && [ "$TAG" = false ] && [ "$PUSH" = false ]; then
    echo "No action specified. Use -b, -g, or -p to specify an action."
    usage
  fi

  echo "Docker image ${IMAGE_NAME}:${TAG} processed successfully."
}

# Call the main function with all script arguments
main "$@"