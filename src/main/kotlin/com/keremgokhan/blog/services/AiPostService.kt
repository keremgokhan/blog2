package com.keremgokhan.blog.services

import com.fasterxml.jackson.databind.ObjectMapper
import com.keremgokhan.blog.models.PostWithAuthor
import mu.KotlinLogging
import java.net.URI
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.time.Duration

private val logger = KotlinLogging.logger {}

class AiPostService(
    private val postService: PostService,
    private val settingsService: SettingsService,
    private val apiKey: String?
) {
    companion object {
        const val MODEL_SONNET = "claude-sonnet-4-6"
        const val MODEL_OPUS = "claude-opus-4-6"
        const val MODEL_HAIKU = "claude-haiku-4-5-20251001"
        private const val MAX_TOKENS = 300
        private const val API_URL = "https://api.anthropic.com/v1/messages"
    }

    private val httpClient = HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(30))
        .build()

    private val objectMapper = ObjectMapper()

    // Returns Pair(title, markdownBody) without saving to DB.
    // The caller decides what to do with the content.
    fun generate(model: String = MODEL_SONNET): Pair<String, String>? {
        if (apiKey.isNullOrBlank()) {
            logger.error { "ANTHROPIC_API_KEY is not configured" }
            return null
        }

        val posts = postService.getAllPosts()
        logger.info { "Building prompt with ${posts.size} posts as voice context" }

        val prompt = buildPrompt(posts)
        val responseText = callClaudeApi(prompt, model) ?: return null
        return parseResponse(responseText)
    }

    private fun buildPrompt(posts: List<PostWithAuthor>): String {
        val postsText = posts.mapIndexed { i, post ->
            val plainBody = post.body
                .replace(Regex("<[^>]*>"), " ")
                .replace(Regex("\\s+"), " ")
                .trim()
            val byLine = if (post.aiGenerated) "[by AI]" else "[by Kerem]"
            "Post ${i + 1} $byLine — \"${post.title}\":\n$plainBody"
        }.joinToString("\n\n---\n\n")

        val template = settingsService.get("ai_prompt")
        if (template.isNullOrBlank()) {
            logger.error { "ai_prompt is not configured. Set it in Admin > Prompt." }
            error("ai_prompt setting is empty")
        }

        val humanPosts = posts.filter { !it.aiGenerated }
        val hint = (if (humanPosts.isNotEmpty()) humanPosts else posts).random().title
        logger.info { "Using topic hint from post: \"$hint\"" }

        return template
            .replace("{{posts}}", postsText)
            .replace("{{topic_hint}}", hint)
    }

    private fun callClaudeApi(prompt: String, model: String): String? {
        val requestBody = objectMapper.writeValueAsString(
            mapOf(
                "model" to model,
                "max_tokens" to MAX_TOKENS,
                "messages" to listOf(
                    mapOf("role" to "user", "content" to prompt)
                )
            )
        )

        val request = HttpRequest.newBuilder()
            .uri(URI.create(API_URL))
            .header("Content-Type", "application/json")
            .header("x-api-key", apiKey!!)
            .header("anthropic-version", "2023-06-01")
            .timeout(Duration.ofSeconds(120))
            .POST(HttpRequest.BodyPublishers.ofString(requestBody))
            .build()

        return try {
            logger.info { "Calling Claude API ($model)..." }
            val response = httpClient.send(request, HttpResponse.BodyHandlers.ofString())
            if (response.statusCode() != 200) {
                logger.error { "Claude API error ${response.statusCode()}: ${response.body()}" }
                return null
            }
            val responseJson = objectMapper.readTree(response.body())
            val text = responseJson["content"]?.get(0)?.get("text")?.asText()
            logger.info { "Claude API response received" }
            text
        } catch (e: Exception) {
            logger.error(e) { "Failed to call Claude API" }
            null
        }
    }

    private fun parseResponse(text: String): Pair<String, String>? {
        return try {
            val jsonStart = text.indexOf('{')
            val jsonEnd = text.lastIndexOf('}')
            if (jsonStart == -1 || jsonEnd == -1) {
                logger.error { "No JSON found in Claude response: $text" }
                return null
            }
            val json = text.substring(jsonStart, jsonEnd + 1)
            val node = objectMapper.readTree(json)
            val title = node["title"]?.asText()?.takeIf { it.isNotBlank() } ?: return null
            val body = node["body"]?.asText()?.takeIf { it.isNotBlank() } ?: return null
            Pair(title, body)
        } catch (e: Exception) {
            logger.error(e) { "Failed to parse Claude response: $text" }
            null
        }
    }
}
