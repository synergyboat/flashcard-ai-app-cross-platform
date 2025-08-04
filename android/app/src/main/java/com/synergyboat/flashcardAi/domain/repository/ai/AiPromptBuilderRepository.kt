package com.synergyboat.flashcardAi.domain.repository.ai

interface AiPromptBuilderRepository<T> {
    fun buildPrompt(topic: String, count: Int = 10): T
}