package com.synergyboat.flashcardAi.data.converter
import android.os.Build
import androidx.annotation.RequiresApi
import com.synergyboat.flashcardAi.data.entities.DeckEntity
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.entities.Flashcard
import org.json.JSONObject
import java.time.LocalDateTime
import java.util.Date

object DeckEntityFactory {
    fun fromDeck(deck: Deck): DeckEntity {
        return DeckEntity(
            id = deck.id,
            name = deck.name,
            description = deck.description,
            createdAt = deck.createdAt,
            updatedAt = deck.updatedAt
        )
    }

    fun toDeck(deckEntity: DeckEntity): Deck {
        return Deck(
            id = deckEntity.id,
            name = deckEntity.name,
            description = deckEntity.description,
            createdAt = deckEntity.createdAt,
            updatedAt = deckEntity.updatedAt
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun fromJsonToDeck(json: String): Deck {
        val jsonObject = JSONObject(json)

        val id: Long? = jsonObject.opt("id")?.let {
            if (it is Number) it.toLong() else null
        }
        val name = jsonObject.optString("name", "")
        val description = jsonObject.optString("description", "")

        val createdAt: Date? = jsonObject.optString("createdAt").takeIf { it.isNotEmpty() }?.let {
            LocalDateTime.parse(it).let { dateTime -> Date.from(dateTime.atZone(java.time.ZoneId.systemDefault()).toInstant()) }
        }
        val updatedAt: Date? = jsonObject.optString("updatedAt").takeIf { it.isNotEmpty() }?.let {
            LocalDateTime.parse(it).let { dateTime -> Date.from(dateTime.atZone(java.time.ZoneId.systemDefault()).toInstant()) }
        }

        val flashcardsJsonArray = jsonObject.optJSONArray("flashcards")
        val flashcards = mutableListOf<Flashcard>()

        if (flashcardsJsonArray != null) {
            for (i in 0 until flashcardsJsonArray.length()) {
                val flashcardJson = flashcardsJsonArray.getJSONObject(i).toString()
                flashcards.add(FlashcardEntityFactory.fromJsonToFlashcard(flashcardJson))
            }
        }

        return Deck(
            id = id,
            name = name,
            description = description,
            createdAt = createdAt,
            updatedAt = updatedAt,
            flashcards = flashcards
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun toJson(deckEntity: DeckEntity): String {
        val jsonObject = JSONObject()
        jsonObject.put("id", deckEntity.id)
        jsonObject.put("name", deckEntity.name)
        jsonObject.put("description", deckEntity.description)
        jsonObject.put("createdAt", deckEntity.createdAt.toString())
        jsonObject.put("updatedAt", deckEntity.updatedAt.toString())

        return jsonObject.toString()
    }

}