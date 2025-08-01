package com.synergyboat.flashcardAi.domain.repository
import com.synergyboat.flashcardAi.domain.entities.Deck

interface DeckRepository {
    suspend fun getAllDecks(): List<Deck>
    suspend fun createDeck(deck: Deck): Long

    suspend fun createDeckWithFlashcards(deck: Deck): Long

    suspend fun getAllDecksWithFlashcards(): List<Deck>

    suspend fun deleteDeck(id: Long)
    suspend fun updateDeck(deck: Deck): Deck
    suspend fun getDeckById(id: Long): Deck?
}