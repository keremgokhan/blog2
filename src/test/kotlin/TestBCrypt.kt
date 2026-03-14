package com.keremgokhan.blog

import org.junit.jupiter.api.Test
import org.mindrot.jbcrypt.BCrypt

class TestBCrypt {
    @Test
    fun testHash() {
        val password = "test123"
        val storedHash = "\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy"

        println("Testing BCrypt verification:")
        println("Password: $password")
        println("Stored hash: $storedHash")
        println("Verification result: ${BCrypt.checkpw(password, storedHash)}")

        // Generate a fresh hash
        val freshHash = BCrypt.hashpw(password, BCrypt.gensalt())
        println("\nFresh hash for '$password': $freshHash")
        println("Fresh hash verification: ${BCrypt.checkpw(password, freshHash)}")
    }
}
