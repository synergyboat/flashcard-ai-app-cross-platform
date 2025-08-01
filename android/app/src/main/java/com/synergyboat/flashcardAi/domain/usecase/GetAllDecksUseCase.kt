package com.synergyboat.flashcardAi.domain.usecase

import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.DeckRepository

class GetAllDecksUseCase(
    private val repository: DeckRepository
) {
    suspend operator fun invoke(): List<Deck> {
        return repository.getAllDecksWithFlashcards()
    }
}