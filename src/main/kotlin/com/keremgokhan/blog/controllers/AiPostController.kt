package com.keremgokhan.blog.controllers

import com.keremgokhan.blog.services.AiPostService
import com.keremgokhan.blog.services.AuthService
import com.keremgokhan.blog.utils.CsrfUtil
import io.javalin.http.Context
import io.javalin.http.HttpStatus
import mu.KotlinLogging

private val logger = KotlinLogging.logger {}

class AiPostController(
    private val aiPostService: AiPostService,
    private val authService: AuthService
) {
    fun generate(ctx: Context) {
        if (!authService.isAuthenticated(ctx)) {
            ctx.status(HttpStatus.UNAUTHORIZED)
            ctx.json(mapOf("error" to "Not authenticated"))
            return
        }

        if (!CsrfUtil.validateToken(ctx)) {
            logger.warn { "CSRF validation failed on AI post generation" }
            ctx.status(HttpStatus.FORBIDDEN)
            ctx.json(mapOf("error" to "CSRF token validation failed"))
            return
        }

        val model = ctx.formParam("model")?.takeIf { it.isNotBlank() } ?: AiPostService.MODEL_SONNET
        logger.info { "Generating AI post with model: $model" }

        val result = aiPostService.generate(model)

        if (result != null) {
            val (title, body) = result
            logger.info { "AI content generated: title=$title" }
            ctx.json(mapOf("title" to title, "body" to body))
        } else {
            logger.error { "AI post generation failed" }
            ctx.status(HttpStatus.INTERNAL_SERVER_ERROR)
            ctx.json(mapOf("error" to "Generation failed. Check that ANTHROPIC_API_KEY is configured."))
        }
    }
}
