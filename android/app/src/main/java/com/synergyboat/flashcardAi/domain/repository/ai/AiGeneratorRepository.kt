package com.synergyboat.flashcardAi.domain.repository.ai

interface AiGeneratorRepository {
    suspend fun generateDeck(deckId: Long?, prompt: String, count: Int): String
}