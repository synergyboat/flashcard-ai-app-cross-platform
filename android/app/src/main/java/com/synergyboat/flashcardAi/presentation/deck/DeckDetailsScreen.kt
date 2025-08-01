package com.synergyboat.flashcardAi.presentation.deck

import android.app.AlertDialog
import android.content.Context
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.BottomAppBar
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import androidx.navigation.NavController
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.entities.Flashcard
import com.synergyboat.flashcardAi.presentation.components.FlashcardAppBar
import kotlinx.coroutines.launch
import kotlin.math.absoluteValue

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DeckDetailsScreen(
    navController: NavController,
    deck: Deck,
) {
    val flashcards = remember(deck) { deck.flashcards.toList() }
    val swipeOffset = remember { Animatable(0f) }
    val coroutineScope = rememberCoroutineScope()
    var currentIndex by remember { mutableIntStateOf(0) }
    var opacity by remember { mutableFloatStateOf(1f) }
    val context = LocalContext.current

    Scaffold(
        topBar = {
            FlashcardAppBar(
                navController = navController,
                title = deck.name,
                actions = {
                    IconButton(onClick = { showDeleteDialog(context, deck, {}) }) {
                        Icon(Icons.Default.Delete, contentDescription = "Delete", tint = Color.Red)
                    }
                }
            )
        },
        bottomBar = {
            BottomAppBar {
                Button(
                    onClick = { navController.popBackStack() },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                ) {
                    Text("Close")
                }
            }
        },
        content = { padding ->
            Column(
                modifier = Modifier
                    .padding(padding)
                    .padding(horizontal = 16.dp, vertical = 8.dp)
                    .fillMaxSize(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                if (!deck.description.isNullOrEmpty()) {
                    Text(
                        text = deck.description,
                        style = MaterialTheme.typography.bodySmall,
                        textAlign = TextAlign.Center,
                        color = Color.Gray
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                }

                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    (0..2).mapNotNull { offset ->
                        val index = currentIndex + offset
                        if (index < flashcards.size) index else null
                    }.reversed().forEachIndexed { i, actualIndex ->
                        val flashcard = flashcards[actualIndex]
                        val offsetY = (i * 12).dp
                        val scale = 1f - (i * 0.05f)
                        val z = 3 - i
                        val isTop = i == 0

                        val cardModifier = Modifier
                            .offset(y = -offsetY)
                            .graphicsLayer {
                                scaleX = scale
                                scaleY = scale
                                translationX = if (isTop) swipeOffset.value else 0f
                                alpha = if (isTop) opacity else 1f
                            }
                            .zIndex(z.toFloat())

                        Card(
                            modifier = cardModifier
                                .fillMaxWidth()
                                .height(400.dp)
                                .then(
                                    if (isTop) Modifier.pointerInput(Unit) {
                                        detectHorizontalDragGestures(
                                            onDragEnd = {
                                                coroutineScope.launch {
                                                    val threshold = 100f
                                                    val screenWidth =
                                                        context.resources.displayMetrics.widthPixels.toFloat()
                                                    val targetOffset = when {
                                                        swipeOffset.value < -threshold && currentIndex < flashcards.lastIndex -> -screenWidth
                                                        swipeOffset.value > threshold && currentIndex > 0 -> screenWidth
                                                        else -> 0f
                                                    }

                                                    swipeOffset.animateTo(
                                                        targetOffset,
                                                        animationSpec = tween(
                                                            durationMillis = 250,
                                                            easing = FastOutSlowInEasing
                                                        )
                                                    )

                                                    if (targetOffset < 0 && currentIndex < flashcards.lastIndex) {
                                                        currentIndex++
                                                    } else if (targetOffset > 0 && currentIndex > 0) {
                                                        currentIndex--
                                                    }

                                                    swipeOffset.snapTo(0f)
                                                    opacity = 1f
                                                }
                                            },
                                            onHorizontalDrag = { _, dragAmount ->
                                                coroutineScope.launch {
                                                    val newOffset = swipeOffset.value + dragAmount
                                                    swipeOffset.snapTo(newOffset)
                                                    opacity =
                                                        ((200f - newOffset.absoluteValue) / 200f)
                                                            .coerceIn(0f, 1f)
                                                }
                                            }
                                        )
                                    } else Modifier
                                ),
                            shape = RoundedCornerShape(32.dp),
                            elevation = CardDefaults.cardElevation(16.dp),
                            colors = CardDefaults.cardColors(containerColor = Color(0xFFF6F6F6))
                        ) {
                            FlashcardContent(flashcard)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))
                Text("Card ${currentIndex + 1} of ${flashcards.size}", color = Color.Gray)
            }
        }
    )
}

@Composable
fun FlashcardContent(flashcard: Flashcard) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.SpaceBetween,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = flashcard.question.orEmpty(),
            style = MaterialTheme.typography.headlineSmall,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(20.dp))
        Text(
            text = flashcard.answer.orEmpty(),
            style = MaterialTheme.typography.bodyMedium,
            textAlign = TextAlign.Center
        )
    }
}

fun showDeleteDialog(context: Context, deck: Deck, onDelete: (Deck) -> Unit) {
    AlertDialog.Builder(context)
        .setTitle("Confirm Deletion")
        .setMessage("Are you sure you want to delete this deck? This action cannot be undone.")
        .setPositiveButton("Confirm") { dialog, _ ->
            onDelete(deck)
            dialog.dismiss()
        }
        .setNegativeButton("Cancel") { dialog, _ ->
            dialog.dismiss()
        }
        .show()
}