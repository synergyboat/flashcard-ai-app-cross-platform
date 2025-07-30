package com.synergyboat.flashcardAi.domain.usecase

import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.DeckRepository

class CreateNewDeckUseCase(
    private val repository: DeckRepository
) {
    suspend operator fun invoke(deck: Deck): Deck {
        return repository.createDeck(deck)
    }
}