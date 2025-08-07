package com.synergyboat.flashcardAi.presentation.router

sealed class Routes(val route: String) {
    object Splash : Routes("splash")
    object Home : Routes("home")
    object AiGenerateDeck : Routes("ai_generate_deck")
    object DeckDetails : Routes("deck_details") {
        fun createRoute(deck: String): String = "$route/$deck"
    }
    object Benchmark : Routes("benchmark")
    object BenchmarkHistory : Routes("benchmark_history") {
        fun createRoute(benchmarkType: String): String = "$route/$benchmarkType"
    }
}