package com.synergyboat.flutterai.presentation.router

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.synergyboat.flutterai.domain.entities.Deck
import com.synergyboat.flutterai.presentation.home.HomeScreen
import com.synergyboat.flutterai.presentation.splashscreen.SplashScreen
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