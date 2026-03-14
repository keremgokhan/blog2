# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A modern personal blog application written in Kotlin using the Javalin web framework. This is a rewrite of an original Perl/Mojolicious blog with enhanced security, type safety, and maintainability. The blog supports authenticated post creation, a sketchbook gallery feature, and uses the Holocene calendar system for dates.

## Build & Development Commands

### Running the Application

```bash
# Development mode (hot-reloading templates)
ENV=development ./gradlew run

# Production mode
ENV=production ./gradlew run

# Build standalone JAR
./gradlew shadowJar
java -jar build/libs/blog-kotlin-1.0.0-all.jar
```

### Testing

```bash
# Run all tests
./gradlew test

# Run specific test class
./gradlew test --tests AuthServiceTest

# Run specific test method
./gradlew test --tests AuthServiceTest.testAuthenticate

# View test report
open build/reports/tests/test/index.html
```

### Database Setup

The application auto-creates tables on startup. Required environment variables:

```bash
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=blog
export DB_USER=your_username
export DB_PASSWORD=your_password
export SESSION_SECRET=your-secret-key-here
```

Create the database first:
```sql
CREATE DATABASE blog CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## Architecture

### Layered Architecture

The application follows a clean layered architecture:

1. **Controllers** (`controllers/`) - Handle HTTP requests/responses, delegate to services
2. **Services** (`services/`) - Business logic, coordinate between models/database
3. **Models** (`models/`) - Data models using Exposed ORM (Posts, Users)
4. **Utils** (`utils/`) - Cross-cutting concerns (CSRF, HTML sanitization, date formatting)
5. **Config** (`config/`) - Application configuration and database connection

### Key Architectural Patterns

- **Service Layer**: Business logic is isolated in service classes (AuthService, PostService, UserService)
- **Template Rendering**: Jte templates provide type-safe, precompiled views
- **Session-based Auth**: Session management via Javalin with user ID stored in session
- **ORM**: Exposed DSL for type-safe database access with connection pooling (HikariCP)

### Database Schema

Two main tables defined in `models/`:

- **Users** (`models/Users.kt`): User authentication (BCrypt hashed passwords)
- **Posts** (`models/Posts.kt`): Blog posts with author foreign key

Both use Exposed's table definitions and DSL queries.

### Security Architecture

1. **CSRF Protection** (`utils/CsrfUtil.kt`): Token generation/validation for state-changing operations
2. **HTML Sanitization** (`utils/HtmlSanitizer.kt`): OWASP sanitizer prevents XSS in post content
3. **Password Hashing**: BCrypt via UserService
4. **Session Security**: HttpOnly cookies, secure flag in production
5. **SQL Injection**: Prevented via Exposed parameterized queries

### Template System

Jte templates in `src/main/resources/templates/`:

- **Layouts**: `layouts/default.jte`, `layouts/blog.jte`, `layouts/sketchbook.jte`
- **Features**: Type-safe parameters, auto-escaping (XSS protection), hot-reload in dev mode
- **Usage**: Controllers call `ctx.render("path/to/template.jte", mapOf("key" to value))`

### Configuration

`config/AppConfig.kt` loads from:
1. `.env` file (highest priority, for local development)
2. System environment variables (for production)
3. Default values (fallback)

This follows the 12-factor app methodology. The `.env` file is git-ignored and should contain your local configuration. In production, set environment variables directly.

## Special Behaviors

### Holocene Calendar

The blog uses Holocene calendar dates (adds 10,000 years to Gregorian). Implemented in `utils/DateUtil.kt`:
- `formatDateHolocene()`: Converts standard dates to Holocene format
- Used throughout templates for displaying dates

When working with dates, always use DateUtil rather than formatting manually.

### Development vs Production Mode

Controlled by `ENV` environment variable:
- **Development** (`ENV=development`): Template hot-reloading, verbose logging, non-secure cookies
- **Production** (`ENV=production`): Precompiled templates, secure cookies, minimal logging

The application checks `System.getenv("ENV") != "production"` to determine mode.

### Database Transactions

All database operations wrapped in Exposed transactions:
```kotlin
transaction {
    // Database operations here
}
```

Services handle transaction management. Controllers should never access database directly.

## Testing Strategy

- **Unit Tests**: Services and utilities (AuthService, PostService, UserService, DateUtil, HtmlSanitizer)
- **Test Database**: H2 in-memory database for isolation
- **Mocking**: MockK for mocking dependencies
- **Location**: Tests mirror main structure in `src/test/kotlin/`

When adding features, write tests for service layer logic. Controllers are tested via service mocks.

## Common Development Patterns

### Adding a New Route

1. Add controller method in appropriate controller class
2. Register route in `Application.kt` main function
3. Create Jte template in `src/main/resources/templates/`
4. Add service method if business logic needed
5. Write tests for service layer

### Creating Authenticated Routes

Use `authService.requireAuth(ctx)` in controller:
```kotlin
fun create(ctx: Context) {
    val user = authService.requireAuth(ctx)
    // Proceed with authenticated logic
}
```

For conditional auth, use `authService.isAuthenticated(ctx)` or `authService.getCurrentUser(ctx)`.

### Working with Posts

Post content is HTML-sanitized before storage:
- Create: `PostService.createPost()` sanitizes via `HtmlSanitizer.sanitize()`
- Display: Already sanitized, safe to render in templates

Never bypass sanitization or use raw HTML rendering.

### CSRF Protection

All state-changing forms require CSRF tokens:
1. Generate: `CsrfUtil.generateToken()` in controller, pass to template
2. Include: Add hidden input in form: `<input type="hidden" name="csrfToken" value="${csrfToken}">`
3. Validate: `CsrfUtil.validateToken(ctx)` in POST handler

## Migration Context

This codebase was converted from a Perl/Mojolicious blog. Key changes:
- PBKDF2 → BCrypt (passwords incompatible, users must reset)
- Embedded Perl templates → Jte
- Class::DBI → Exposed ORM
- Added CSRF protection and HTML sanitization (security improvements)

Database schema is compatible with the Perl version except password hashing algorithm.
