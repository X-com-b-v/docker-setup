#!/bin/bash
set -e

# Create and use a new builder instance with multi-architecture support
docker buildx create --name multiarch-builder --use

# Enable qemu for multi-architecture support
docker run --privileged --rm tonistiigi/binfmt --install all

# Build and push the multi-architecture images
docker buildx bake -f docker-bake.hcl --push

# Clean up the builder
docker buildx rm multiarch-builder
