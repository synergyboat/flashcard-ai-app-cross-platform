package com.synergyboat.flashcardAi.presentation.components.containers

import android.os.Build
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.presentation.components.cards.DeckCard
import com.synergyboat.flashcardAi.presentation.router.Routes

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun DeckCollectionGrid(
    navController: NavController,
    decks: List<Deck>,
    onDeckClick: (Deck) -> Unit
) {
    val screenWidthDp = LocalConfiguration.current.screenWidthDp
    val isMac = Build.DEVICE.lowercase().contains("mac") // platform check fallback
    val crossAxisCount = if (isMac || screenWidthDp > 1000) 6 else 2

    Box(modifier = Modifier
        .fillMaxSize()
        .padding(horizontal = 16.dp)) {
        LazyVerticalGrid(
            columns = GridCells.Fixed(crossAxisCount),
            contentPadding = PaddingValues(horizontal = 16.dp),
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(decks) { deck ->
                DeckCard(deck = deck, onClick = {
                    navController.navigate(Routes.DeckDetails.createRoute(deck.id?:-1 ))
                })
            }
        }

        // Top fade gradient
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(60.dp)
                .align(Alignment.TopCenter)
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color(0xfffdf7fe),
                            Color(0xfffdf7fe).copy(alpha = 0.5f),
                            Color(0xfffdf7fe).copy(alpha = 0.0f)
                        )
                    )
                )
        )

        // Bottom fade gradient
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(60.dp)
                .align(Alignment.BottomCenter)
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color(0xfffdf7fe),
                            Color(0xfffdf7fe).copy(alpha = 0.5f),
                            Color(0xfffdf7fe).copy(alpha = 0.0f)
                        ),
                        startY = Float.POSITIVE_INFINITY,
                        endY = 0f
                    )
                )
        )
    }
}