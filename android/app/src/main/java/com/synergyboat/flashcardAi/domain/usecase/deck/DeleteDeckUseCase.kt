package com.synergyboat.flashcardAi.domain.usecase.deck

import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.DeckRepository

class DeleteDeckUseCase(
    private val repository: DeckRepository
) {
    suspend operator fun invoke(deck: Deck) {
        repository.deleteDeck(deck)
    }
}