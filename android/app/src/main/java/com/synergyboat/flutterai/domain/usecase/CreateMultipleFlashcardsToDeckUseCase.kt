package com.synergyboat.flutterai.domain.usecase

import com.synergyboat.flutterai.domain.entities.Flashcard
import com.synergyboat.flutterai.domain.repository.FlashcardRepository

class CreateMultipleFlashcardsToDeckUseCase(
    private val repository: FlashcardRepository
) {
    suspend operator fun invoke(flashcards: List<Flashcard>): List<Flashcard> {
        return flashcards.map { repository.createFlashcard(it) }
    }
}