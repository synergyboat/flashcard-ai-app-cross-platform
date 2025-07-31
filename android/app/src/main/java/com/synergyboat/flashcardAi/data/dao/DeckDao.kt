package com.synergyboat.flashcardAi.data.dao

import androidx.room.*
import com.synergyboat.flashcardAi.data.entities.DeckEntity
import com.synergyboat.flashcardAi.data.entities.DeckWithFlashcardsEntity
import com.synergyboat.flashcardAi.data.entities.FlashcardEntity

@Dao
interface DeckDao {

    @Query("SELECT * FROM deck WHERE id = :deckId")
    suspend fun getDeckById(deckId: Long): DeckEntity?

    @Insert
    suspend fun createDeck(deck: DeckEntity): Long

    @Query("SELECT * FROM deck")
    suspend fun getAllDecks(): List<DeckEntity>

    @Update
    suspend fun updateDeck(deck: DeckEntity)

    @Delete
    suspend fun deleteDeck(deck: DeckEntity)

    @Query("DELETE FROM deck WHERE id = :deckId")
    suspend fun deleteDeckById(deckId: Long)

    @Insert
    suspend fun addMultipleFlashcardsToDeck(flashcards: List<FlashcardEntity>)

    @Transaction
    suspend fun createDeckWithFlashcards(
        deck: DeckEntity,
        flashcards: List<FlashcardEntity>
    ): Long {
        val deckId: Long = createDeck(deck)
        val updatedFlashcards = flashcards.map { it.copy(deckId = deckId) }
        addMultipleFlashcardsToDeck(updatedFlashcards)
        return deckId
    }

    @Transaction
    @Query("SELECT * FROM deck")
    suspend fun getAllDeckWithFlashcards(): List<DeckWithFlashcardsEntity>

    @Transaction
    @Query("SELECT * FROM deck WHERE id = :deckId")
    suspend fun getDeckWithFlashcards(deckId: Int): List<DeckWithFlashcardsEntity>
}