package com.synergyboat.flutterai.domain.usecase

import com.synergyboat.flutterai.domain.entities.Deck
import com.synergyboat.flutterai.domain.repository.DeckRepository

class CreateNewDeckUseCase(
    private val repository: DeckRepository
) {
    suspend operator fun invoke(deck: Deck): Deck {
        return repository.createDeck(deck)
    }
}