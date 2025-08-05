package com.synergyboat.flashcardAi.domain.entities

import kotlinx.serialization.Serializable
import java.util.Date

@Serializable
data class Deck(
    var id: Long? = null,
    var name: String = "",
    var description: String = "",
    @kotlinx.serialization.Contextual
    var createdAt: Date? = null,
    @kotlinx.serialization.Contextual
    var updatedAt: Date? = null,
    var flashcards: List<Flashcard> = emptyList()
)