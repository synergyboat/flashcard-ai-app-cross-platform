package com.synergyboat.flashcardAi.data.entities


import androidx.room.*
import java.util.*

@Entity(
    tableName = "flashcard",
    foreignKeys = [
        ForeignKey(
            entity = DeckEntity::class,
            parentColumns = ["id"],
            childColumns = ["deckId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["deckId"])]
)
data class FlashcardEntity(
    @PrimaryKey(autoGenerate = true) val id: Int? = null,
    val deckId: Int?,
    val question: String,
    val answer: String,
    val createdAt: Date? = null,
    val updatedAt: Date? = null,
    val lastReviewed: Date? = null
)