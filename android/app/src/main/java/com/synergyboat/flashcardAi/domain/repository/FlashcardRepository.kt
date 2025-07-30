package com.synergyboat.flashcardAi.domain.repository

import com.synergyboat.flashcardAi.domain.entities.Flashcard

interface FlashcardRepository {
    suspend fun createFlashcard(flashcard: Flashcard): Flashcard
    suspend fun getFlashcardsByDeck(deckId: Int): List<Flashcard>
    suspend fun deleteFlashcard(id: Int)
    suspend fun updateFlashcard(flashcard: Flashcard): Flashcard
    suspend fun getFlashcardById(id: Int): Flashcard?
}