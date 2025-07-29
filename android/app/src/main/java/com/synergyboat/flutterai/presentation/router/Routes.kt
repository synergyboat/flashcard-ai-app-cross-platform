package com.synergyboat.flutterai.presentation.router

sealed class Routes(val route: String) {
    object Splash : Routes("splash")
    object Home : Routes("home")
}