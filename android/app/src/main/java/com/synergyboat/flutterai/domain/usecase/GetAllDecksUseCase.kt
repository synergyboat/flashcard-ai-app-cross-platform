package com.synergyboat.flutterai.domain.usecase

import com.synergyboat.flutterai.domain.entities.Deck
import com.synergyboat.flutterai.domain.repository.DeckRepository

class GetAllDecksUseCase(
    private val repository: DeckRepository
) {
    suspend operator fun invoke(): List<Deck> {
        return repository.getAllDecks()
    }
}