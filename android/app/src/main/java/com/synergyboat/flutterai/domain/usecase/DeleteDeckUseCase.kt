package com.synergyboat.flutterai.domain.usecase

import com.synergyboat.flutterai.domain.repository.DeckRepository

class DeleteDeckUseCase(
    private val repository: DeckRepository
) {
    suspend operator fun invoke(deckId: Int) {
        repository.deleteDeck(deckId)
    }
}