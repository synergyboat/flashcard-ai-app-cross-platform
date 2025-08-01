package com.synergyboat.flashcardAi.presentation.home.viewModels

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.DeckRepository
import com.synergyboat.flashcardAi.domain.usecase.GetAllDecksUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class HomeScreenViewModel @Inject constructor(
    private val getAllDecksUseCase: GetAllDecksUseCase
): ViewModel() {
    // This ViewModel can be used to manage the state and logic for the Home Screen.
    // You can add LiveData or StateFlow properties here to hold the UI state.
    // Additionally, you can inject use cases or repositories as needed for data operations.

    // Example:
    // private val _decks = MutableLiveData<List<Deck>>()
    // val decks: LiveData<List<Deck>> get() = _decks
    // // fun loadDecks() {
    //     viewModelScope.launch {
    //         _decks.value = deckRepository.getAllDecks()
    //     }
    // }

    private val _decks = MutableStateFlow<List<Deck>>(emptyList())

    val decks: StateFlow<List<Deck>> = _decks

    fun refreshDecks() {
        viewModelScope.launch {
            _decks.value = getAllDecksUseCase()
        }
    }
}