package com.keremgokhan.blog.controllers

import com.keremgokhan.blog.services.AuthService
import com.keremgokhan.blog.services.PostService
import com.keremgokhan.blog.utils.CsrfUtil
import com.keremgokhan.blog.utils.DateUtil
import io.javalin.http.Context
import mu.KotlinLogging

private val logger = KotlinLogging.logger {}

class AdminController(
    private val authService: AuthService,
    private val postService: PostService
) {
    fun index(ctx: Context) {
        val currentUser = authService.getCurrentUser(ctx)
        val today = DateUtil.formatTodayString(java.time.LocalDateTime.now())

        if (currentUser == null) {
            // Show login form
            val error = ctx.queryParam("error")
            ctx.render("admin/login.jte", mapOf(
                "error" to error,
                "csrfToken" to CsrfUtil.generateToken(ctx),
                "today" to today
            ))
        } else {
            val drafts = postService.getPostsByStatus("draft").map { post ->
                mapOf("id" to post.id, "title" to post.title)
            }
            val archived = postService.getPostsByStatus("archived").map { post ->
                mapOf("id" to post.id, "title" to post.title)
            }
            ctx.render("admin/index.jte", mapOf(
                "currentUser" to currentUser,
                "isAuthenticated" to true,
                "today" to today,
                "drafts" to drafts,
                "archived" to archived,
                "csrfToken" to CsrfUtil.generateToken(ctx)
            ))
        }
    }

    fun login(ctx: Context) {
        // Verify CSRF token
        if (!CsrfUtil.validateToken(ctx)) {
            logger.warn { "CSRF token validation failed on login" }
            ctx.redirect("/admin?error=csrf")
            return
        }

        val username = ctx.formParam("username")?.trim()
        val password = ctx.formParam("password")

        if (username.isNullOrBlank() || password.isNullOrBlank()) {
            ctx.redirect("/admin?error=empty")
            return
        }

        val user = authService.authenticate(username, password)
        if (user != null) {
            authService.login(ctx, user)
            logger.info { "User logged in: $username" }
            ctx.redirect("/admin")
        } else {
            logger.warn { "Failed login attempt for username: $username" }
            ctx.redirect("/admin?error=invalid")
        }
    }

    fun logout(ctx: Context) {
        authService.logout(ctx)
        logger.info { "User logged out" }
        ctx.redirect("/")
    }

    fun showCreatePost(ctx: Context) {
        val currentUser = authService.getCurrentUser(ctx)

        if (currentUser == null) {
            ctx.redirect("/admin")
            return
        }

        val error = ctx.queryParam("error")
        val today = DateUtil.formatTodayString(java.time.LocalDateTime.now())

        ctx.render("admin/create.jte", mapOf(
            "currentUser" to currentUser,
            "isAuthenticated" to true,
            "error" to error,
            "csrfToken" to CsrfUtil.generateToken(ctx),
            "today" to today
        ))
    }
}
