package com.synergyboat.flashcardAi.domain.entities

import kotlinx.serialization.Serializable
import java.util.Date
import java.time.LocalDateTime

@Serializable
data class Deck(
    val id: Long? = null,
    val name: String,
    val description: String,
    @kotlinx.serialization.Contextual
    val createdAt: Date? = null,
    @kotlinx.serialization.Contextual
    val updatedAt: Date? = null,
    val flashcards: List<Flashcard> = emptyList()
)