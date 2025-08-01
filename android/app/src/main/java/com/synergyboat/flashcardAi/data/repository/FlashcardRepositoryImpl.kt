package com.synergyboat.flashcardAi.data.repository

import com.synergyboat.flashcardAi.data.converter.FlashcardEntityFactory
import com.synergyboat.flashcardAi.data.dao.FlashcardDao
import com.synergyboat.flashcardAi.domain.entities.Flashcard
import com.synergyboat.flashcardAi.domain.repository.FlashcardRepository
import java.util.logging.Logger
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FlashcardRepositoryImpl @Inject constructor(
    private val flashcardDao: FlashcardDao,
    private val logger: Logger
) : FlashcardRepository {
    override suspend fun createFlashcard(flashcard: Flashcard): Long {
        return flashcardDao.createFlashcard(FlashcardEntityFactory.fromFlashcard(flashcard))
    }

    override suspend fun getFlashcardsByDeck(deckId: Long): List<Flashcard> {
        return flashcardDao.getAllFlashcardsFromDeckId(deckId)
            .map { FlashcardEntityFactory.toFlashcard(it) }
            .also { logger.info("Retrieved ${it.size} flashcards for deck ID $deckId") }
    }

    override suspend fun deleteFlashcard(id: Long) {
        TODO("Not yet implemented")
    }

    override suspend fun updateFlashcard(flashcard: Flashcard): Flashcard {
        TODO("Not yet implemented")
    }

    override suspend fun getFlashcardById(id: Long): Flashcard? {
        TODO("Not yet implemented")
    }
}