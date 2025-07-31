package com.synergyboat.flashcardAi.core.di

import com.aallam.openai.api.chat.ChatCompletionRequest
import com.synergyboat.flashcardAi.data.repository.DeckRepositoryImpl
import com.synergyboat.flashcardAi.data.repository.ai.AiGeneratorRepositoryImpl
import com.synergyboat.flashcardAi.data.repository.ai.AiPromptBuilderRepositoryImpl
import com.synergyboat.flashcardAi.domain.repository.DeckRepository
import com.synergyboat.flashcardAi.domain.repository.FlashcardRepository
import com.synergyboat.flashcardAi.domain.repository.ai.AiGeneratorRepository
import com.synergyboat.flashcardAi.domain.repository.ai.AiPromptBuilderRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class DomainDependencyModule {
    // This module is currently empty, but can be used to provide application-wide dependencies in the future.
    // For example, you could provide a logger, a network client, or any other singleton dependencies here.

    @Binds
    @Singleton
    abstract fun bindDeckRepository(
        impl: DeckRepositoryImpl
    ): DeckRepository

    @Binds
    @Singleton
    abstract fun bindAiGeneratorRepository(
        impl: AiGeneratorRepositoryImpl
    ): AiGeneratorRepository

    @Binds
    @Singleton
    abstract fun bindAiPromptBuilderRepository(
        impl: AiPromptBuilderRepositoryImpl
    ): AiPromptBuilderRepository<ChatCompletionRequest>

}