package com.synergyboat.flashcardAi.data.repository

import com.synergyboat.flashcardAi.data.converter.DeckEntityFactory
import com.synergyboat.flashcardAi.data.converter.FlashcardEntityFactory
import com.synergyboat.flashcardAi.data.dao.DeckDao
import com.synergyboat.flashcardAi.data.entities.DeckWithFlashcardsEntity
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
        return deckDao.getAllDecks().map { DeckEntityFactory.toDeck(it) }
    }

    override suspend fun createDeck(deck: Deck): Long {
        // TODO("Not yet implemented")
        return 0
    }

    override suspend fun createDeckWithFlashcards(deck: Deck): Long {
        return deckDao.createDeckWithFlashcards(
            DeckEntityFactory.fromDeck(deck),
            deck.flashcards.map { FlashcardEntityFactory.fromFlashcard(it) }
        )
    }

    override suspend fun getAllDecksWithFlashcards(): List<Deck> {
        val decksWithFlashcardsEntity: List<DeckWithFlashcardsEntity> = deckDao.getAllDecksWithFlashcards()
        return decksWithFlashcardsEntity.map { deckWithFlashcardsEntity ->
            DeckEntityFactory.toDeck(deckWithFlashcardsEntity.deck).apply {
                flashcards = deckWithFlashcardsEntity.flashcards.map { FlashcardEntityFactory.toFlashcard(it) }
            }
        }
    }

    override suspend fun deleteDeck(id: Long) {
        TODO("Not yet implemented")
    }

    override suspend fun updateDeck(deck: Deck): Deck {
        TODO("Not yet implemented")
    }

    override suspend fun getDeckById(id: Long): Deck? {
        TODO("Not yet implemented")
    }

}