#!/bin/bash

REPO_URL="https://github.com/Sala-Cloud/SIT.git"
REPO_DIR="$JENKINS_HOME/workspace/IT-INF/"  # Update this to your local repository path

# Ensure the REPO_DIR exists in the Jenkins workspace
mkdir -p "$REPO_DIR"

if [ -d "$REPO_DIR/.git" ]; then
    echo "Updating existing repository..."
    cd "$REPO_DIR" || { echo "Failed to navigate to the repository directory."; exit 1; }
    
    # Fetch the latest changes
    git fetch --all
    
    # Check if there are changes to pull
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "Pulling changes from remote..."
        git pull origin main || { echo "Failed to pull changes."; exit 1; }
    else
        echo "No changes to pull."
    fi
else
    echo "Cloning repository..."
    git clone -b main "$REPO_URL" "$REPO_DIR" || { echo "Failed to clone repository."; exit 1; }
fi
