package com.synergyboat.flashcardAi.core.di

import com.aallam.openai.api.chat.ChatCompletionRequest
import com.synergyboat.flashcardAi.data.repository.DeckRepositoryImpl
import com.synergyboat.flashcardAi.data.repository.FlashcardRepositoryImpl
import com.synergyboat.flashcardAi.data.repository.ai.AiGeneratorRepositoryImpl
import com.synergyboat.flashcardAi.data.repository.ai.AiPromptBuilderRepositoryImpl
import com.synergyboat.flashcardAi.domain.repository.DeckRepository
import com.synergyboat.flashcardAi.domain.repository.FlashcardRepository
import com.synergyboat.flashcardAi.domain.repository.ai.AiGeneratorRepository
import com.synergyboat.flashcardAi.domain.repository.ai.AiPromptBuilderRepository
import com.synergyboat.flashcardAi.domain.usecase.deck.CreateMultipleFlashcardsToDeckUseCase
import com.synergyboat.flashcardAi.domain.usecase.deck.CreateNewDeckUseCase
import com.synergyboat.flashcardAi.domain.usecase.deck.DeleteDeckUseCase
import com.synergyboat.flashcardAi.domain.usecase.deck.GetAllDecksUseCase
import com.synergyboat.flashcardAi.domain.usecase.flashcard.GetFlashcardsFromDeckUseCase
import com.synergyboat.flashcardAi.domain.usecase.ai.GenerateDeckWithAIUseCase
import com.synergyboat.flashcardAi.domain.usecase.deck.UpdateDeckDetailsUseCase
import com.synergyboat.flashcardAi.domain.usecase.flashcard.DeleteFlashcardUseCase
import com.synergyboat.flashcardAi.domain.usecase.flashcard.UpdateFlashcardUseCase
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * This module is responsible for providing domain layer dependencies.
 * It binds the repository implementations to their respective interfaces
 * and provides use cases that interact with these repositories.
 */
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryImplModule {
    @Binds
    @Singleton
    abstract fun bindDeckRepository(
        impl: DeckRepositoryImpl
    ): DeckRepository

    @Binds
    @Singleton
    abstract fun bindFlashcardRepository(
        impl: FlashcardRepositoryImpl
    ): FlashcardRepository

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

/**
 * This module provides use cases that encapsulate business logic
 * and interact with the repositories to perform operations.
 */
@Module
@InstallIn(SingletonComponent::class)
object UseCaseDependencyModule {
    @Provides
    @Singleton
    fun providesCreateMultipleFlashcardsToDeckUseCase(
        flashcardRepository: FlashcardRepository,
    ) = CreateMultipleFlashcardsToDeckUseCase(
        repository = flashcardRepository
    )

    @Provides
    @Singleton
    fun providesCreateNewDeckUseCase(
        deckRepository: DeckRepository
    ) = CreateNewDeckUseCase(
        repository = deckRepository
    )

    @Provides
    @Singleton
    fun providesDeleteDeckUseCase(
        deckRepository: DeckRepository
    ) = DeleteDeckUseCase(
        repository = deckRepository
    )

    @Provides
    @Singleton
    fun providesGetAllDecksUseCase(
        deckRepository: DeckRepository
    ) = GetAllDecksUseCase(
        repository = deckRepository
    )

    @Provides
    @Singleton
    fun providesGetFlashcardsFromDeckUseCase(
        flashcardRepository: FlashcardRepository
    ) = GetFlashcardsFromDeckUseCase(
        repository = flashcardRepository
    )

    @Provides
    @Singleton
    fun providesGenerateDeckWithAIUseCase(
        aiGeneratorRepository: AiGeneratorRepository,
    ) = GenerateDeckWithAIUseCase(
        repository = aiGeneratorRepository
    )

    @Provides
    @Singleton
    fun providesDeleteFlashcardUseCase(
        flashcardRepository: FlashcardRepository
    ) = DeleteFlashcardUseCase(
        repository = flashcardRepository
    )

    @Provides
    @Singleton
    fun providesUpdateDeckDetailsUseCase(
        deckRepository: DeckRepository
    ) = UpdateDeckDetailsUseCase(
        repository = deckRepository
    )

    @Provides
    @Singleton
    fun providesUpdateFlashcardUseCase(
        flashcardRepository: FlashcardRepository
    ) = UpdateFlashcardUseCase(
        repository = flashcardRepository
    )
}