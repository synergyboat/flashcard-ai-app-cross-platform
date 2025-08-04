package com.synergyboat.flashcardAi.presentation.home

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.navigation.NavController
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.presentation.components.FlashcardAppBar
import com.synergyboat.flashcardAi.presentation.components.FlashcardBottomActionBar
import com.synergyboat.flashcardAi.presentation.components.buttons.AIButton
import com.synergyboat.flashcardAi.presentation.components.containers.DeckCollectionGrid
import com.synergyboat.flashcardAi.presentation.home.viewModels.HomeScreenViewModel

@Composable
fun HomeScreen(
    navController: NavController,
    viewModel: HomeScreenViewModel = hiltViewModel<HomeScreenViewModel>()
) {

    val decks: List<Deck> = viewModel.decks.collectAsState().value
    val lifecycleOwner = LocalLifecycleOwner.current

    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) {
                viewModel.refreshDecks()
            }
        }

        lifecycleOwner.lifecycle.addObserver(observer)

        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
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
                    DeckCollectionGrid(
                        navController = navController,
                        decks = decks,
                        onDeckClick = {})
                }
            }
        }
    )
}