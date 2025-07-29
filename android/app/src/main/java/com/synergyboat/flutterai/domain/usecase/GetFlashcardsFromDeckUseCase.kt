package com.synergyboat.flutterai.domain.usecase

import com.synergyboat.flutterai.domain.entities.Flashcard
import com.synergyboat.flutterai.domain.repository.FlashcardRepository

class GetFlashcardsFromDeckUseCase(
    private val repository: FlashcardRepository
) {
    suspend operator fun invoke(deckId: Int): List<Flashcard> {
        return repository.getFlashcardsByDeck(deckId)
    }
}