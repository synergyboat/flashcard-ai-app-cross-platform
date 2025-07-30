package com.synergyboat.flashcardAi.core.benchmark

import java.util.logging.Logger
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.system.measureTimeMillis

@Singleton
class ExecutionLogger @Inject constructor(
    private val logger: Logger
) {
    suspend fun <T> logExecDuration(
        action: suspend () -> T,
        name: String = "no_name",
        tag: String = "no_tag",
        log: Boolean = true
    ): T {
        var result: T
        val elapsedTime = measureTimeMillis {
            result = action()
        }

        if (log) {
            logger.info("$tag | Execution time for $name: $elapsedTime ms")
        }

        return result
    }
}