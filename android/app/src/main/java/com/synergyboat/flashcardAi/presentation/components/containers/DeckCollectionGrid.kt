@file:OptIn(ExperimentalFoundationApi::class)

package com.synergyboat.flashcardAi.presentation.components.containers

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex

import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.presentation.components.cards.DeckCard
import com.synergyboat.flashcardAi.presentation.home.viewModels.HomeScreenViewModel

@Composable
fun DeckCollectionGrid(
    decks: List<Deck>,
    onDeckClick: (Deck) -> Unit,
    modifier: Modifier = Modifier,
    viewModel: HomeScreenViewModel = hiltViewModel<HomeScreenViewModel>()
) {
    var isShaking by remember { mutableStateOf(false) }
    val configuration = LocalConfiguration.current
    val isDesktop = configuration.screenWidthDp > 600 // Simple desktop detection
    val backgroundColor = Color(0xFFFDF7FE)

    Box(modifier = modifier.fillMaxSize()) {
        LazyVerticalGrid(
            columns = GridCells.Fixed(if (isDesktop) 6 else 2),
            contentPadding = PaddingValues(top = 8.dp, bottom = 80.dp),
            modifier = Modifier
                .fillMaxSize()
                .pointerInput(Unit) {
                    detectTapGestures {
                        if (isShaking) {
                            isShaking = false
                        }
                    }
                }
        ) {
            itemsIndexed(decks) { index, deck ->
                DeckCard(
                    deck = deck,
                    isShaking = isShaking,
                    viewModel = viewModel,
                    onDeckSelected = { selectedDeck ->
                        if (isShaking) {
                            isShaking = false
                        } else {
                            onDeckClick(selectedDeck)
                        }
                    },
                    onLongPress = {
                        isShaking = true
                    }
                )
            }
        }
        // Top gradient overlay
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(60.dp)
                .background(
                    brush = Brush.verticalGradient(
                        colors = listOf(
                            backgroundColor,
                            backgroundColor.copy(alpha = 0.5f),
                            backgroundColor.copy(alpha = 0f),
                            backgroundColor.copy(alpha = 0f),
                            backgroundColor.copy(alpha = 0f),
                            backgroundColor.copy(alpha = 0f)
                        )
                    )
                )
                .zIndex(1f)
        )

        // Bottom gradient overlay
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(60.dp)
                .align(Alignment.BottomCenter)
                .background(
                    brush = Brush.verticalGradient(
                        colors = listOf(
                            backgroundColor,
                            backgroundColor.copy(alpha = 0.5f),
                            backgroundColor.copy(alpha = 0f),
                            backgroundColor.copy(alpha = 0f)
                        ),
                        startY = Float.POSITIVE_INFINITY,
                        endY = 0f
                    )
                )
                .zIndex(1f)
        )
    }
}