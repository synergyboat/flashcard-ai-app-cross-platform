package com.synergyboat.flashcardAi.presentation.deck.viewModels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.entities.Flashcard
import com.synergyboat.flashcardAi.domain.usecase.flashcard.DeleteFlashcardUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import java.util.logging.Logger
import javax.inject.Inject

@HiltViewModel
class DeckDetailsScreenViewModel @Inject constructor(
    private val logger: Logger,
    private val deleteFlashcardUseCase: DeleteFlashcardUseCase,
//    private val updateFlashcardUseCase: UpdateFlashcardUseCase
) : ViewModel() {

    private val _deck = MutableStateFlow<Deck?>(null)
    val deck: StateFlow<Deck?> get() = _deck

    private val _flashcards = MutableStateFlow<List<Flashcard>>(emptyList())
    val flashcards: StateFlow<List<Flashcard>> get() = _flashcards

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> get() = _isLoading

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> get() = _error

    fun initializeDeck(deck: Deck) {
        _deck.value = deck
        _flashcards.value = deck.flashcards.toMutableList()
        logger.info("The deck is: ${deck}")
    }

//    fun updateFlashcard(flashcard: Flashcard, question: String, answer: String) {
//        viewModelScope.launch {
//            try {
//                _isLoading.value = true
//                val updatedFlashcard = flashcard.copy(question = question, answer = answer)
//
//                updateFlashcardUseCase(updatedFlashcard)
//
//                val currentFlashcards = _flashcards.value.toMutableList()
//                val index = currentFlashcards.indexOfFirst { it.id == flashcard.id }
//                if (index != -1) {
//                    currentFlashcards[index] = updatedFlashcard
//                    _flashcards.value = currentFlashcards
//
//                    // Update the deck as well
//                    _deck.value = _deck.value?.copy(flashcards = currentFlashcards)
//                }
//
//                _error.value = null
//            } catch (e: Exception) {
//                _error.value = "Failed to update flashcard: ${e.message}"
//                logger.severe("Error updating flashcard: ${e.message}")
//            } finally {
//                _isLoading.value = false
//            }
//        }
//    }

    fun deleteFlashcard(flashcard: Flashcard) {
        viewModelScope.launch {
            try {
                _isLoading.value = true

                deleteFlashcardUseCase(flashcard)

                val currentFlashcards = _flashcards.value.toMutableList()
                currentFlashcards.removeAll { it.id == flashcard.id }
                _flashcards.value = currentFlashcards

                // Update the deck as well
                _deck.value = _deck.value?.copy(flashcards = currentFlashcards)

                _error.value = null
            } catch (e: Exception) {
                _error.value = "Failed to delete flashcard: ${e.message}"
                logger.severe("Error deleting flashcard: ${e.message}")
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun clearError() {
        _error.value = null
    }
}