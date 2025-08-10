package com.synergyboat.flashcardAi.domain.repository

import com.synergyboat.flashcardAi.domain.entities.Flashcard

interface FlashcardRepository {
    suspend fun createFlashcard(flashcard: Flashcard): Long
    suspend fun getFlashcardsByDeck(deckId: Long): List<Flashcard>
    suspend fun deleteFlashcard(flashcard: Flashcard)
    suspend fun updateFlashcard(flashcard: Flashcard)
    suspend fun getFlashcardById(id: Long): Flashcard?
}