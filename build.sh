#!/bin/bash
# Build script for the fantasy-sports-db Docker image

set -e

# Default values
IMAGE_NAME="${IMAGE_NAME:-fantasy-sports-db}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
REGISTRY="${REGISTRY:-}"

# Build the image
echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .

# Tag with registry if provided
if [ -n "$REGISTRY" ]; then
    FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    echo "Tagging image as: ${FULL_IMAGE_NAME}"
    docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${FULL_IMAGE_NAME}"
    echo ""
    echo "To push to registry, run:"
    echo "  docker push ${FULL_IMAGE_NAME}"
fi

echo ""
echo "Image built successfully!"
echo "To run the container, use:"
echo "  docker run -d -p 3306:3306 ${IMAGE_NAME}:${IMAGE_TAG}"
