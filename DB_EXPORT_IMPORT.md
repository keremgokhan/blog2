# Database Export/Import Guide

This guide helps you export your production database and import it locally for development and testing.

## Prerequisites

- SSH access to your production server
- MySQL client installed locally
- Local MySQL server running

## Step 1: Export Database from Production

### Option A: Export from Production Server (SSH Access)

SSH into your production server and run:

```bash
# Export the entire blog database
mysqldump -u YOUR_PROD_USER -p blog > blog_export_$(date +%Y%m%d).sql

# Or with compression (recommended for large databases)
mysqldump -u YOUR_PROD_USER -p blog | gzip > blog_export_$(date +%Y%m%d).sql.gz
```

### Option B: Export Specific Tables Only

If you only want certain data:

```bash
# Export only posts and users (no sessions, etc.)
mysqldump -u YOUR_PROD_USER -p blog User Post > blog_export_$(date +%Y%m%d).sql
```

### Option C: Remote Export (If you have remote MySQL access)

From your local machine:

```bash
# Direct export from remote server
mysqldump -h YOUR_PROD_HOST -P 3306 -u YOUR_PROD_USER -p blog > blog_export_$(date +%Y%m%d).sql

# With SSH tunnel (more secure)
ssh -L 3307:localhost:3306 user@your-prod-server
# Then in another terminal:
mysqldump -h 127.0.0.1 -P 3307 -u YOUR_PROD_USER -p blog > blog_export_$(date +%Y%m%d).sql
```

## Step 2: Transfer to Local Machine

If you exported on the production server, download the file:

```bash
# Using scp
scp user@your-prod-server:/path/to/blog_export_20250124.sql ~/Downloads/

# Using rsync (better for large files)
rsync -avz -e ssh user@your-prod-server:/path/to/blog_export_20250124.sql ~/Downloads/

# If compressed
scp user@your-prod-server:/path/to/blog_export_20250124.sql.gz ~/Downloads/
gunzip ~/Downloads/blog_export_20250124.sql.gz
```

## Step 3: Prepare Local Database

Create a fresh local database:

```bash
# Connect to MySQL
mysql -u root -p

# In MySQL shell:
CREATE DATABASE blog_local CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit;
```

## Step 4: Import to Local MySQL

```bash
# Import the dump file
mysql -u root -p blog_local < ~/Downloads/blog_export_20250124.sql

# Or if you want to see progress:
pv ~/Downloads/blog_export_20250124.sql | mysql -u root -p blog_local

# Verify import
mysql -u root -p blog_local -e "SHOW TABLES; SELECT COUNT(*) FROM Post; SELECT COUNT(*) FROM User;"
```

## Step 5: Configure Local Application

Update your environment variables to use the local database:

```bash
# In your terminal or add to ~/.zshrc or ~/.bashrc
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=blog_local
export DB_USER=root
export DB_PASSWORD=your_local_mysql_password
export SESSION_SECRET=local-dev-secret
export ENV=development
```

Or create a `.env` file in the project root:

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=blog_local
DB_USER=root
DB_PASSWORD=your_local_mysql_password
SESSION_SECRET=local-dev-secret
ENV=development
```

## Step 6: Handle Password Compatibility

⚠️ **Important**: If your production database still uses PBKDF2 passwords (from the old Perl version), but your Kotlin app uses BCrypt, authentication won't work.

### Option A: Create a Test Admin User

```bash
# Start your local app first to ensure tables exist
./gradlew run

# Then add this temporarily to Application.kt after DatabaseConfig.init():
```

```kotlin
// Add to Application.kt temporarily (after line 32)
transaction {
    val userService = UserService()
    if (userService.findByUsername("testadmin") == null) {
        userService.createUser("testadmin", "testpassword123")
        logger.info { "Created test admin user: testadmin / testpassword123" }
    }
}
```

Then restart the app and login with `testadmin` / `testpassword123`.

### Option B: Reset Passwords for Existing Users

If you want to use existing usernames:

```bash
mysql -u root -p blog_local

# In MySQL, get the BCrypt hash for a test password:
# (You'll need to generate this from Kotlin or use an online BCrypt generator)
# Example: "test123" -> $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

UPDATE User SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy' WHERE name = 'admin';
```

## Step 7: Run the Application

```bash
ENV=development ./gradlew run
```

Visit http://localhost:7070 and you should see your production data!

## Optional: Anonymize Sensitive Data

If you're sharing your local database with others, anonymize sensitive data:

```sql
-- Anonymize user data
UPDATE User SET
    name = CONCAT('user_', id),
    password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'; -- test123

-- Optionally sanitize post content if it contains sensitive info
UPDATE Post SET body = CONCAT('[SAMPLE POST ', id, ']') WHERE id > 10;
```

## Regular Sync Script

Create a script for regular syncing:

```bash
#!/bin/bash
# sync-prod-db.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="blog_export_$DATE.sql"

echo "Exporting from production..."
ssh user@your-prod-server "mysqldump -u prod_user -p'PROD_PASSWORD' blog" > "/tmp/$BACKUP_FILE"

echo "Importing to local..."
mysql -u root -p'LOCAL_PASSWORD' blog_local < "/tmp/$BACKUP_FILE"

echo "Cleaning up..."
rm "/tmp/$BACKUP_FILE"

echo "Done! Database synced at $DATE"
```

Make it executable:
```bash
chmod +x scripts/sync-prod-db.sh
./scripts/sync-prod-db.sh
```

## Troubleshooting

### Connection Issues

```bash
# Test local MySQL connection
mysql -u root -p -e "SELECT VERSION();"

# Check if database exists
mysql -u root -p -e "SHOW DATABASES LIKE 'blog_local';"
```

### Import Errors

```bash
# Check MySQL error log
tail -f /usr/local/var/mysql/*.err  # macOS Homebrew
tail -f /var/log/mysql/error.log    # Linux

# Import with verbose error reporting
mysql -u root -p --verbose --show-warnings blog_local < blog_export.sql
```

### Character Encoding Issues

```bash
# Ensure UTF-8 encoding during import
mysql -u root -p --default-character-set=utf8mb4 blog_local < blog_export.sql
```

## Security Notes

1. **Never commit** production database dumps to version control
2. **Add to .gitignore**:
   ```
   *.sql
   *.sql.gz
   .env
   ```
3. **Delete dumps** after importing to local
4. **Use SSH tunnels** instead of exposing MySQL ports publicly
5. **Rotate passwords** if they're exposed in scripts

## Quick Reference

```bash
# Export from production
ssh prod-server "mysqldump -u user -p blog | gzip" > blog.sql.gz

# Transfer and import
gunzip blog.sql.gz
mysql -u root -p blog_local < blog.sql

# Configure and run
export DB_NAME=blog_local
./gradlew run
```
