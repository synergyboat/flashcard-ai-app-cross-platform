package com.synergyboat.flashcardAi.domain.usecase

import com.synergyboat.flashcardAi.domain.entities.Flashcard
import com.synergyboat.flashcardAi.domain.repository.FlashcardRepository

class GetFlashcardsFromDeckUseCase(
    private val repository: FlashcardRepository
) {
    suspend operator fun invoke(deckId: Long): List<Flashcard> {
        return repository.getFlashcardsByDeck(deckId)
    }
}