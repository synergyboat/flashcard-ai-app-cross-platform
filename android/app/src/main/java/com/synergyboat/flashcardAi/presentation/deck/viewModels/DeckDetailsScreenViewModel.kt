package com.synergyboat.flashcardAi.presentation.deck.viewModels

import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import com.synergyboat.flashcardAi.domain.entities.Deck
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import java.util.logging.Logger
import javax.inject.Inject

@HiltViewModel
class DeckDetailsScreenViewModel @Inject constructor(
    private val logger: Logger
): ViewModel() {
    private val _deck = MutableStateFlow<Deck?>(null)

    val deck: StateFlow<Deck?> get() = _deck
}