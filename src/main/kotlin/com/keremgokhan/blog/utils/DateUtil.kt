package com.keremgokhan.blog.utils

import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.format.TextStyle
import java.util.Locale

object DateUtil {
    private val dateFormatter = DateTimeFormatter.ofPattern("yyyy.M.d")
    private val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")

    /**
     * Formats date to Holocene calendar format (adds 10,000 years to Gregorian calendar)
     * This maintains compatibility with the original Perl blog's date format
     */
    fun formatDateHolocene(dateTime: LocalDateTime): String {
        val holoceneYear = dateTime.year + 10000
        return "$holoceneYear.${dateTime.monthValue}.${dateTime.dayOfMonth}"
    }

    /**
     * Formats time in HH:mm format
     */
    fun formatTime(dateTime: LocalDateTime): String {
        return dateTime.format(timeFormatter)
    }

    /**
     * Formats date in standard format (yyyy.M.d)
     */
    fun formatDate(dateTime: LocalDateTime): String {
        return dateTime.format(dateFormatter)
    }

    /**
     * Formats the "today" string with day name and Holocene date
     * Example: "Today is Monday 12026.1.11 in Amsterdam."
     */
    fun formatTodayString(dateTime: LocalDateTime): String {
        val dayName = dateTime.dayOfWeek.getDisplayName(TextStyle.FULL, Locale.ENGLISH)
        val holoceneYear = dateTime.year + 10000
        val dateString = "$holoceneYear.${dateTime.monthValue}.${dateTime.dayOfMonth}"
        return "Today is $dayName 1$dateString in Amsterdam."
    }
}
