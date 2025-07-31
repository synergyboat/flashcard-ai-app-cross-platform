package com.synergyboat.flashcardAi.data.repository.ai

import com.aallam.openai.api.chat.ChatCompletionRequest
import com.aallam.openai.api.chat.ChatMessage
import com.aallam.openai.api.chat.ChatRole
import com.aallam.openai.api.model.ModelId
import com.synergyboat.flashcardAi.core.Constants
import com.synergyboat.flashcardAi.domain.repository.ai.AiPromptBuilderRepository

class AiPromptGeneratorRepositoryImpl: AiPromptBuilderRepository<ChatCompletionRequest> {
    override fun buildPrompt(topic: String, count: Int): ChatCompletionRequest {
        return ChatCompletionRequest(
            model = ModelId("gpt-3.5-turbo"),
            messages = listOf(
                ChatMessage(
                    role = ChatRole.System,
                    content = Constants.PROMPT
                ),
                ChatMessage(
                    role = ChatRole.User,
                    content = "Generate flashcards for the topic: '$topic'.\n Number of cards to generate: '$count'."
                )
            )
        )
    }
}