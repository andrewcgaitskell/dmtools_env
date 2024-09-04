#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# GitHub repository and token from environment variables
REPO_URL=${ENV_REPO_URL}
RUNNER_TOKEN=${ENV_RUNNER_TOKEN}

# Configure the GitHub Actions Runner
./config.sh --url "${ENV_REPO_URL}" --token "${ENV_RUNNER_TOKEN}" --work "${ENV_RUNNER_WORKDIR}" --unattended --replace

# Run the GitHub Actions Runner
./run.sh

