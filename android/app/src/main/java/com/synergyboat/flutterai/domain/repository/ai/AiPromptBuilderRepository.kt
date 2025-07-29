package com.synergyboat.flutterai.domain.repository.ai

interface AiPromptBuilderRepository {
    fun buildPrompt(topic: String, level: String = "beginner"): String
}