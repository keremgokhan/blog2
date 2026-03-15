package com.keremgokhan.blog.models

import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.javatime.timestamp
import java.time.Instant

object Settings : IntIdTable("Setting") {
    val key = varchar("key", 255).uniqueIndex()
    val value = text("value")
    val created = timestamp("created").default(Instant.now())
    val updated = timestamp("updated").default(Instant.now())
}
