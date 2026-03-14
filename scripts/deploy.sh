#!/bin/bash
set -e

SERVER="keremgokhan@95.85.21.104"
REMOTE_PATH="/opt/blog/blog-kotlin-1.0.0-all.jar"

echo "Building..."
./gradlew shadowJar

echo "Deploying..."
scp build/libs/blog-kotlin-1.0.0-all.jar "$SERVER:$REMOTE_PATH"

echo "Restarting service..."
ssh -t "$SERVER" "sudo systemctl restart blog && sudo systemctl status blog --no-pager -l"

echo "Done."
