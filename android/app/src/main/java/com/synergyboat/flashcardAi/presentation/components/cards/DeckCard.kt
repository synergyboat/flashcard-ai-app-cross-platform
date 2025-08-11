@file:OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)

package com.synergyboat.flashcardAi.presentation.components.cards

import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.compose.ui.zIndex
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.presentation.home.viewModels.HomeScreenViewModel
import kotlinx.coroutines.launch

@Composable
fun DeckCard(
    deck: Deck,
    onDeckSelected: (Deck) -> Unit,
    onLongPress: () -> Unit,
    isShaking: Boolean,
    viewModel: HomeScreenViewModel,
    modifier: Modifier = Modifier
) {
    var showEditDialog by remember { mutableStateOf(false) }
    var showDeleteDialog by remember { mutableStateOf(false) }
    var nameEditValue by remember { mutableStateOf("") }
    var descriptionEditValue by remember { mutableStateOf("") }

    // Shaking animation
    val infiniteTransition = rememberInfiniteTransition(label = "shake")
    val shakeAnimation by infiniteTransition.animateFloat(
        initialValue = -5f,
        targetValue = 5f,
        animationSpec = infiniteRepeatable(
            animation = tween(100, easing = EaseInOut),
            repeatMode = RepeatMode.Reverse
        ),
        label = "shake"
    )

    val rotationAngle = if (isShaking) shakeAnimation else 0f

    Box(
        modifier = modifier
            .padding(16.dp)
            .aspectRatio(0.8f)
            .combinedClickable(
                indication = null,
                interactionSource = remember { MutableInteractionSource() },
                onClick = { onDeckSelected(deck) },
                onLongClick = onLongPress
            )
    ) {
        // Card stack
        Box(
            modifier = Modifier
                .rotate(rotationAngle)
                .aspectRatio(0.8f)
                .fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            CardStack(deck = deck)
        }

        // Edit button (shown when shaking)
        if (isShaking) {
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .align(Alignment.TopEnd)
                    .offset(x = 12.dp, y = (-6).dp)
                    .zIndex(10f)
            ) {
                IconButton(
                    onClick = {
                        nameEditValue = deck.name
                        descriptionEditValue = deck.description
                        showEditDialog = true
                    },
                    modifier = Modifier
                        .size(42.dp)
                        .align(Alignment.TopEnd)
                        .shadow(8.dp, CircleShape)
                        .background(
                            brush = Brush.radialGradient(
                                colors = listOf(Color.White, Color.White.copy(alpha = 1f))
                            ),
                            shape = CircleShape
                        )
                ) {
                    Icon(
                        imageVector = Icons.Default.Edit,
                        contentDescription = "Edit Deck",
                        tint = Color.Black.copy(alpha = 0.7f),
                        modifier = Modifier.size(24.dp)
                    )
                }
            }
        }
    }

    // Edit Dialog
    if (showEditDialog) {
        EditDeckBottomSheet(
            deck = deck,
            nameEditValue = nameEditValue,
            descriptionEditValue = descriptionEditValue,
            onNameChanged = { nameEditValue = it },
            onDescriptionChanged = { descriptionEditValue = it },
            onSave = { /* no-op, already updated in sheet; keep if you need extra side effects */ },
            onDelete = {
                showEditDialog = false
                showDeleteDialog = true
            },
            onDismiss = { showEditDialog = false },
            viewModel = viewModel
        )
    }

    // Delete Dialog
    if (showDeleteDialog) {
        DeleteConfirmationDialog(
            deck = deck,
            onConfirm = {
                showDeleteDialog = false
                // Handle delete logic
            },
            onCancel = { showDeleteDialog = false },
            viewModel = viewModel
        )
    }
}

