package com.synergyboat.flashcardAi.core.benchmark

import java.util.logging.Logger
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class DbSizeLogger @Inject constructor(
    private val logger: Logger
) {

    fun logDbRowSize(
        row: Map<String, Any?>,
        name: String = "",
        tag: String = "db_row_size",
        log: Boolean = true
    ) {
        val sizeInBytes = RowSizeBenchmark.getRowSizeInBytes(row)
        val sizeInKB = RowSizeBenchmark.getRowSizeInKB(row)

        if (log) {
            logger.info("$tag | Row size for $name: $sizeInBytes bytes (${String.format("%.2f", sizeInKB)} KB)")
        }
    }

    fun logTotalDbRowSize(
        rows: List<Map<String, Any?>>,
        name: String = "",
        tag: String = "db_row_size",
        log: Boolean = true
    ) {
        val totalSizeInBytes = rows.sumOf { RowSizeBenchmark.getRowSizeInBytes(it) }
        val totalSizeInKB = totalSizeInBytes / 1024.0

        if (log) {
            logger.info("$tag | Total row size for $name: $totalSizeInBytes bytes (${String.format("%.2f", totalSizeInKB)} KB)")
        }
    }
}