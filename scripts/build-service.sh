#!/bin/bash

# Default values
REPO_PREFIX=""
CONTAINER_NAME=""
CONTAINER_TAG="latest"
REGISTRY=""
DOCKER_FILE="./Dockerfiles/Dockerfile.service"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --repo-prefix)
            REPO_PREFIX="$2"
            shift 2
            ;;
        --container-name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --container-tag)
            CONTAINER_TAG="$2"
            shift 2
            ;;
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        --docker-file)
            DOCKER_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 --repo-prefix <prefix> --container-name <name> [--container-tag <tag>] [--registry <registry>] [--docker-file <dockerfile>]"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$REPO_PREFIX" ]]; then
    echo "Error: --repo-prefix is required"
    exit 1
fi

if [[ -z "$CONTAINER_NAME" ]]; then
    echo "Error: --container-name is required"
    exit 1
fi

echo "Building with parameters:"
echo "  Repo prefix: $REPO_PREFIX"
echo "  Container name: $CONTAINER_NAME"
echo "  Container tag: $CONTAINER_TAG"
echo "  Docker file: $DOCKER_FILE"
if [[ -n "$REGISTRY" ]]; then
    echo "  Registry: $REGISTRY"
fi

# Build the specified service
echo "Building $CONTAINER_NAME image..."
docker build --build-arg SERVICE_NAME=$CONTAINER_NAME -t $REPO_PREFIX/$CONTAINER_NAME:$CONTAINER_TAG -f $DOCKER_FILE .

# Tag and push if registry is specified
if [[ -n "$REGISTRY" ]]; then
    docker tag $REPO_PREFIX/$CONTAINER_NAME:$CONTAINER_TAG $REGISTRY/$REPO_PREFIX/$CONTAINER_NAME:$CONTAINER_TAG
    docker push $REGISTRY/$REPO_PREFIX/$CONTAINER_NAME:$CONTAINER_TAG
    echo "Built and pushed $CONTAINER_NAME image to $REGISTRY"
else
    echo "Built $CONTAINER_NAME image locally"
fi