#!/bin/bash

# Push script for Jenkins Docker Agent
# Usage: ./push.sh [tag] [dockerhub-username]

set -e

# Default values
DEFAULT_TAG="latest"
DEFAULT_USERNAME="your-dockerhub-username"

# Get parameters
TAG="${1:-$DEFAULT_TAG}"
DOCKERHUB_USERNAME="${2:-$DEFAULT_USERNAME}"

IMAGE_NAME="jenkins-docker-agent"
FULL_IMAGE_NAME="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"

echo "=================================="
echo "Pushing Jenkins Docker Agent"
echo "=================================="
echo "Image: ${FULL_IMAGE_NAME}"
echo "=================================="

# Check if user is logged in to Docker Hub
if ! docker info | grep -q "Username"; then
    echo "Please login to Docker Hub first:"
    echo "  docker login"
    exit 1
fi

# Push the image
echo "Pushing Docker image..."
docker push "${FULL_IMAGE_NAME}"

# Push latest tag if not already
if [ "$TAG" != "latest" ]; then
    echo "Pushing latest tag..."
    docker push "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
fi

echo ""
echo "=================================="
echo "Push completed successfully!"
echo "=================================="
echo "Image available at: https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
echo ""
