package com.synergyboat.flashcardAi.data.dao

import androidx.room.*
import com.synergyboat.flashcardAi.data.entities.DeckEntity

@Dao
interface DeckDao {

    @Query("SELECT * FROM deck WHERE id = :deckId")
    suspend fun getDeckById(deckId: Int): DeckEntity?

    @Insert
    suspend fun createDeck(deck: DeckEntity): Long

    @Query("SELECT * FROM deck")
    suspend fun getAllDecks(): List<DeckEntity>

    @Update
    suspend fun updateDeck(deck: DeckEntity)

    @Delete
    suspend fun deleteDeck(deck: DeckEntity)

    @Query("DELETE FROM deck WHERE id = :deckId")
    suspend fun deleteDeckById(deckId: Int)
}