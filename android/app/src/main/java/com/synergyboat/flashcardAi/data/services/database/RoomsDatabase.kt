package com.synergyboat.flashcardAi.data.services.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.synergyboat.flashcardAi.data.converter.DateTypeConverter
import com.synergyboat.flashcardAi.data.dao.DeckDao
import com.synergyboat.flashcardAi.data.entities.DeckEntity

@Database(entities = [DeckEntity::class], version = 1)
@TypeConverters(DateTypeConverter::class)
abstract class RoomsDatabase : RoomDatabase() {
    abstract fun deckDao(): DeckDao
}