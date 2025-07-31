package com.synergyboat.flashcardAi.presentation.router

import androidx.compose.runtime.Composable
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.presentation.deck.AIGenerateDeckScreen
import com.synergyboat.flashcardAi.presentation.deck.DeckDetailsScreen
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

        composable(Routes.AiGenerateDeck.route) {
            AIGenerateDeckScreen(
                navController
            )
        }

        composable(
            route = "${Routes.DeckDetails.route}/{deckId}",
            arguments = listOf(navArgument("deckId") { type = NavType.LongType })
        ) { backStackEntry ->
            val deckId = backStackEntry.arguments?.getLong("deckId") ?: -1L

            DeckDetailsScreen(
                navController = navController,
                deck = Deck(
                    id = deckId,
                    name = "Deck $deckId",
                    description = "Description for deck $deckId"
                )
            )
        }

        // Example future route
        // composable(Routes.DeckDetail.route + "/{deckId}") { backStackEntry ->
        //     val deckId = backStackEntry.arguments?.getString("deckId")
        //     DeckDetailScreen(deckId = deckId)
        // }
    }
}