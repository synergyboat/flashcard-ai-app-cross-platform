package com.synergyboat.flashcardAi.presentation.splashscreen

import androidx.lifecycle.ViewModel
import com.synergyboat.flashcardAi.core.benchmark.ExecutionLogger
import com.synergyboat.flashcardAi.domain.repository.DeckRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject

@HiltViewModel
class SplashScreenViewModel @Inject constructor(
    val executionLogger: ExecutionLogger,
    val deckRepository: DeckRepository
): ViewModel()