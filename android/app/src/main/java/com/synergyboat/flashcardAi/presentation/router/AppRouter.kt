package com.synergyboat.flashcardAi.presentation.router

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.presentation.home.HomeScreen
import com.synergyboat.flashcardAi.presentation.splashscreen.SplashScreen
import kotlin.collections.listOf

@Composable
fun AppRouter() {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = Routes.Splash.route
    ) {
        composable(Routes.Splash.route) {
            SplashScreen(navController)
        }

        composable(Routes.Home.route) {
            HomeScreen(navController, decks = listOf(
                // Example decks for preview
                Deck(id = 1, name = "Deck 1", description = "Description 1"),
                Deck(id = 1, name = "Deck 1", description = "Description 1"),
                Deck(id = 1, name = "Deck 1", description = "Description 1"),
            ))
        }

        // Example future route
        // composable(Routes.DeckDetail.route + "/{deckId}") { backStackEntry ->
        //     val deckId = backStackEntry.arguments?.getString("deckId")
        //     DeckDetailScreen(deckId = deckId)
        // }
    }
}