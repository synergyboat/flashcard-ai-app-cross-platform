package com.synergyboat.flashcardAi.domain.usecase.deck

import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.DeckRepository

class UpdateDeckDetailsUseCase(
    private val repository: DeckRepository
) {
    suspend operator fun invoke(updatedDeck: Deck) {
        repository.updateDeck(updatedDeck)
    }
}