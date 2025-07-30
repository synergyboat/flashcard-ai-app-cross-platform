package com.synergyboat.flashcardAi.presentation.splashscreen

import androidx.lifecycle.ViewModel
import com.synergyboat.flashcardAi.core.benchmark.ExecutionLogger
import dagger.hilt.android.lifecycle.HiltViewModel
import jakarta.inject.Inject

@HiltViewModel
class SplashScreenViewModel @Inject constructor(
    val executionLogger: ExecutionLogger
): ViewModel()