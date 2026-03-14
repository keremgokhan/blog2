#!/bin/bash

# Database Sync Script
# Exports production database and imports it to local development database
#
# Usage:
#   1. Configure the variables below
#   2. Make executable: chmod +x sync-prod-db.sh
#   3. Run: ./sync-prod-db.sh

# ============================================
# CONFIGURATION - Update these values
# ============================================

# Production server details
PROD_HOST="keremgokhan.net"
PROD_USER="kerem"
PROD_DB_USER="root"
PROD_DB_NAME="blog"

# Local database details
LOCAL_DB_USER="root"
LOCAL_DB_NAME="blog_local"

# ============================================
# Script starts here
# ============================================

set -e  # Exit on error

DATE=$(date +%Y%m%d_%H%M%S)
TEMP_FILE="/tmp/blog_export_$DATE.sql"

echo "============================================"
echo "Blog Database Sync"
echo "============================================"
echo "Started at: $(date)"
echo ""

# Step 1: Export from production
echo "📦 Step 1: Exporting from production server..."
echo "   Server: $PROD_HOST"
echo "   Database: $PROD_DB_NAME"
echo ""

ssh "$PROD_USER@$PROD_HOST" "mysqldump -u $PROD_DB_USER -p $PROD_DB_NAME" > "$TEMP_FILE"

if [ ! -f "$TEMP_FILE" ]; then
    echo "❌ Error: Export file not created!"
    exit 1
fi

FILE_SIZE=$(ls -lh "$TEMP_FILE" | awk '{print $5}')
echo "✅ Export complete! File size: $FILE_SIZE"
echo ""

# Step 2: Check if local database exists
echo "🔍 Step 2: Checking local database..."
if mysql -u "$LOCAL_DB_USER" -p -e "USE $LOCAL_DB_NAME" 2>/dev/null; then
    echo "⚠️  Database '$LOCAL_DB_NAME' exists. It will be dropped and recreated."
    read -p "   Continue? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        rm "$TEMP_FILE"
        exit 1
    fi
    mysql -u "$LOCAL_DB_USER" -p -e "DROP DATABASE $LOCAL_DB_NAME;"
fi

# Step 3: Create database and import
echo ""
echo "💾 Step 3: Creating local database and importing..."
mysql -u "$LOCAL_DB_USER" -p -e "CREATE DATABASE $LOCAL_DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "   Importing data (this may take a while)..."
mysql -u "$LOCAL_DB_USER" -p "$LOCAL_DB_NAME" < "$TEMP_FILE"

echo "✅ Import complete!"
echo ""

# Step 4: Verify import
echo "🔍 Step 4: Verifying import..."
TABLES=$(mysql -u "$LOCAL_DB_USER" -p "$LOCAL_DB_NAME" -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$LOCAL_DB_NAME';")
USERS=$(mysql -u "$LOCAL_DB_USER" -p "$LOCAL_DB_NAME" -sN -e "SELECT COUNT(*) FROM User;" 2>/dev/null || echo "0")
POSTS=$(mysql -u "$LOCAL_DB_USER" -p "$LOCAL_DB_NAME" -sN -e "SELECT COUNT(*) FROM Post;" 2>/dev/null || echo "0")

echo "   Tables: $TABLES"
echo "   Users: $USERS"
echo "   Posts: $POSTS"
echo ""

# Step 5: Cleanup
echo "🧹 Step 5: Cleaning up..."
rm "$TEMP_FILE"
echo "✅ Temporary file removed"
echo ""

# Step 6: Show configuration
echo "============================================"
echo "✨ Sync Complete!"
echo "============================================"
echo ""
echo "Configure your application with:"
echo ""
echo "  export DB_NAME=$LOCAL_DB_NAME"
echo "  export DB_USER=$LOCAL_DB_USER"
echo "  export DB_HOST=localhost"
echo "  export ENV=development"
echo ""
echo "Then run:"
echo "  ./gradlew run"
echo ""
echo "⚠️  Note: If authentication fails, you may need to create"
echo "   a test user with BCrypt password. See DB_EXPORT_IMPORT.md"
echo ""
echo "Completed at: $(date)"
