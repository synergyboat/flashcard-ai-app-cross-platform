package com.synergyboat.flashcardAi.core.benchmark

import kotlinx.serialization.json.Json
import java.nio.charset.Charset


object RowSizeBenchmark {
    inline fun <reified T> getRowSizeInBytes(row: T): Int {
        val jsonString = Json.encodeToString(row)
        val bytes = jsonString.toByteArray(Charset.forName("UTF-8"))
        return bytes.size
    }

    inline fun <reified T> getRowSizeInKB(row: T): Double {
        return getRowSizeInBytes(row) / 1024.0
    }
}