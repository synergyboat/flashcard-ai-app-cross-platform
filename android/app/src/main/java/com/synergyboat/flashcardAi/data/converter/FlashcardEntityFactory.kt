package com.synergyboat.flashcardAi.data.converter

import android.os.Build
import androidx.annotation.RequiresApi
import com.synergyboat.flashcardAi.data.entities.FlashcardEntity
import com.synergyboat.flashcardAi.domain.entities.Flashcard
import org.json.JSONObject
import java.time.LocalDateTime
import java.util.Date

object FlashcardEntityFactory {

    fun fromFlashcard(flashcard: Flashcard): FlashcardEntity {
        return FlashcardEntity(
            id = flashcard.id,
            question = flashcard.question,
            answer = flashcard.answer,
            deckId = flashcard.deckId,
            createdAt = flashcard.createdAt,
            updatedAt = flashcard.updatedAt
        )
    }

    fun toFlashcard(flashcardEntity: FlashcardEntity): Flashcard {
        return Flashcard(
            id = flashcardEntity.id,
            question = flashcardEntity.question,
            answer = flashcardEntity.answer,
            deckId = flashcardEntity.deckId,
            createdAt = flashcardEntity.createdAt,
            updatedAt = flashcardEntity.updatedAt,
            lastReviewed = flashcardEntity.lastReviewed
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun fromJsonToFlashcard(json: String): Flashcard {

        val jsonObject = JSONObject(json)
        val id: Long? = jsonObject.opt("id")?.let {
            if (it is Number) it.toLong() else null
        }
        val question = jsonObject.optString("question", "")
        val answer = jsonObject.optString("answer", "")
        val deckId = jsonObject.optLong("deckId")
        val createdAt: Date? = jsonObject.optString("createdAt").takeIf { it.isNotEmpty() }?.let {
            LocalDateTime.parse(it).let { dateTime -> Date.from(dateTime.atZone(java.time.ZoneId.systemDefault()).toInstant()) }
        }
        val updatedAt: Date? = jsonObject.optString("updatedAt").takeIf { it.isNotEmpty() }?.let {
            LocalDateTime.parse(it).let { dateTime -> Date.from(dateTime.atZone(java.time.ZoneId.systemDefault()).toInstant()) }
        }

        val lastReviewed: Date? = jsonObject.optString("lastReviewed").takeIf { it.isNotEmpty() }?.let {
            LocalDateTime.parse(it).let { dateTime -> Date.from(dateTime.atZone(java.time.ZoneId.systemDefault()).toInstant()) }
        }

        return Flashcard(
            id = id, // Placeholder, replace with parsed value
            question = question, // Placeholder, replace with parsed value
            answer = answer, // Placeholder, replace with parsed value
            deckId = deckId, // Placeholder, replace with parsed value
            createdAt = createdAt, // Placeholder, replace with parsed value
            updatedAt = updatedAt, // Placeholder, replace with parsed value
            lastReviewed = lastReviewed // Placeholder, replace with parsed value
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun toJson(flashcardEntity: FlashcardEntity): String {
        val jsonObject = JSONObject()
        jsonObject.put("id", flashcardEntity.id)
        jsonObject.put("question", flashcardEntity.question)
        jsonObject.put("answer", flashcardEntity.answer)
        jsonObject.put("deckId", flashcardEntity.deckId)
        jsonObject.put("createdAt", flashcardEntity.createdAt.toString())
        jsonObject.put("updatedAt", flashcardEntity.updatedAt.toString())
        jsonObject.put("lastReviewed", flashcardEntity.lastReviewed?.toString())

        return jsonObject.toString()
    }
}