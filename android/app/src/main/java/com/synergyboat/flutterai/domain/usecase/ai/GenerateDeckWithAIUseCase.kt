package com.synergyboat.flutterai.domain.usecase.ai

import com.synergyboat.flutterai.domain.entities.Deck
import com.synergyboat.flutterai.domain.repository.ai.AiGeneratorRepository
import kotlinx.serialization.builtins.serializer
import kotlinx.serialization.json.Json

class GenerateDeckWithAIUseCase(
    private val repository: AiGeneratorRepository
) {
    suspend operator fun invoke(
        deckId: Int? = null,
        count: Int = 10,
        prompt: String = ""
    ): Deck {
        val response: String? = repository.generateDeck(deckId = deckId, count = count, prompt = prompt)

        // You can replace this with proper serialization logic
        return if (response != null) {
            decodeDeckFromJson(response)
        } else {
            throw IllegalStateException("AI generation failed: null response")
        }
    }

    private fun decodeDeckFromJson(json: String): Deck {
        return Json.decodeFromString(Deck.serializer(),json)
    }
}