package com.synergyboat.flutterai.presentation.home

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.navigation.NavController
import com.synergyboat.flutterai.domain.entities.Deck
import com.synergyboat.flutterai.presentation.components.FlashcardAppBar
import com.synergyboat.flutterai.presentation.components.FlashcardBottomActionBar
import com.synergyboat.flutterai.presentation.components.buttons.AIButton
import com.synergyboat.flutterai.presentation.components.containers.DeckCollectionGrid

@Composable
fun HomeScreen(
    navController: NavController,
    decks: List<Deck>,
) {
    val lifecycleOwner = LocalLifecycleOwner.current

    LaunchedEffect(Unit) {
        lifecycleOwner.lifecycle.addObserver(
            LifecycleEventObserver { _, event ->
                if (event == Lifecycle.Event.ON_RESUME) {
//                    refreshDecks()
                }
            }
        )
    }

    Scaffold(
        topBar = { FlashcardAppBar(navController = navController) },
        bottomBar = {
            FlashcardBottomActionBar(
                trailing = {
                    AIButton(onClick = {
                        navController.navigate("ai_generate_deck")
                    })
                }
            )
        },
        content = { padding ->
            Box(modifier = Modifier.padding(padding)) {
                if (decks.isEmpty()) {
                    HomeEmptyState()
                } else {
                    DeckCollectionGrid(decks = decks, onDeckClick = {})
                }
            }
        }
    )
}