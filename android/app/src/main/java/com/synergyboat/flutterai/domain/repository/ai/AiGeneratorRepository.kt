package com.synergyboat.flutterai.domain.repository.ai

import com.synergyboat.flutterai.domain.entities.Deck

interface AiGeneratorRepository {
    suspend fun generateDeck(deckId: Int?, prompt: String, count: Int): String
}