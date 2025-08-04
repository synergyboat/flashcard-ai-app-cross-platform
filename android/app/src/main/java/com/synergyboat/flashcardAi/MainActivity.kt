package com.synergyboat.flashcardAi

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.synergyboat.flashcardAi.presentation.router.AppRouter
import com.synergyboat.flashcardAi.presentation.ui.theme.FlutterAITheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            FlutterAITheme {
                AppRouter()
            }
        }
    }
}