package com.synergyboat.flashcardAi.domain.repository.ai

interface AiGeneratorRepository {
    suspend fun generateDeck(deckId: Int?, prompt: String, count: Int): String
}