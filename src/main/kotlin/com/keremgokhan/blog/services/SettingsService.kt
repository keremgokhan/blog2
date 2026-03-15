package com.keremgokhan.blog.services

import com.keremgokhan.blog.models.Settings
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import java.time.Instant

class SettingsService {
    fun get(key: String): String? = transaction {
        Settings.selectAll()
            .where { Settings.key eq key }
            .firstOrNull()
            ?.get(Settings.value)
    }

    fun set(key: String, value: String) = transaction {
        val existing = Settings.selectAll().where { Settings.key eq key }.firstOrNull()
        if (existing != null) {
            Settings.update({ Settings.key eq key }) {
                it[Settings.value] = value
                it[Settings.updated] = Instant.now()
            }
        } else {
            Settings.insert {
                it[Settings.key] = key
                it[Settings.value] = value
            }
        }
    }
}
