package com.synergyboat.flashcardAi.presentation.deck

import android.app.AlertDialog
import android.content.Context
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
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
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    var currentIndex by remember { mutableIntStateOf(0) }
    val swipeOffset = remember { Animatable(0f) }
    var opacity by remember { mutableFloatStateOf(1f) }

    val flashcards = remember(deck) { deck.flashcards }
    val visibleFlashcards = remember(currentIndex, flashcards) {
        flashcards.subList(
            currentIndex,
            (currentIndex + 3).coerceAtMost(flashcards.size)
        )
    }

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
                    onClick = { navController.navigateUp() },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                ) {
                    Text("Close")
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .padding(horizontal = 16.dp, vertical = 8.dp)
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (!deck.description.isNullOrEmpty()) {
                Text(
                    text = deck.description!!,
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
                visibleFlashcards.reversed().forEachIndexed { i, flashcard ->
                    val isTop = i == 0
                    val offsetY = (i * 12).dp
                    val scale = 1f - (i * 0.05f)
                    val z = 3 - i

                    val modifier = Modifier
                        .offset(y = -offsetY)
                        .graphicsLayer {
                            scaleX = scale
                            scaleY = scale
                            translationX = if (isTop) swipeOffset.value else 0f
                            alpha = if (isTop) opacity else 1f
                        }
                        .zIndex(z.toFloat())
                        .fillMaxWidth()
                        .height(400.dp)
                        .then(
                            if (isTop) Modifier.pointerInput(Unit) {
                                detectHorizontalDragGestures(
                                    onDragEnd = {
                                        coroutineScope.launch {
                                            val threshold = 100f
                                            val screenWidth = context.resources.displayMetrics.widthPixels
                                            val targetOffset = when {
                                                swipeOffset.value < -threshold && currentIndex < flashcards.lastIndex -> -screenWidth.toFloat()
                                                swipeOffset.value > threshold && currentIndex > 0 -> screenWidth.toFloat()
                                                else -> 0f
                                            }

                                            swipeOffset.animateTo(
                                                targetOffset,
                                                animationSpec = tween(250, easing = FastOutSlowInEasing)
                                            )

                                            when {
                                                targetOffset < 0 && currentIndex < flashcards.lastIndex -> currentIndex++
                                                targetOffset > 0 && currentIndex > 0 -> currentIndex--
                                            }

                                            swipeOffset.snapTo(0f)
                                            opacity = 1f
                                        }
                                    },
                                    onHorizontalDrag = { _, dragAmount ->
                                        coroutineScope.launch {
                                            val newOffset = swipeOffset.value + dragAmount
                                            swipeOffset.snapTo(newOffset)
                                            opacity = ((200f - newOffset.absoluteValue) / 200f)
                                                .coerceIn(0f, 1f)
                                        }
                                    }
                                )
                            } else Modifier
                        )

                    Card(
                        modifier = modifier,
                        shape = RoundedCornerShape(32.dp),
                        elevation = CardDefaults.cardElevation(16.dp),
                        colors = CardDefaults.cardColors(containerColor = Color(0xFFF6F6F6))
                    ) {
                        FlashcardContent(flashcard)
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = "Card ${currentIndex + 1} of ${flashcards.size}",
                color = Color.Gray
            )
        }
    }
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