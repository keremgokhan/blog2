# Blog - Kotlin/Javalin Edition

A modern, secure personal blog application written in Kotlin using the Javalin web framework. This is a complete rewrite of the original Perl/Mojolicious blog with significant improvements in security, maintainability, and developer experience.

## Features

- **Blog Posts**: Create, edit, and manage blog posts with a rich Markdown editor (EasyMDE)
- **Draft & Archive Workflow**: Save posts as drafts, publish, or archive them
- **AI Post Generation**: Generate posts using Claude (Anthropic API) with a customisable prompt, editable from the admin panel
- **Authentication**: Secure user authentication with BCrypt password hashing
- **Sketchbook Gallery**: Image gallery feature for showcasing artwork
- **Holocene Calendar**: Dates displayed in the Holocene calendar system (+10,000 years)
- **Security**: CSRF protection, HTML sanitization, and input validation
- **Responsive Design**: Mobile-friendly UI using Skeleton CSS framework
- **SEO**: Meta descriptions, Open Graph tags, canonical URLs, sitemap.xml

## Technology Stack

- **Framework**: [Javalin 6.x](https://javalin.io/) - Lightweight web framework
- **Language**: Kotlin 1.9.22
- **Database ORM**: [Exposed](https://github.com/JetBrains/Exposed) - JetBrains Kotlin SQL library
- **Template Engine**: [Jte](https://jte.gg/) - Fast, type-safe templates
- **Database**: MySQL 8.0+ (with H2 for testing)
- **Connection Pool**: HikariCP
- **Security**: BCrypt for password hashing, OWASP HTML Sanitizer
- **Testing**: JUnit 5, MockK
- **Logging**: Logback with kotlin-logging

## Prerequisites

- JDK 17 or higher
- MySQL 8.0 or higher
- Gradle 8.x (or use the included wrapper)

## Quick Start

### 1. Database Setup

Create a MySQL database:

```sql
CREATE DATABASE blog CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

The application will automatically create the necessary tables on first run via `SchemaUtils.createMissingTablesAndColumns()`.

### 2. Configuration

Create a `.env` file in the project root or set environment variables:

```bash
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=blog
export DB_USER=your_username
export DB_PASSWORD=your_password
export SESSION_SECRET=your-secret-key-here

# Optional: enable AI post generation
export ANTHROPIC_API_KEY=sk-ant-...
```

The application reads configuration in this order: `.env` file → environment variables → defaults.

### 3. Create Admin User

After starting the application once (so tables are created), insert a user directly into MySQL. The password must be BCrypt-hashed:

```bash
# Generate a BCrypt hash for your password (online tools or use a script)
# Then insert:
mysql -u your_username -p blog
```

```sql
INSERT INTO User (name, password, updated) VALUES ('yourname', '$2a$10$...bcrypt_hash...', NOW());
```

### 4. Seed AI Models (optional)

If you want to use AI post generation, insert the Claude user and model rows:

```sql
INSERT INTO User (name, password, is_artificial, updated)
VALUES ('Claude', UUID(), true, NOW());

SET @claude_id = LAST_INSERT_ID();

INSERT INTO AiModel (model_id, name, user_id, created, updated) VALUES
  ('claude-sonnet-4-6',         'Claude Sonnet 4',  @claude_id, NOW(), NOW()),
  ('claude-opus-4-6',           'Claude Opus 4',    @claude_id, NOW(), NOW()),
  ('claude-haiku-4-5-20251001', 'Claude Haiku 4.5', @claude_id, NOW(), NOW());
```

Then set your AI generation prompt via the admin panel at `/admin/prompt`.

### 5. Run the Application

```bash
# Development mode (template hot-reloading)
ENV=development ./gradlew run

# Production mode
./gradlew shadowJar
java -jar build/libs/blog-kotlin-1.0.0-all.jar
```

The application will start on `http://localhost:7070`.

### 6. Run Tests

```bash
./gradlew test
```

## Project Structure

```
blog-kotlin/
├── src/
│   ├── main/
│   │   ├── kotlin/com/keremgokhan/blog/
│   │   │   ├── Application.kt               # Main application entry point & routes
│   │   │   ├── config/
│   │   │   │   ├── AppConfig.kt
│   │   │   │   └── DatabaseConfig.kt
│   │   │   ├── controllers/
│   │   │   │   ├── AdminController.kt
│   │   │   │   ├── AdminPromptController.kt  # AI prompt editor
│   │   │   │   ├── AiPostController.kt       # AI generation endpoint
│   │   │   │   ├── IndexController.kt
│   │   │   │   ├── PostController.kt
│   │   │   │   └── SketchbookController.kt
│   │   │   ├── models/
│   │   │   │   ├── AiModels.kt              # AI model registry table
│   │   │   │   ├── Posts.kt
│   │   │   │   ├── Settings.kt              # Key-value settings table
│   │   │   │   └── Users.kt
│   │   │   ├── services/
│   │   │   │   ├── AiPostService.kt         # Claude API integration
│   │   │   │   ├── AuthService.kt
│   │   │   │   ├── PostService.kt
│   │   │   │   ├── SettingsService.kt       # Admin-editable settings
│   │   │   │   └── UserService.kt
│   │   │   └── utils/
│   │   │       ├── CsrfUtil.kt
│   │   │       ├── DateUtil.kt
│   │   │       └── HtmlSanitizer.kt
│   │   └── resources/
│   │       ├── templates/
│   │       │   ├── layouts/
│   │       │   ├── posts/
│   │       │   ├── admin/
│   │       │   ├── sketchbook/
│   │       │   └── errors/
│   │       ├── prompts/
│   │       │   └── ai-post-generation.txt   # Default AI prompt template
│   │       └── public/
│   │           ├── css/
│   │           └── images/
│   └── test/
└── build.gradle.kts
```

## API Routes

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/` | List all published posts | No |
| GET | `/sitemap.xml` | XML sitemap | No |
| GET | `/post/:id` | View single post | No |
| GET | `/admin` | Admin dashboard or login | No |
| POST | `/admin/login` | Authenticate | No |
| GET | `/admin/logout` | Logout | Yes |
| GET | `/admin/create` | Post creation form | Yes |
| GET | `/admin/prompt` | AI prompt editor | Yes |
| POST | `/admin/prompt` | Save AI prompt | Yes |
| POST | `/admin/ai-generate` | Generate post via Claude API (returns JSON) | Yes |
| POST | `/post` | Create new post | Yes |
| GET | `/post/:id/edit` | Edit post form | Yes |
| POST | `/post/:id/edit` | Update post | Yes |
| POST | `/post/:id/archive` | Archive post | Yes |
| POST | `/post/:id/restore` | Restore archived post | Yes |
| GET | `/sketchbook` | Image gallery | No |

## Security Features

1. **Password Security**: BCrypt hashing with automatic salt generation
2. **CSRF Protection**: Token-based protection on all state-changing operations
3. **HTML Sanitization**: All user-generated content sanitized using OWASP HTML Sanitizer
4. **Session Management**: Secure session handling with HttpOnly cookies, secure flag in production
5. **SQL Injection Protection**: Parameterized queries via Exposed ORM
6. **XSS Prevention**: Automatic HTML escaping in Jte templates

## Development

### Development Mode

```bash
ENV=development ./gradlew run
```

- Template hot reloading (no restart needed on template changes)
- More verbose logging
- Non-secure session cookies (for HTTP testing)

### Adding a New Route

1. Add controller method in the appropriate controller
2. Register the route in `Application.kt`
3. Create the corresponding Jte template
4. Add service method if business logic is needed
5. Write tests for the service layer

## Deployment

### Production Checklist

- [ ] Set `ENV=production`
- [ ] Use a strong `SESSION_SECRET` (32+ random characters)
- [ ] Configure database credentials via environment variables
- [ ] Set `ANTHROPIC_API_KEY` if using AI generation
- [ ] Enable HTTPS (configure reverse proxy like Nginx)
- [ ] Set up automated backups for MySQL database
- [ ] Consider using a process manager (systemd)

### Systemd Service

Add environment variables in `/etc/systemd/system/blog.service`:

```ini
[Service]
Environment=ENV=production
Environment=DB_HOST=localhost
Environment=DB_NAME=blog
Environment=DB_USER=blog
Environment=DB_PASSWORD=secret
Environment=SESSION_SECRET=your-secret
Environment=ANTHROPIC_API_KEY=sk-ant-...
ExecStart=/usr/bin/java -Xmx256m -jar /opt/blog/blog-kotlin-1.0.0-all.jar
```

## Testing

```bash
# Run all tests
./gradlew test

# Run specific test class
./gradlew test --tests UserServiceTest

# View test report
open build/reports/tests/test/index.html
```

## Migration from Perl Version

1. **Export your data** from the Perl MySQL database
2. **Import to new database** (schema is compatible)
3. **Re-hash passwords**: Passwords need to be re-hashed with BCrypt — users must reset them
4. **Copy images**: Copy image files to `src/main/resources/public/images/`
5. **Update configuration**: Set environment variables for database connection

## Troubleshooting

### Application won't start
- Check database connection settings
- Verify MySQL is running and accessible

### AI generation fails
- Verify `ANTHROPIC_API_KEY` is set in the environment
- Ensure a prompt is saved via `/admin/prompt`
- Check that Claude user and AiModel rows exist in the database

### Templates not updating
- Make sure you're running in development mode (`ENV=development`)

---

Built with ❤️ using Kotlin and Javalin
