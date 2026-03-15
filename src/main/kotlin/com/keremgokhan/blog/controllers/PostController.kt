package com.keremgokhan.blog.controllers

import com.keremgokhan.blog.services.AuthService
import com.keremgokhan.blog.services.PostService
import com.keremgokhan.blog.utils.CsrfUtil
import com.keremgokhan.blog.utils.DateUtil
import com.keremgokhan.blog.utils.HtmlSanitizer
import com.keremgokhan.blog.utils.MarkdownUtil
import io.javalin.http.Context
import io.javalin.http.HttpStatus
import mu.KotlinLogging

private val logger = KotlinLogging.logger {}

class PostController(
    private val postService: PostService,
    private val authService: AuthService
) {
    fun show(ctx: Context) {
        val today = DateUtil.formatTodayString(java.time.LocalDateTime.now())

        val id = ctx.pathParam("id").toIntOrNull()
        if (id == null) {
            ctx.status(HttpStatus.NOT_FOUND)
            ctx.render("errors/404.jte", mapOf(
                "message" to "Invalid post ID",
                "today" to today
            ))
            return
        }

        val post = postService.getPostById(id)
        if (post == null) {
            ctx.status(HttpStatus.NOT_FOUND)
            ctx.render("errors/404.jte", mapOf(
                "message" to "Post not found",
                "today" to today
            ))
            return
        }

        val currentUser = authService.getCurrentUser(ctx)
        val sanitizedBody = HtmlSanitizer.sanitize(post.body)
        val plainText = sanitizedBody.replace(Regex("<[^>]*>"), " ").replace(Regex("\\s+"), " ").trim()
        val description = if (plainText.length > 160) plainText.substring(0, 157) + "..." else plainText

        ctx.render("posts/show.jte", mapOf(
            "post" to mapOf(
                "id" to post.id,
                "title" to post.title,
                "body" to sanitizedBody,
                "author" to post.author,
                "date" to DateUtil.formatDateHolocene(post.created),
                "time" to DateUtil.formatTime(post.created),
                "aiGenerated" to post.aiGenerated
            ),
            "description" to description,
            "canonicalUrl" to "https://keremgokhan.net/post/${post.id}",
            "currentUser" to currentUser,
            "isAuthenticated" to authService.isAuthenticated(ctx),
            "today" to today
        ))
    }

    fun showEdit(ctx: Context) {
        if (!authService.isAuthenticated(ctx)) {
            ctx.redirect("/admin")
            return
        }

        val id = ctx.pathParam("id").toIntOrNull()
        val post = if (id != null) postService.getPostById(id) else null
        if (post == null) {
            ctx.status(HttpStatus.NOT_FOUND)
            ctx.render("errors/404.jte", mapOf(
                "message" to "Post not found",
                "today" to DateUtil.formatTodayString(java.time.LocalDateTime.now())
            ))
            return
        }

        val currentUser = authService.getCurrentUser(ctx)
        val today = DateUtil.formatTodayString(java.time.LocalDateTime.now())

        ctx.render("admin/edit.jte", mapOf(
            "post" to mapOf(
                "id" to post.id,
                "title" to post.title,
                "body" to post.body
            ),
            "currentUser" to currentUser,
            "isAuthenticated" to true,
            "csrfToken" to CsrfUtil.generateToken(ctx),
            "today" to today
        ))
    }

    fun update(ctx: Context) {
        if (!authService.isAuthenticated(ctx)) {
            ctx.status(HttpStatus.UNAUTHORIZED)
            ctx.redirect("/admin")
            return
        }

        if (!CsrfUtil.validateToken(ctx)) {
            logger.warn { "CSRF token validation failed on update" }
            ctx.status(HttpStatus.FORBIDDEN)
            ctx.result("CSRF token validation failed")
            return
        }

        val id = ctx.pathParam("id").toIntOrNull()
        if (id == null) {
            ctx.status(HttpStatus.NOT_FOUND)
            return
        }

        val title = ctx.formParam("title")?.trim()
        val body = ctx.formParam("body")?.trim()

        if (title.isNullOrBlank() || body.isNullOrBlank()) {
            ctx.redirect("/post/$id/edit?error=empty")
            return
        }

        val status = if (ctx.formParam("draft") == "true") "draft" else "published"
        val html = MarkdownUtil.render(body)
        val updated = postService.updatePost(id, title, html, status)

        if (updated) {
            logger.info { "Post updated ($status): $id" }
            if (status == "draft") ctx.redirect("/admin") else ctx.redirect("/post/$id")
        } else {
            logger.error { "Failed to update post: $id" }
            ctx.redirect("/post/$id/edit?error=failed")
        }
    }

    fun archive(ctx: Context) {
        if (!authService.isAuthenticated(ctx)) {
            ctx.status(HttpStatus.UNAUTHORIZED)
            ctx.redirect("/admin")
            return
        }

        if (!CsrfUtil.validateToken(ctx)) {
            logger.warn { "CSRF token validation failed on archive" }
            ctx.status(HttpStatus.FORBIDDEN)
            ctx.result("CSRF token validation failed")
            return
        }

        val id = ctx.pathParam("id").toIntOrNull()
        if (id == null) {
            ctx.status(HttpStatus.NOT_FOUND)
            return
        }

        val archived = postService.setStatus(id, "archived")

        if (archived) {
            logger.info { "Post archived: $id" }
            ctx.redirect("/admin")
        } else {
            logger.error { "Failed to archive post: $id" }
            ctx.redirect("/post/$id/edit?error=failed")
        }
    }

    fun restore(ctx: Context) {
        if (!authService.isAuthenticated(ctx)) {
            ctx.status(HttpStatus.UNAUTHORIZED)
            ctx.redirect("/admin")
            return
        }

        if (!CsrfUtil.validateToken(ctx)) {
            logger.warn { "CSRF token validation failed on restore" }
            ctx.status(HttpStatus.FORBIDDEN)
            ctx.result("CSRF token validation failed")
            return
        }

        val id = ctx.pathParam("id").toIntOrNull()
        if (id == null) {
            ctx.status(HttpStatus.NOT_FOUND)
            return
        }

        val restored = postService.setStatus(id, "published")

        if (restored) {
            logger.info { "Post restored: $id" }
            ctx.redirect("/admin")
        } else {
            logger.error { "Failed to restore post: $id" }
            ctx.redirect("/admin")
        }
    }

    fun create(ctx: Context) {
        // Verify authentication
        if (!authService.isAuthenticated(ctx)) {
            ctx.status(HttpStatus.UNAUTHORIZED)
            ctx.redirect("/admin")
            return
        }

        // Verify CSRF token
        if (!CsrfUtil.validateToken(ctx)) {
            logger.warn { "CSRF token validation failed" }
            ctx.status(HttpStatus.FORBIDDEN)
            ctx.result("CSRF token validation failed")
            return
        }

        val title = ctx.formParam("title")?.trim()
        val body = ctx.formParam("body")?.trim()

        if (title.isNullOrBlank() || body.isNullOrBlank()) {
            ctx.redirect("/admin/create?error=empty")
            return
        }

        val user = authService.requireAuth(ctx)
        val status = if (ctx.formParam("draft") == "true") "draft" else "published"
        val aiGenerated = ctx.formParam("ai_generated") == "true"
        val aiModel = ctx.formParam("ai_model")
        val authorId = if (aiGenerated && !aiModel.isNullOrBlank())
            postService.getAiUserIdByModel(aiModel) ?: user.id
        else user.id
        val html = MarkdownUtil.render(body)
        val post = postService.createPost(title, html, authorId, status, aiGenerated)

        if (post != null) {
            logger.info { "Post created (${post.status}): ${post.id} - ${post.title}" }
            if (status == "draft") ctx.redirect("/admin") else ctx.redirect("/")
        } else {
            logger.error { "Failed to create post" }
            ctx.redirect("/admin/create?error=failed")
        }
    }
}
