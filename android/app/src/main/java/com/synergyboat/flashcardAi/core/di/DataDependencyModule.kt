package com.synergyboat.flashcardAi.core.di

import android.content.Context
import androidx.room.Room
import com.aallam.openai.api.http.Timeout
import com.aallam.openai.client.OpenAI
import com.synergyboat.flashcardAi.BuildConfig
import com.synergyboat.flashcardAi.data.dao.DeckDao
import com.synergyboat.flashcardAi.data.dao.FlashcardDao
import com.synergyboat.flashcardAi.data.services.database.RoomsDatabase
import com.synergyboat.flashcardAi.data.services.openai.OpenAIService
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton
import kotlin.time.Duration.Companion.seconds

@Module
@InstallIn(SingletonComponent::class)
object DataDependencyModule {
    // This module is responsible for providing data layer dependencies.
    // It can be used to provide database instances, DAOs, and other data-related services.
    @Provides
    @Singleton
    fun provideAppDatabase(@ApplicationContext appContext: Context): RoomsDatabase {
        return Room.databaseBuilder(
            appContext,
            RoomsDatabase::class.java,
            "flashcard_db"
        ).fallbackToDestructiveMigration(false)
            .build()
    }

    @Provides
    @Singleton
    fun provideDeckDao(db: RoomsDatabase): DeckDao = db.deckDao()

    @Provides
    @Singleton
    fun provideFlashcardDao(db: RoomsDatabase): FlashcardDao = db.flashcardDao()

    @Provides
    @Singleton
    fun provideOpenAi(): OpenAI {
        val token = BuildConfig.API_KEY.ifBlank {
            throw IllegalStateException("API_KEY is missing in BuildConfig")
        }
        return OpenAI(
            token = token,
            timeout = Timeout(socket = 60.seconds)
        )
    }

    @Provides
    @Singleton
    fun provideOpenAiService(openAI: OpenAI): OpenAIService {
        return OpenAIService(openAI)
    }
}