package com.synergyboat.flashcardAi.data.repository

import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.DeckRepository

/**
 * Implementation of the [DeckRepository] interface.
 * This class is responsible for handling data operations related to decks.
 */
class DeckRepositoryImpl: DeckRepository {
    override suspend fun getAllDecks(): List<Deck> {
        TODO("Not yet implemented")
    }

    override suspend fun createDeck(deck: Deck): Deck {
        TODO("Not yet implemented")
    }

    override suspend fun deleteDeck(id: Int) {
        TODO("Not yet implemented")
    }

    override suspend fun updateDeck(deck: Deck): Deck {
        TODO("Not yet implemented")
    }

    override suspend fun getDeckById(id: Int): Deck? {
        TODO("Not yet implemented")
    }

}