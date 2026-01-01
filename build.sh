#!/bin/bash

# Build and push script for Jenkins Docker Agent
# Usage: ./build.sh [tag] [dockerhub-username]

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
echo "Building Jenkins Docker Agent"
echo "=================================="
echo "Image: ${FULL_IMAGE_NAME}"
echo "=================================="

# Build the Docker image
echo "Building Docker image..."
docker build -t "${FULL_IMAGE_NAME}" .

# Tag as latest if not already
if [ "$TAG" != "latest" ]; then
    echo "Tagging as latest..."
    docker tag "${FULL_IMAGE_NAME}" "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
fi

echo ""
echo "=================================="
echo "Build completed successfully!"
echo "=================================="
echo ""
echo "To push to Docker Hub, run:"
echo "  docker push ${FULL_IMAGE_NAME}"
if [ "$TAG" != "latest" ]; then
    echo "  docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
fi
echo ""
echo "Or use the push script:"
echo "  ./push.sh ${TAG} ${DOCKERHUB_USERNAME}"
echo ""
