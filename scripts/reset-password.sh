#!/bin/bash

# Script to reset a user's password in the local database with BCrypt hash

if [ "$#" -ne 2 ]; then
    echo "Usage: ./reset-password.sh <username> <password>"
    exit 1
fi

USERNAME="$1"
PASSWORD="$2"

echo "Generating BCrypt hash for password..."

# Generate hash using Gradle task
HASH=$(./gradlew -q hashPassword --args="$PASSWORD" 2>&1 | grep '^\$2' | tail -1)

if [ -z "$HASH" ]; then
    echo "Error: Could not generate BCrypt hash"
    echo "Try running manually: ./gradlew hashPassword --args='$PASSWORD'"
    exit 1
fi

echo "Generated hash: $HASH"
echo "Updating database..."

# Update the database
mysql -u root blog_local -e "UPDATE User SET password = '$HASH' WHERE name = '$USERNAME';"

if [ $? -eq 0 ]; then
    echo "✓ Password updated successfully for user: $USERNAME"
    echo "You can now login with username '$USERNAME' and the password you provided"
else
    echo "✗ Failed to update password"
    exit 1
fi