@Composable
private fun CardStack(deck: Deck) {
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier.fillMaxSize().aspectRatio(0.5f)
    ) {
        // Background card 1
        Card(
            modifier = Modifier
                .scale(0.90f)
                .fillMaxHeight(0.5f)
                .fillMaxWidth(0.8f)
                .graphicsLayer {
                    translationX = 15.dp.toPx()
                    rotationZ = 11.46f // 0.2 radians in degrees
                },
            shape = RoundedCornerShape(32.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 0.dp),
            border = BorderStroke(0.5.dp, Color.Gray.copy(alpha = 0.4f))
        ) {
            Spacer(modifier = Modifier.size(120.dp, 100.dp))
        }

        // Background card 2
        Card(
            modifier = Modifier
                .scale(0.95f)
                .fillMaxHeight(0.5f)
                .fillMaxWidth(0.8f)
                .graphicsLayer {
                    translationX = (-18).dp.toPx()
                    translationY = 10.dp.toPx()
                    rotationZ = -11.46f // -0.2 radians in degrees
                },
            shape = RoundedCornerShape(32.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
            border = BorderStroke(0.5.dp, Color.Gray.copy(alpha = 0.4f))
        ) {
            Spacer(modifier = Modifier.size(120.dp, 100.dp))
        }

        // Front card
        Card(
            modifier = Modifier
                .fillMaxHeight(0.5f)
                .fillMaxWidth(0.8f),
            shape = RoundedCornerShape(32.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
            border = BorderStroke(0.5.dp, Color.Gray.copy(alpha = 0.4f))
        ) {
            Box(
                modifier = Modifier.fillMaxSize()
                    .padding(8.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "\"${deck.name}\"",
                    textAlign = TextAlign.Center,
                    fontSize = 12.sp,
                    color = Color.Black.copy(alpha = 0.87f),
                    fontWeight = FontWeight.W400,
                    lineHeight = 14.4.sp
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun EditDeckBottomSheet(
    deck: Deck,
    nameEditValue: String,
    descriptionEditValue: String,
    onNameChanged: (String) -> Unit,
    onDescriptionChanged: (String) -> Unit,
    onSave: (Deck) -> Unit,
    onDelete: () -> Unit,
    onDismiss: () -> Unit,
    viewModel: HomeScreenViewModel
) {
    val scope = rememberCoroutineScope()
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        dragHandle = {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(vertical = 8.dp)
            ) {
                Box(
                    modifier = Modifier
                        .width(40.dp)
                        .height(4.dp)
                        .background(Color.Gray.copy(alpha = 0.3f), RoundedCornerShape(2.dp))
                )
            }
        }
    ) {
        val scroll = rememberScrollState()
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 440.dp)          // keep it from going full-screen
                .verticalScroll(scroll)
                .padding(20.dp)
        ) {
            // Header with centered title and a Delete action
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Spacer(Modifier.width(48.dp)) // visual balance with Delete button width

                Text(
                    text = "Edit Deck",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.W600
                )

                TextButton(onClick = onDelete) {
                    Text("Delete", fontSize = 14.sp, color = Color.Red)
                }
            }

            Spacer(Modifier.height(20.dp))

            // Name (Question)
            Text("Question", fontSize = 12.sp, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(
                value = nameEditValue,
                onValueChange = onNameChanged,
                placeholder = { Text("Name") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            )

            Spacer(Modifier.height(16.dp))

            // Description (Answer)
            Text("Answer", fontSize = 12.sp, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(
                value = descriptionEditValue,
                onValueChange = onDescriptionChanged,
                placeholder = { Text("Description") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            )

            Spacer(Modifier.height(24.dp))

            Button(
                onClick = {
                    scope.launch {
                        val updated = deck.copy(
                            name = nameEditValue,
                            description = descriptionEditValue
                        )
                        viewModel.updateDeck(updated)
                        onSave(updated)
                        onDismiss()
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                shape = RoundedCornerShape(24.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color.Blue)
            ) {
                Icon(Icons.Default.Check, contentDescription = null, tint = Color.White)
                Spacer(Modifier.width(8.dp))
                Text("Save changes", color = Color.White, fontWeight = FontWeight.Medium)
            }
        }
    }
}

@Composable
private fun DeleteConfirmationDialog(
    deck: Deck,
    onConfirm: () -> Unit,
    onCancel: () -> Unit,
    viewModel: HomeScreenViewModel
) {
    val scope = rememberCoroutineScope()

    AlertDialog(
        onDismissRequest = onCancel,
        containerColor = Color.White,
        title = {
            Text(
                text = "Confirm Deletion",
                color = Color.Black
            )
        },
        text = {
            Column {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(8.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = Color.Red.copy(alpha = 0.1f)
                    )
                ) {
                    Row(
                        modifier = Modifier.padding(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.Info,
                            contentDescription = null,
                            tint = Color.Red
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "This action cannot be undone.",
                            color = Color.Red,
                            fontSize = 12.sp
                        )
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                Text(
                    text = "Are you sure you want to delete this Deck?",
                    color = Color.Black.copy(alpha = 0.54f)
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    scope.launch {
                        viewModel.deleteDeck(deck)
                        onConfirm()
                    }
                }
            ) {
                Text(
                    text = "Confirm",
                    color = Color.Red
                )
            }
        },
        dismissButton = {
            TextButton(onClick = onCancel) {
                Text(
                    text = "Cancel",
                    color = Color.Black
                )
            }
        }
    )
}