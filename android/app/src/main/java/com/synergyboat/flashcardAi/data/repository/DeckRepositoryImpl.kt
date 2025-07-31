package com.synergyboat.flashcardAi.data.repository

import com.synergyboat.flashcardAi.data.dao.DeckDao
import com.synergyboat.flashcardAi.data.services.database.RoomsDatabase
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.DeckRepository
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Implementation of the [DeckRepository] interface.
 * This class is responsible for handling data operations related to decks.
 */
@Singleton
class DeckRepositoryImpl @Inject constructor(val deckDao: DeckDao): DeckRepository {
    override suspend fun getAllDecks(): List<Deck> {
        TODO("Not yet implemented")
    }

    override suspend fun createDeck(deck: Deck): Deck {
        // TODO("Not yet implemented")
        return deck
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