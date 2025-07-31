package com.synergyboat.flashcardAi.core.di

import android.content.Context
import androidx.room.Room
import com.synergyboat.flashcardAi.data.dao.DeckDao
import com.synergyboat.flashcardAi.data.repository.DeckRepositoryImpl
import com.synergyboat.flashcardAi.data.services.database.RoomsDatabase
import com.synergyboat.flashcardAi.domain.repository.DeckRepository
import com.synergyboat.flashcardAi.domain.repository.FlashcardRepository
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import java.util.logging.Logger
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

}