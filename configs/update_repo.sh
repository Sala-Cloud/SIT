#!/bin/bash

REPO_URL="https://github.com/Sala-Cloud/SIT.git"
REPO_DIR="$JENKINS_HOME/workspace/IT-INF/"  # Update this to your local repository path

if [ -d "$REPO_DIR" ]; then
    echo "Updating existing repository..."
    cd "$REPO_DIR" || exit
    git pull origin main
else
    echo "Cloning repository..."
    git clone -b main "$REPO_URL" "$REPO_DIR"
fi
