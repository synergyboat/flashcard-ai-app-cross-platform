package com.synergyboat.flashcardAi.presentation.splashscreen

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.synergyboat.flashcardAi.presentation.router.Routes
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(navController: NavController, viewModel: SplashScreenViewModel = hiltViewModel()) {

    LaunchedEffect(Unit) {

        viewModel.deckRepository.createDeck(
            com.synergyboat.flashcardAi.domain.entities.Deck(
                name = "Default Deck",
                description = "This is a default deck created on first launch.",
            )
        )

        delay(2000)
        navController.navigate(Routes.Home.route) {
            popUpTo("splash") { inclusive = true }
        }
    }

    Scaffold { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Flashcard AI",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}