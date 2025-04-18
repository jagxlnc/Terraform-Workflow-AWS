#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is required but not installed. Please install Docker first."
    exit 1
fi

# Run Checkov using Docker
echo "Running Checkov scan on Terraform code..."
docker run --rm -v "$(pwd):/tf" bridgecrew/checkov --directory /tf --framework terraform

echo "Scan complete!"