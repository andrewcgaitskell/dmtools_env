#!/bin/bash
    
# Configuration
REPO="BrownParticleAstro/dmtools"  # Replace with your repository
SECRET_API_URL="https://api.github.com/repos/$REPO/actions/secrets"
SECRET_NAMES=("DMTOOLS_TEST_SECRET" "ANOTHER_SECRET")  # Add other secret names here
ENV_FILE="/opt/dmtools/code/.env_test"

# Ensure the GitHub token is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    exit 1
fi

# Create or clear the .env file
> $ENV_FILE

# Fetch and write secrets to the .env file
for SECRET in "${SECRET_NAMES[@]}"; do
    # Fetch secret value from GitHub API
    SECRET_VALUE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$SECRET_API_URL/$SECRET" | jq -r .value)

    # Check if the secret was fetched successfully
    if [ "$SECRET_VALUE" == "null" ]; then
        echo "Warning: Secret '$SECRET' not found or could not be fetched."
    else
        echo "$SECRET=$SECRET_VALUE" >> $ENV_FILE
    fi
done

echo ".env file populated successfully."
