package com.synergyboat.flashcardAi

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class FlashcardAiApp : Application() {
    // This class is the entry point for Hilt dependency injection.
    // It initializes the Hilt components and allows for dependency injection throughout the app.
    // You can add application-wide dependencies here if needed.
}