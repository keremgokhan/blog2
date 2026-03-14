package com.keremgokhan.blog.config

import io.github.cdimascio.dotenv.Dotenv

data class AppConfig(
    val server: ServerConfig,
    val database: DatabaseConfig,
    val session: SessionConfig,
    val analytics: AnalyticsConfig
) {
    data class ServerConfig(
        val port: Int,
        val host: String
    )

    data class DatabaseConfig(
        val host: String,
        val port: Int,
        val name: String,
        val user: String,
        val password: String
    )

    data class SessionConfig(
        val secret: String,
        val maxAge: Int
    )

    data class AnalyticsConfig(
        val enabled: Boolean,
        val googleAnalyticsId: String?
    )

    companion object {
        fun load(dotenv: Dotenv? = null): AppConfig {
            return AppConfig(
                server = ServerConfig(
                    port = getEnv(dotenv, "SERVER_PORT", "7070").toInt(),
                    host = getEnv(dotenv, "SERVER_HOST", "0.0.0.0")
                ),
                database = DatabaseConfig(
                    host = getEnv(dotenv, "DB_HOST", "localhost"),
                    port = getEnv(dotenv, "DB_PORT", "3306").toInt(),
                    name = getEnv(dotenv, "DB_NAME", "blog"),
                    user = getEnv(dotenv, "DB_USER", "root"),
                    password = getEnv(dotenv, "DB_PASSWORD", "")
                ),
                session = SessionConfig(
                    secret = getEnv(dotenv, "SESSION_SECRET", "change-this-secret-in-production"),
                    maxAge = getEnv(dotenv, "SESSION_MAX_AGE", "86400").toInt()
                ),
                analytics = AnalyticsConfig(
                    enabled = getEnv(dotenv, "ANALYTICS_ENABLED", "false").toBoolean(),
                    googleAnalyticsId = getEnvOrNull(dotenv, "GOOGLE_ANALYTICS_ID")
                )
            )
        }

        private fun getEnv(dotenv: Dotenv?, key: String, default: String): String {
            return dotenv?.get(key) ?: System.getenv(key) ?: default
        }

        private fun getEnvOrNull(dotenv: Dotenv?, key: String): String? {
            return dotenv?.get(key) ?: System.getenv(key)
        }
    }
}
