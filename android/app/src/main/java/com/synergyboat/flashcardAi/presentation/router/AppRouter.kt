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
import kotlinx.serialization.json.Json
import java.nio.charset.StandardCharsets

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
            HomeScreen(navController)
        }

        composable(Routes.AiGenerateDeck.route) {
            AIGenerateDeckScreen(
                navController
            )
        }

        composable(
            route = "${Routes.DeckDetails.route}/{deckJson}",
            arguments = listOf(navArgument("deckJson") { type = NavType.StringType })
        ) { backStackEntry ->
            val deckJson = backStackEntry.arguments?.getString("deckJson") ?: ""
            val decodedDeck =
                java.net.URLDecoder.decode(deckJson, StandardCharsets.UTF_8.toString())
            val deck = Json.decodeFromString<Deck>(decodedDeck)

            DeckDetailsScreen(
                navController = navController,
                deck = deck
            )
        }

        // Example future route
        // composable(Routes.DeckDetail.route + "/{deckId}") { backStackEntry ->
        //     val deckId = backStackEntry.arguments?.getString("deckId")
        //     DeckDetailScreen(deckId = deckId)
        // }
    }
}