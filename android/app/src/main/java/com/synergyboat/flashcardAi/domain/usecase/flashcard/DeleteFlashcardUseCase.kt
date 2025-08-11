package com.synergyboat.flashcardAi.domain.usecase.flashcard

import com.synergyboat.flashcardAi.domain.entities.Flashcard
import com.synergyboat.flashcardAi.domain.repository.FlashcardRepository

class DeleteFlashcardUseCase(
    private val repository: FlashcardRepository
) {
    suspend operator fun invoke(flashcard: Flashcard) {
        repository.deleteFlashcard(flashcard)
    }
}