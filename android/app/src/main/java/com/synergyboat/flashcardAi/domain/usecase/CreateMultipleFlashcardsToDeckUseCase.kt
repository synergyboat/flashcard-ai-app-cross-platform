package com.synergyboat.flashcardAi.domain.usecase

import com.synergyboat.flashcardAi.domain.entities.Flashcard
import com.synergyboat.flashcardAi.domain.repository.FlashcardRepository

class CreateMultipleFlashcardsToDeckUseCase(
    private val repository: FlashcardRepository
) {
    suspend operator fun invoke(flashcards: List<Flashcard>): List<Long> {
        return flashcards.map {
            repository.createFlashcard(it) }
    }
}