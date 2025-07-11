#!/bin/bash

# Use the argument passed in $1 to overwrite the default LOCAL_REGISTRY
LOCAL_REGISTRY=${1:-localhost:5000}

echo "Using local registry: $LOCAL_REGISTRY"

echo "Building all images..."

echo "Building base image..."
bash ./scripts/build-service.sh --repo-prefix kaiju --container-name service-base-kaiju --docker-file ./Dockerfiles/Dockerfile.base --registry $LOCAL_REGISTRY
echo "Built and pushed base image..."

# Function to build, tag, and push a service image
build_service() {
    local service_name=$1
    echo "Building $service_name image..."
    bash ./scripts/build-service.sh --repo-prefix kaiju --container-name $service_name --docker-file ./Dockerfiles/Dockerfile.service --registry $LOCAL_REGISTRY
    echo "Built and pushed $service_name image..."
}

echo "Building service images..."

# List of services to build
services=(
    "service-get-bounding-box"
    "service-get-satellite-imagery"
    "service-convert-images"
    "service-resize-images"
    "service-inject-kaiju"
    "service-chip-images"
)

# Build all services
for service in "${services[@]}"; do
    build_service $service
done

echo "Built and pushed all service images successfully!"