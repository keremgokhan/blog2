#!/bin/bash
set -e

SERVER="keremgokhan@95.85.21.104"
REMOTE_PATH="/opt/blog/blog-kotlin-1.0.0-all.jar"
SSH_OPTS="-o ConnectTimeout=10 -o ServerAliveInterval=5 -o ServerAliveCountMax=3"

echo "Building..."
./gradlew shadowJar

echo "Deploying..."
scp $SSH_OPTS build/libs/blog-kotlin-1.0.0-all.jar "$SERVER:$REMOTE_PATH"

echo "Restarting service..."
ssh $SSH_OPTS "$SERVER" "systemctl restart blog && sleep 2 && systemctl status blog --no-pager -l | tail -8"

echo "Done."
