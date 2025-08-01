package com.synergyboat.flashcardAi.data.dao


import androidx.room.*
import com.synergyboat.flashcardAi.data.entities.FlashcardEntity

@Dao
interface FlashcardDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun createFlashcard(flashcard: FlashcardEntity): Long

    @Query("SELECT * FROM flashcard WHERE deckId = :deckId")
    suspend fun getAllFlashcardsFromDeckId(deckId: Long): List<FlashcardEntity>

    @Update
    suspend fun updateFlashcard(flashcard: FlashcardEntity)

    @Delete
    suspend fun deleteFlashcard(flashcard: FlashcardEntity)

    @Query("DELETE FROM flashcard WHERE id = :flashcardId")
    suspend fun deleteFlashcardById(flashcardId: Long)
}