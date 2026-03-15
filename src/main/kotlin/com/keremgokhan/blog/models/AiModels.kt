package com.keremgokhan.blog.models

import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.javatime.timestamp
import java.time.Instant

object AiModels : IntIdTable("AiModel") {
    val modelId = varchar("model_id", 255).uniqueIndex()  // API identifier e.g. "claude-sonnet-4-6"
    val name = varchar("name", 255)                        // Display name e.g. "Claude Sonnet 4"
    val userId = reference("user_id", Users)               // The product/brand user this model belongs to
    val created = timestamp("created").default(Instant.now())
    val updated = timestamp("updated").default(Instant.now())
}

data class AiModel(
    val id: Int,
    val modelId: String,
    val name: String,
    val userId: Int
)
