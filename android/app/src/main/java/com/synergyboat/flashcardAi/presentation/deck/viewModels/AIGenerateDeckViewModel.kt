package com.synergyboat.flashcardAi.presentation.deck.viewModels

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.usecase.CreateNewDeckUseCase
import com.synergyboat.flashcardAi.domain.usecase.ai.GenerateDeckWithAIUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import java.util.logging.Logger
import javax.inject.Inject

@HiltViewModel
class AIGenerateDeckViewModel @Inject constructor(
    private val generateDeckWithAIUseCase: GenerateDeckWithAIUseCase,
    private val createNewDeckUseCase: CreateNewDeckUseCase,
    private val logger: Logger
) : ViewModel() {

    var promptText by mutableStateOf("")
    var numberOfCards by mutableIntStateOf(10)
    var isGenerating by mutableStateOf(false)

    fun generateDeck(
        onSuccess: (Deck) -> Unit,
        onError: (Throwable) -> Unit = {}
    ) {
        if (isGenerating) return

        viewModelScope.launch {
            isGenerating = true
            try {
                val deck = generateDeckWithAIUseCase(prompt = promptText, count = numberOfCards)
                logger.info("Deck generated with prompt: $promptText")
                createNewDeckUseCase(deck).also { deck.id = it }
                onSuccess(deck)
            } catch (e: Exception) {
                logger.warning("Error generating deck: ${e.message}")
                onError(e)
            } finally {
                isGenerating = false
            }
        }
    }
}