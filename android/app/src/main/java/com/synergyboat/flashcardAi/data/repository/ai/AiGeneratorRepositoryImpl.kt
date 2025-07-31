package com.synergyboat.flashcardAi.data.repository.ai

import android.os.Build
import androidx.annotation.RequiresApi
import com.aallam.openai.api.chat.ChatCompletionRequest
import com.synergyboat.flashcardAi.data.converter.DeckEntityFactory
import com.synergyboat.flashcardAi.data.services.openai.OpenAIService
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.ai.AiPromptBuilderRepository
import javax.inject.Inject

class AiGeneratorRepositoryImpl @Inject constructor(
    private val aiPromptBuilderRepository: AiPromptBuilderRepository<ChatCompletionRequest>,
    private val openAIService: OpenAIService
) {

    @RequiresApi(Build.VERSION_CODES.O)
    suspend fun generateDeck(topic: String, count: Int = 10): Deck {
        val chatCompletionRequest = aiPromptBuilderRepository.buildPrompt(topic, count)
        val jsonString = openAIService.getChatResponseJson(chatCompletionRequest)
        return DeckEntityFactory.fromJsonToDeck(jsonString)
    }

}