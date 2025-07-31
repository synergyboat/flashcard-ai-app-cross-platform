package com.synergyboat.flashcardAi.domain.usecase

import com.synergyboat.flashcardAi.domain.repository.DeckRepository

class DeleteDeckUseCase(
    private val repository: DeckRepository
) {
    suspend operator fun invoke(deckId: Long) {
        repository.deleteDeck(deckId)
    }
}