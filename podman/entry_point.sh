#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# GitHub repository and token from environment variables
REPO_URL=${REPO_URL}
RUNNER_TOKEN=${RUNNER_TOKEN}

# Configure the GitHub Actions Runner
./config.sh --url "${REPO_URL}" --token "${RUNNER_TOKEN}" --work "${RUNNER_WORKDIR}" --unattended --replace

# Run the GitHub Actions Runner
./run.sh

