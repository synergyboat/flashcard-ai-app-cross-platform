package com.synergyboat.flashcardAi.domain.repository.ai

import com.synergyboat.flashcardAi.domain.entities.Deck

interface AiGeneratorRepository {
    suspend fun generateDeck(deckId: Long?, topic: String, count: Int): Deck
}