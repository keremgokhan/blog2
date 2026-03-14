package com.keremgokhan.blog.utils

import com.vladsch.flexmark.html.HtmlRenderer
import com.vladsch.flexmark.parser.Parser
import com.vladsch.flexmark.util.data.MutableDataSet

object MarkdownUtil {
    private val options = MutableDataSet().apply {
        // Treat single newlines as <br> so line breaks in the editor are preserved
        set(HtmlRenderer.SOFT_BREAK, "<br />\n")
    }
    private val parser = Parser.builder(options).build()
    private val renderer = HtmlRenderer.builder(options).build()

    /**
     * Converts markdown (with optional inline HTML) to HTML.
     * Raw HTML tags in the input are preserved and passed through.
     * The output should still be run through HtmlSanitizer before display.
     */
    fun render(markdown: String): String {
        val document = parser.parse(markdown)
        return renderer.render(document)
    }
}
