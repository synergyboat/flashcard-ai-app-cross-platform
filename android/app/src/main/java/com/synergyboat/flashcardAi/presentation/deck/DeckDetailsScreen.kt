package com.synergyboat.flashcardAi.presentation.deck

import android.app.AlertDialog
import android.content.Context
import androidx.compose.animation.core.Animatable
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
import androidx.compose.material3.TopAppBar
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
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.entities.Flashcard
import kotlinx.coroutines.launch
import kotlin.math.absoluteValue
import kotlin.math.pow

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DeckDetailsScreen(
    deck: Deck,
    onClose: () -> Unit,
    onDelete: (Deck) -> Unit
) {
    val flashcards = remember(deck) { deck.flashcards.toList() }
    val swipeOffset = remember { Animatable(0f) }
    val coroutineScope = rememberCoroutineScope()
    var currentIndex by remember { mutableIntStateOf(0) }
    var opacity by remember { mutableFloatStateOf(1f) }

    val context = LocalContext.current

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(deck.name) },
                actions = {
                    IconButton(onClick = { showDeleteDialog(context, deck, onDelete) }) {
                        Icon(Icons.Default.Delete, contentDescription = "Delete", tint = Color.Red)
                    }
                }
            )
        },
        bottomBar = {
            BottomAppBar {
                Button(
                    onClick = onClose,
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
                if (deck.description.isNotEmpty()) {
                    Text(
                        text = deck.description!!,
                        style = MaterialTheme.typography.bodySmall,
                        textAlign = TextAlign.Center,
                        color = Color.Gray
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                }

                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    flashcards.drop(currentIndex).take(3).reversed().forEachIndexed { i, flashcard ->
                        val offset = (i * 12).dp
                        val scale = 1f - (i * 0.05f)
                        val zIndex = 3 - i

                        val cardModifier = Modifier
                            .offset(y = -offset)
                            .graphicsLayer {
                                scaleX = scale
                                scaleY = scale
                                alpha = if (i == 0) opacity else 1f
                            }

                        if (i == 0) {
                            Card(
                                modifier = cardModifier
                                    .fillMaxWidth()
                                    .height(400.dp)
                                    .pointerInput(Unit) {
                                        detectHorizontalDragGestures(
                                            onDragEnd = {
                                                if (swipeOffset.value < -100 && currentIndex < flashcards.size - 1) {
                                                    coroutineScope.launch {
                                                        swipeOffset.snapTo(0f)
                                                        currentIndex++
                                                    }
                                                } else if (swipeOffset.value > 100 && currentIndex > 0) {
                                                    coroutineScope.launch {
                                                        swipeOffset.snapTo(0f)
                                                        currentIndex--
                                                    }
                                                } else {
                                                    coroutineScope.launch {
                                                        swipeOffset.animateTo(0f)
                                                    }
                                                }
                                            },
                                            onHorizontalDrag = { _, dragAmount ->
                                                coroutineScope.launch {
                                                    swipeOffset.snapTo(swipeOffset.value + dragAmount)
                                                    opacity = (1f - (swipeOffset.value.absoluteValue / 200f)).pow(2).coerceIn(0f, 1f)
                                                }
                                            }
                                        )
                                    },
                                shape = RoundedCornerShape(24.dp),
                                elevation = CardDefaults.cardElevation(8.dp)
                            ) {
                                FlashcardContent(flashcard)
                            }
                        } else {
                            Card(
                                modifier = cardModifier
                                    .fillMaxWidth()
                                    .height(400.dp)
                                    .zIndex(zIndex.toFloat()),
                                shape = RoundedCornerShape(24.dp),
                                elevation = CardDefaults.cardElevation(4.dp)
                            ) {
                                FlashcardContent(flashcard)
                            }
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
            text = flashcard.question,
            style = MaterialTheme.typography.headlineSmall,
            textAlign = TextAlign.Center
        )
        Text(
            text = flashcard.answer,
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
