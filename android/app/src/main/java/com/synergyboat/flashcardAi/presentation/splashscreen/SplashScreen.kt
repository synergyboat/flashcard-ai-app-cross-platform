package com.synergyboat.flashcardAi.presentation.splashscreen

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.synergyboat.flashcardAi.presentation.router.Routes
import com.synergyboat.flashcardAi.presentation.splashscreen.viewModels.SplashScreenViewModel
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(
    navController: NavController,
    viewModel: SplashScreenViewModel = hiltViewModel<SplashScreenViewModel>()
) {

    LaunchedEffect(Unit) {
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