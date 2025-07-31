package com.synergyboat.flashcardAi.core.di

import android.content.Context
import androidx.room.Room
import com.synergyboat.flashcardAi.data.dao.DeckDao
import com.synergyboat.flashcardAi.data.services.database.RoomsDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import io.github.cdimascio.dotenv.Dotenv
import java.util.logging.Logger
import javax.inject.Singleton
import io.github.cdimascio.dotenv.dotenv
import com.synergyboat.flashcardAi.BuildConfig

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