package com.keremgokhan.blog.controllers

import com.keremgokhan.blog.services.AuthService
import com.keremgokhan.blog.services.SettingsService
import com.keremgokhan.blog.utils.CsrfUtil
import com.keremgokhan.blog.utils.DateUtil
import io.javalin.http.Context
import io.javalin.http.HttpStatus
import mu.KotlinLogging

private val logger = KotlinLogging.logger {}

class AdminPromptController(
    private val settingsService: SettingsService,
    private val authService: AuthService
) {
    fun show(ctx: Context) {
        if (!authService.isAuthenticated(ctx)) {
            ctx.redirect("/admin")
            return
        }

        ctx.render("admin/prompt.jte", mapOf(
            "currentUser" to authService.getCurrentUser(ctx),
            "isAuthenticated" to true,
            "today" to DateUtil.formatTodayString(java.time.LocalDateTime.now()),
            "prompt" to (settingsService.get("ai_prompt") ?: ""),
            "csrfToken" to CsrfUtil.generateToken(ctx),
            "saved" to (ctx.queryParam("saved") == "true")
        ))
    }

    fun save(ctx: Context) {
        if (!authService.isAuthenticated(ctx)) {
            ctx.status(HttpStatus.UNAUTHORIZED)
            ctx.redirect("/admin")
            return
        }

        if (!CsrfUtil.validateToken(ctx)) {
            logger.warn { "CSRF validation failed on prompt save" }
            ctx.status(HttpStatus.FORBIDDEN)
            ctx.result("CSRF token validation failed")
            return
        }

        val prompt = ctx.formParam("prompt") ?: ""
        settingsService.set("ai_prompt", prompt)
        logger.info { "AI prompt updated (${prompt.length} chars)" }
        ctx.redirect("/admin/prompt?saved=true")
    }
}
