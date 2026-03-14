package com.keremgokhan.blog.services

import com.keremgokhan.blog.models.Post
import com.keremgokhan.blog.models.PostWithAuthor
import com.keremgokhan.blog.models.Posts
import com.keremgokhan.blog.models.Users
import mu.KotlinLogging
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import java.time.LocalDateTime

private val logger = KotlinLogging.logger {}

class PostService {
    fun getAllPosts(): List<PostWithAuthor> = transaction {
        (Posts innerJoin Users)
            .selectAll()
            .where { Posts.status eq "published" }
            .orderBy(Posts.created, SortOrder.DESC)
            .map { row -> rowToPostWithAuthor(row) }
    }

    fun getPostsByStatus(status: String): List<PostWithAuthor> = transaction {
        (Posts innerJoin Users)
            .selectAll()
            .where { Posts.status eq status }
            .orderBy(Posts.created, SortOrder.DESC)
            .map { row -> rowToPostWithAuthor(row) }
    }

    fun getPostById(id: Int): PostWithAuthor? = transaction {
        (Posts innerJoin Users)
            .selectAll()
            .where { Posts.id eq id }
            .map { row -> rowToPostWithAuthor(row) }
            .singleOrNull()
    }

    fun createPost(title: String, body: String, authorId: Int, status: String = "published"): Post? = transaction {
        val id = Posts.insert {
            it[Posts.title] = title
            it[Posts.body] = body
            it[Posts.authorId] = authorId
            it[Posts.status] = status
            it[created] = LocalDateTime.now()
        } get Posts.id

        Posts.selectAll()
            .where { Posts.id eq id }
            .map { row ->
                Post(
                    id = row[Posts.id].value,
                    title = row[Posts.title],
                    body = row[Posts.body],
                    authorId = row[Posts.authorId].value,
                    created = row[Posts.created],
                    status = row[Posts.status]
                )
            }
            .singleOrNull()
    }

    fun updatePost(id: Int, title: String, body: String, status: String? = null): Boolean = transaction {
        Posts.update({ Posts.id eq id }) {
            it[Posts.title] = title
            it[Posts.body] = body
            if (status != null) it[Posts.status] = status
        } > 0
    }

    fun setStatus(id: Int, status: String): Boolean = transaction {
        Posts.update({ Posts.id eq id }) {
            it[Posts.status] = status
        } > 0
    }

    fun deletePost(id: Int): Boolean = transaction {
        Posts.deleteWhere(op = { Posts.id eq id }) > 0
    }

    private fun rowToPostWithAuthor(row: ResultRow) = PostWithAuthor(
        id = row[Posts.id].value,
        title = row[Posts.title],
        body = row[Posts.body],
        author = row[Users.name],
        created = row[Posts.created],
        status = row[Posts.status]
    )
}
