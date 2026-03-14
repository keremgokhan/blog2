package com.keremgokhan.blog.utils

import org.owasp.html.HtmlPolicyBuilder
import org.owasp.html.PolicyFactory

object HtmlSanitizer {
    private val policy: PolicyFactory = HtmlPolicyBuilder()
        .allowElements(
            "p", "br", "div", "span",
            "h1", "h2", "h3", "h4", "h5", "h6",
            "strong", "em", "b", "i", "u",
            "ul", "ol", "li",
            "a", "blockquote", "code", "pre",
            "img"
        )
        .allowAttributes("href").onElements("a")
        .allowAttributes("src", "alt", "width", "height").onElements("img")
        .allowAttributes("class").globally()
        .requireRelNofollowOnLinks()
        .toFactory()

    /**
     * Sanitizes HTML content to prevent XSS attacks while allowing safe formatting
     */
    fun sanitize(html: String?): String {
        if (html.isNullOrBlank()) return ""
        return policy.sanitize(html)
    }

    /**
     * Converts plain text to HTML-safe text by escaping special characters
     */
    fun escapeHtml(text: String?): String {
        if (text.isNullOrBlank()) return ""
        return text
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;")
    }
}
