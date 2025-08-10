package com.synergyboat.flashcardAi.domain.usecase.flashcard

import com.synergyboat.flashcardAi.domain.entities.Flashcard
import com.synergyboat.flashcardAi.domain.repository.FlashcardRepository

class UpdateFlashcardUseCase(
    private val repository: FlashcardRepository
) {
    suspend operator fun invoke(updatedFlashcard: Flashcard) {
        repository.updateFlashcard(updatedFlashcard)
    }
}