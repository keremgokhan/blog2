package com.keremgokhan.blog.controllers

import com.keremgokhan.blog.services.AuthService
import com.keremgokhan.blog.services.PostService
import com.keremgokhan.blog.utils.DateUtil
import com.keremgokhan.blog.utils.HtmlSanitizer
import io.javalin.http.Context
import java.time.format.DateTimeFormatter

class IndexController(
    private val postService: PostService,
    private val authService: AuthService
) {
    fun index(ctx: Context) {
        val posts = postService.getAllPosts().map { post ->
            mapOf(
                "id" to post.id,
                "title" to post.title,
                "body" to HtmlSanitizer.sanitize(post.body),
                "author" to post.author,
                "date" to DateUtil.formatDateHolocene(post.created),
                "time" to DateUtil.formatTime(post.created),
                "aiGenerated" to post.aiGenerated
            )
        }

        val currentUser = authService.getCurrentUser(ctx)
        val today = DateUtil.formatTodayString(java.time.LocalDateTime.now())

        ctx.render("posts/index.jte", mapOf(
            "posts" to posts,
            "currentUser" to currentUser,
            "isAuthenticated" to authService.isAuthenticated(ctx),
            "today" to today
        ))
    }

    fun sitemap(ctx: Context) {
        val posts = postService.getAllPosts()
        val fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd")
        val sb = StringBuilder()
        sb.appendLine("""<?xml version="1.0" encoding="UTF-8"?>""")
        sb.appendLine("""<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">""")
        sb.appendLine("""  <url><loc>https://keremgokhan.net/</loc><changefreq>weekly</changefreq><priority>1.0</priority></url>""")
        for (post in posts) {
            val date = post.created.format(fmt)
            sb.appendLine("""  <url><loc>https://keremgokhan.net/post/${post.id}</loc><lastmod>$date</lastmod><changefreq>monthly</changefreq><priority>0.8</priority></url>""")
        }
        sb.appendLine("</urlset>")
        ctx.contentType("application/xml")
        ctx.result(sb.toString())
    }
}
