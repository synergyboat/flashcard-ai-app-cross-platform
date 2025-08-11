package com.synergyboat.flashcardAi.domain.usecase.deck

import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.DeckRepository
import javax.inject.Inject

class CreateNewDeckUseCase @Inject constructor(
    private val repository: DeckRepository
) {
    suspend operator fun invoke(deck: Deck): Long {

        return if (deck.flashcards.isEmpty())
            repository.createDeck(deck)
        else repository.createDeckWithFlashcards(deck)
    }
}