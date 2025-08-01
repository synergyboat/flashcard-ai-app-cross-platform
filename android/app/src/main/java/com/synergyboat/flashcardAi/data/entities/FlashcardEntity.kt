package com.synergyboat.flashcardAi.data.entities


import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import java.util.Date

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
    @PrimaryKey(autoGenerate = true) val id: Long? = null,
    val deckId: Long? = null,
    val question: String = "",
    val answer: String = "",
    val createdAt: Date? = null,
    val updatedAt: Date? = null,
    val lastReviewed: Date? = null
)