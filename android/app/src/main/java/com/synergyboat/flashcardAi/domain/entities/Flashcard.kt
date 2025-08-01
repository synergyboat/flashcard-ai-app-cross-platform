package com.synergyboat.flashcardAi.domain.entities

import kotlinx.serialization.Serializable
import java.util.Date
import java.time.LocalDateTime

@Serializable
data class Flashcard(
    val id: Long? = null,
    val deckId: Long? = null,
    val question: String = "",
    val answer: String = "",
    @kotlinx.serialization.Contextual
    val createdAt: Date? = null,
    @kotlinx.serialization.Contextual
    val updatedAt: Date? = null,
    @kotlinx.serialization.Contextual
    val lastReviewed: Date? = null
)