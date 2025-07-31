package com.synergyboat.flashcardAi.core.di

import android.content.Context
import androidx.room.Room
import com.synergyboat.flashcardAi.data.dao.DeckDao
import com.synergyboat.flashcardAi.data.dao.FlashcardDao
import com.synergyboat.flashcardAi.data.services.database.RoomsDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import java.util.logging.Logger
import javax.inject.Singleton

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
    fun provideDeckDao(db: RoomsDatabase): DeckDao = db.deckDao()

    @Provides
    fun provideFlashcardDao(db: RoomsDatabase): FlashcardDao = db.flashcardDao()
}