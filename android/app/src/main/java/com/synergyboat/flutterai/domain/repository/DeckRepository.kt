package com.synergyboat.flutterai.domain.repository
import com.synergyboat.flutterai.domain.entities.Deck

interface DeckRepository {
    suspend fun getAllDecks(): List<Deck>
    suspend fun createDeck(deck: Deck): Deck
    suspend fun deleteDeck(id: Int)
    suspend fun updateDeck(deck: Deck): Deck
    suspend fun getDeckById(id: Int): Deck?
}