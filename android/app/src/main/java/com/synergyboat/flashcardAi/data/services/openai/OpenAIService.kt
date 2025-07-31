package com.synergyboat.flashcardAi.data.services.openai

import com.aallam.openai.api.chat.ChatCompletion
import com.aallam.openai.api.chat.ChatCompletionRequest
import com.aallam.openai.client.OpenAI
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class OpenAIService @Inject constructor (
    private val openAI: OpenAI
) {
    fun getOpenAI(): OpenAI {
        return openAI
    }

    suspend fun getChatCompletion(chatCompletionRequest: ChatCompletionRequest): ChatCompletion {
        return openAI.chatCompletion(chatCompletionRequest)
    }

    fun getJsonFromResponse(chatCompletion: ChatCompletion): String {
        return chatCompletion.choices.firstOrNull()?.message?.content ?: ""
    }

    suspend fun getChatResponseJson(chatCompletionRequest: ChatCompletionRequest): String {
        val chatCompletion = getChatCompletion(chatCompletionRequest)
        return getJsonFromResponse(chatCompletion)
    }
}