package com.synergyboat.flashcardAi.domain.usecase.ai

import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.ai.AiGeneratorRepository

class GenerateDeckWithAIUseCase(
    private val repository: AiGeneratorRepository
) {
    suspend operator fun invoke(
        deckId: Long? = null,
        count: Int = 10,
        prompt: String = ""
    ): Deck {
        return repository.generateDeck(deckId = deckId, count = count, topic = prompt)
    }
}