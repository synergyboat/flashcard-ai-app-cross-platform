package com.synergyboat.flashcardAi.presentation.home.viewModels

import android.R
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.usecase.deck.DeleteDeckUseCase
import com.synergyboat.flashcardAi.domain.usecase.deck.GetAllDecksUseCase
import com.synergyboat.flashcardAi.domain.usecase.deck.UpdateDeckDetailsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.logging.Logger
import javax.inject.Inject
import kotlin.coroutines.cancellation.CancellationException

@HiltViewModel
class HomeScreenViewModel @Inject constructor(
    private val getAllDecksUseCase: GetAllDecksUseCase,
    private val deleteDeckUseCase: DeleteDeckUseCase,
    private val updateDeckDetailsUseCase: UpdateDeckDetailsUseCase
) : ViewModel() {
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
    private val _isLoading = MutableStateFlow(true)
    val decks: StateFlow<List<Deck>> = _decks
    val isLoading: StateFlow<Boolean> = _isLoading

    private var refreshJob: Job? = null

    fun refreshDecks() {
        refreshJob?.cancel()
        refreshJob = viewModelScope.launch {
            setIsLoading(true)
            try {
                // Keep heavy I/O off the main thread
                val decks = withContext(Dispatchers.IO) { getAllDecksUseCase() }
                _decks.value = decks
            } catch (ce: CancellationException) {
                throw ce
            } catch (e: Exception) {
                e.printStackTrace() //Log the exception and report in production
            } finally {
                setIsLoading(false)
            }
        }
    }

    fun setIsLoading(state: Boolean) {
        _isLoading.value = state
    }

    fun updateDeck(updatedDeck: Deck) {
        viewModelScope.launch {
            updateDeckDetailsUseCase(updatedDeck)
            refreshDecks()
        }
    }

    fun deleteDeck(deck: Deck) {
        viewModelScope.launch {
            deleteDeckUseCase(deck)
            refreshDecks()
        }
    }
}