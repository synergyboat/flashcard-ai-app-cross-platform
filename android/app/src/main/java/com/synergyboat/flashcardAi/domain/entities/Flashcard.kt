package com.synergyboat.flashcardAi.domain.entities

import kotlinx.serialization.Serializable
import java.time.LocalDateTime

@Serializable
data class Flashcard(
    val id: Int? = null,
    val deckId: Int? = null,
    val question: String,
    val answer: String,
    @kotlinx.serialization.Contextual
    val createdAt: LocalDateTime? = null,
    @kotlinx.serialization.Contextual
    val updatedAt: LocalDateTime? = null,
    @kotlinx.serialization.Contextual
    val lastReviewed: LocalDateTime? = null
)