package com.synergyboat.flashcardAi.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.LocalDateTime
import java.util.Date
@Entity(tableName = "deck")
data class DeckEntity(
    @PrimaryKey(autoGenerate = true) val id: Long? = null,
    val name: String,
    val description: String,
    val createdAt: Date? = null,
    val updatedAt: Date? = null
)