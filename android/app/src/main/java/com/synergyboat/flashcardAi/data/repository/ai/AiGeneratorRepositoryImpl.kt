package com.synergyboat.flashcardAi.data.repository.ai

import android.os.Build
import androidx.annotation.RequiresApi
import com.aallam.openai.api.chat.ChatCompletionRequest
import com.synergyboat.flashcardAi.data.converter.DeckEntityFactory
import com.synergyboat.flashcardAi.data.services.openai.OpenAIService
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.ai.AiGeneratorRepository
import com.synergyboat.flashcardAi.domain.repository.ai.AiPromptBuilderRepository
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AiGeneratorRepositoryImpl @Inject constructor(
    private val aiPromptBuilderRepository: AiPromptBuilderRepository<ChatCompletionRequest>,
    private val openAIService: OpenAIService
): AiGeneratorRepository {

    @RequiresApi(Build.VERSION_CODES.O)
    override suspend fun generateDeck(
        deckId: Long?,
        topic: String,
        count: Int
    ): Deck {
        val chatCompletionRequest = aiPromptBuilderRepository.buildPrompt(topic, count)
        val jsonString = openAIService.getChatResponseJson(chatCompletionRequest)
        return DeckEntityFactory.fromJsonToDeck(jsonString)
    }

}