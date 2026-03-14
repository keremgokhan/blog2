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

        ctx.render("posts/show.jte", mapOf(
            "post" to mapOf(
                "id" to post.id,
                "title" to post.title,
                "body" to HtmlSanitizer.sanitize(post.body),
                "author" to post.author,
                "date" to DateUtil.formatDateHolocene(post.created),
                "time" to DateUtil.formatTime(post.created)
            ),
            "currentUser" to currentUser,
            "isAuthenticated" to authService.isAuthenticated(ctx),
            "today" to today
        ))
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
        val html = MarkdownUtil.render(body)
        val post = postService.createPost(title, html, user.id)

        if (post != null) {
            logger.info { "Post created: ${post.id} - ${post.title}" }
            ctx.redirect("/")
        } else {
            logger.error { "Failed to create post" }
            ctx.redirect("/admin/create?error=failed")
        }
    }
}
