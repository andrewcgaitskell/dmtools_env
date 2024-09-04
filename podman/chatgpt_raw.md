# ChatGPT recommendation

Yes, you can run the GitHub Actions runner inside a rootless Podman container, which allows you to run containers without needing root privileges.

Running Podman in rootless mode provides additional security by minimizing the attack surface and is a good fit for setups where you want to avoid giving elevated privileges to the user running the containers.


# Rootless Podman Setup for a GitHub Actions Runner

Here's how to run the GitHub Actions runner in a rootless Podman container:

    Ensure Podman is Installed and Configured for Rootless Use
    Create the Dockerfile and Entrypoint for the Runner Container
    Build and Run the Container as a Rootless User

## Step 1: Install and Configure Rootless Podman

Ensure that Podman is installed and configured for rootless mode on your RHEL server:

    Install Podman if not already installed:

    bash

    sudo dnf install -y podman

Configure Rootless Podman: Make sure you have subuid and subgid mappings set up for your user, which are required for rootless containers.

    bash
    
    echo "$(whoami):100000:65536" | sudo tee -a /etc/subuid /etc/subgid

Re-login to Apply Changes: Log out and back in to apply the changes, or use newgrp to update your current session.

Enable Systemd Support for Rootless Containers: Run the following command to enable Systemd support for rootless containers:

bash

    sudo loginctl enable-linger $(whoami)

## Step 2: Create the Dockerfile and Entrypoint Script

Create a Dockerfile for the GitHub Actions runner container that will run in rootless Podman mode:
Dockerfile

## Dockerfile

    # Dockerfile for GitHub Actions Runner in Rootless Podman
    
    FROM ubuntu:20.04
    
    # Install necessary dependencies
    RUN apt-get update && apt-get install -y \
        curl \
        tar \
        git \
        sudo \
        && rm -rf /var/lib/apt/lists/*
    
    # Create a user for the GitHub runner
    RUN useradd -m runner && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    
    # Switch to the runner user
    USER runner
    WORKDIR /home/runner
    
    # Set environment variables
    ENV RUNNER_NAME="podman-runner"
    ENV RUNNER_WORKDIR="_work"
    
    # Download and install the GitHub Actions Runner
    RUN curl -o actions-runner-linux-x64-2.300.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.300.2/actions-runner-linux-x64-2.300.2.tar.gz && \
        tar xzf actions-runner-linux-x64-2.300.2.tar.gz && \
        rm -f actions-runner-linux-x64-2.300.2.tar.gz
    
    # Copy entrypoint script
    COPY entrypoint.sh .
    
    # Make the entrypoint script executable
    RUN chmod +x entrypoint.sh
    
    # Set the entrypoint to the script
    ENTRYPOINT ["./entrypoint.sh"]
    
    Entrypoint Script (entrypoint.sh)

## entrypoint.sh

    Create a file named entrypoint.sh in the same directory:
    
    bash
    
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

## Step 3: Build and Run the Container in Rootless Mode

Make sure you are logged in as a non-root user (the user configured for rootless Podman) when running the following commands:

    Build the Podman Container:

    bash

podman build -t github-runner:latest .

## Obtain a GitHub Runner Registration Token:

    Navigate to your GitHub repository's Settings > Actions > Runners.
    Click "New self-hosted runner" and select Linux.
    Copy the token provided by GitHub.

## Run the Podman Container Rootlessly:

Use the token and repository URL obtained earlier to run the container:

bash

    podman run -d --name github-runner \
      -e REPO_URL="https://github.com/your-user/your-repo" \
      -e RUNNER_TOKEN="YOUR_TOKEN_HERE" \
      -v ${HOME}/runner/_work:/home/runner/_work \
      github-runner:latest

    Explanation of the podman run Command:
        -d: Run the container in detached mode.
        --name github-runner: Name the container github-runner.
        -e REPO_URL=...: Set the environment variable for the repository URL.
        -e RUNNER_TOKEN=...: Set the environment variable for the GitHub runner token.
        -v ${HOME}/runner/_work:/home/runner/_work: Bind mount a directory for the GitHub Actions runner work directory. Ensure this directory is writable by the runner user inside the container.

## Step 4: Verify the Runner

    Check Runner Status:
        After starting the container, check if it is running properly:

    bash

    podman ps

    View the Runner in GitHub:
        Go to your repository's Settings > Actions > Runners.
        The runner should appear as Online.

    Test the Workflow:
        Push a change to your repository or manually trigger a workflow that uses runs-on: self-hosted to see if the runner picks up the job.

## Additional Notes

    Networking Considerations: If your workflows involve network access, ensure that the rootless Podman container has appropriate network permissions. Rootless Podman containers typically run with slirp4netns networking by default.
    User Permissions: Ensure that the runner user inside the container has the appropriate permissions to execute necessary tasks.

## Summary

    Rootless Podman: You can run the GitHub Actions runner inside a Podman container in rootless mode for enhanced security.
    Configuration: Set up a Dockerfile and entrypoint script, build the container, and run it with the appropriate environment variables and volume mounts.
    Test and Verify: Ensure the runner is registered and working correctly by triggering a workflow in your GitHub repository.

    By following these steps, you can create a secure and isolated environment for your GitHub Actions runner using rootless Podman on your RHEL server.
