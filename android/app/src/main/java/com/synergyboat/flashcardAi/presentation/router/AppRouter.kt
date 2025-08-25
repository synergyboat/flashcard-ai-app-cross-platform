package com.synergyboat.flashcardAi.presentation.router

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.remember
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.presentation.benchmark.BenchmarkHistoryScreen
import com.synergyboat.flashcardAi.presentation.benchmark.BenchmarkResult
import com.synergyboat.flashcardAi.presentation.benchmark.BenchmarkType
import com.synergyboat.flashcardAi.presentation.benchmark.ListRenderBenchmarkScreen
import com.synergyboat.flashcardAi.presentation.deck.AIGenerateDeckScreen
import com.synergyboat.flashcardAi.presentation.deck.DeckDetailsScreen
import com.synergyboat.flashcardAi.presentation.home.HomeScreen
import com.synergyboat.flashcardAi.presentation.splashscreen.SplashScreen
import kotlinx.serialization.json.Json
import java.nio.charset.StandardCharsets

@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun AppRouter() {
    val navController = rememberNavController()
    val benchmarkResults = remember { mutableStateListOf<BenchmarkResult>() }


    NavHost(
        navController = navController,
        startDestination = Routes.Home.route
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

        composable("benchmark") {
            ListRenderBenchmarkScreen(
                itemCount = 100,
                iterations = 3,
                benchmarkType = BenchmarkType.ScrollPerformance,
                onBenchmarkComplete = {
                    benchmarkResults.clear()
                    benchmarkResults.addAll(it)
                    navController.navigate("history")
                }
            )
        }
            composable("history") {
                BenchmarkHistoryScreen(results = benchmarkResults)
            }

        // Example future route
        // composable(Routes.DeckDetail.route + "/{deckId}") { backStackEntry ->
        //     val deckId = backStackEntry.arguments?.getString("deckId")
        //     DeckDetailScreen(deckId = deckId)
        // }
    }
}