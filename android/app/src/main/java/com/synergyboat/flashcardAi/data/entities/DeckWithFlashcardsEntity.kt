package com.synergyboat.flashcardAi.data.entities

import androidx.room.Embedded
import androidx.room.Relation

data class DeckWithFlashcardsEntity(
    @Embedded val deck: DeckEntity,
    @Relation(
        parentColumn = "id",
        entityColumn = "deckId"
    )
    val flashcards: List<FlashcardEntity>
)