package com.synergyboat.flashcardAi.domain.entities

import kotlinx.serialization.Serializable
import java.time.LocalDateTime

@Serializable
data class Deck(
    val id: Int? = null,
    val name: String,
    val description: String,
    @kotlinx.serialization.Contextual
    val createdAt: LocalDateTime? = null,
    @kotlinx.serialization.Contextual
    val updatedAt: LocalDateTime? = null,
    val flashcards: List<Flashcard> = emptyList()
)