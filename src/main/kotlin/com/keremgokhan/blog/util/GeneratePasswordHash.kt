package com.keremgokhan.blog.util

import org.mindrot.jbcrypt.BCrypt

fun main(args: Array<String>) {
    if (args.isEmpty()) {
        System.err.println("Usage: ./gradlew hashPassword --args='YOUR_PASSWORD'")
        return
    }

    val password = args.joinToString(" ")
    val hash = BCrypt.hashpw(password, BCrypt.gensalt())

    println(hash)
}
