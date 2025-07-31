package com.synergyboat.flashcardAi.core.di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import java.util.logging.Logger
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object CoreDependencyModule {
    // This module is currently empty, but can be used to provide application-wide dependencies in the future.
    // For example, you could provide a logger, a network client, or any other singleton dependencies here.
    @Provides
    @Singleton
    fun providesLogger(): Logger {
        return Logger.getLogger("FlashcardAiLogger")
    }
}