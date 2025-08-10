package com.synergyboat.flashcardAi.presentation.deck

import android.content.Context
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.BottomAppBar
import androidx.compose.material3.BottomSheetDefaults
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Snackbar
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.entities.Flashcard
import com.synergyboat.flashcardAi.presentation.components.FlashcardAppBar
import com.synergyboat.flashcardAi.presentation.deck.viewModels.DeckDetailsScreenViewModel
import kotlinx.coroutines.launch
import kotlin.math.absoluteValue
import kotlin.math.pow

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DeckDetailsScreen(
    navController: NavController,
    deck: Deck,
    viewModel: DeckDetailsScreenViewModel = hiltViewModel()
) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    // Initialize deck in ViewModel
    LaunchedEffect(deck) {
        viewModel.initializeDeck(deck)
    }

    val flashcards by viewModel.flashcards.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()

    var currentIndex by remember { mutableIntStateOf(0) }
    val swipeOffset = remember { Animatable(0f) }
    var opacity by remember { mutableFloatStateOf(1f) }
    var showEditSheet by remember { mutableStateOf(false) }
    var editingFlashcard by remember { mutableStateOf<Flashcard?>(null) }

    val visibleFlashcards = remember(currentIndex, flashcards) {
        if (flashcards.isEmpty()) emptyList()
        else flashcards.subList(
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
                    if (flashcards.isNotEmpty()) {
                        TextButton(
                            onClick = {
                                editingFlashcard = flashcards[currentIndex]
                                showEditSheet = true
                            },
                            colors = ButtonDefaults.textButtonColors(
                                contentColor = Color(0xFF2196F3)
                            )
                        ) {
                            Text("Edit", fontSize = 16.sp)
                        }
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
                        .padding(16.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFF2196F3)
                    )
                ) {
                    Text("Close", color = Color.White)
                }
            }
        }
    ) { padding ->
        if (!error.isNullOrEmpty())
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center){
            Text(
                "An error occurred! \n ${error ?: "Unknown error"}",
                style = TextStyle(
                    color = Color.Red,
                    fontSize = 16.sp,
                    textAlign = TextAlign.Center
                )
            )
        } else
        Column(
            modifier = Modifier
                .padding(padding)
                .padding(horizontal = 16.dp, vertical = 8.dp)
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Description
            Text(
                text = deck.description.ifEmpty { "No description available" },
                style = MaterialTheme.typography.bodyMedium,
                textAlign = TextAlign.Center,
                color = Color.Gray,
                fontSize = 16.sp
            )
            Spacer(modifier = Modifier.height(16.dp))

            if (flashcards.isEmpty()) {
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "No flashcards available",
                        style = MaterialTheme.typography.bodyLarge,
                        color = Color.Gray
                    )
                }
            } else {
                // Card Stack
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    visibleFlashcards.reversed().forEachIndexed { i, flashcard ->
                        val isTop = i == 0
                        val isSecond = i == 1
                        val offsetY = (i * 12).dp
                        val baseScale = 1f - (i * 0.05f)
                        val z = 3 - i

                        // Calculate adjusted scale for second card during drag
                        val adjustedScale = if (isSecond) {
                            val progress = (swipeOffset.value.absoluteValue / 150f).coerceIn(0f, 1f)
                            baseScale + (1f - baseScale - 0.05f) * progress
                        } else {
                            baseScale
                        }

                        val modifier = Modifier
                            .offset(y = -offsetY)
                            .graphicsLayer {
                                scaleX = adjustedScale
                                scaleY = adjustedScale
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

                        EnhancedFlashcardContent(
                            modifier = modifier,
                            flashcard = flashcard
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "Card ${currentIndex + 1} of ${flashcards.size}",
                    color = Color.Gray,
                    fontSize = 14.sp
                )
            }
        }
    }

    // Edit Modal Bottom Sheet
    if (showEditSheet && editingFlashcard != null) {
        EditFlashcardBottomSheet(
            viewModel = viewModel,
            flashcard = editingFlashcard!!,
            onDismiss = {
                showEditSheet = false
                editingFlashcard = null
            },
            onSave = { flashcard, question, answer ->
//                viewModel.updateFlashcard(flashcard, question, answer)
                showEditSheet = false
                editingFlashcard = null
            },
            onDelete = { flashcard ->
//                viewModel.deleteFlashcard(flashcard)
                if (currentIndex > 0) currentIndex--
                showEditSheet = false
                editingFlashcard = null
            }
        )
    }
}

@Composable
fun EnhancedFlashcardContent(
    modifier: Modifier = Modifier,
    flashcard: Flashcard
) {
    Box(modifier = modifier) {
        // Base white card with shadow
        Card(
            modifier = Modifier.fillMaxSize(),
            shape = RoundedCornerShape(48.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(18.dp)
        ) {}

        // First gradient overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .clip(RoundedCornerShape(48.dp))
        )

        // Second gradient overlay with border
        Box(
            modifier = Modifier
                .fillMaxSize()
                .clip(RoundedCornerShape(48.dp))
                .border(
                    1.dp,
                    Color.Gray.copy(alpha = 0.3f),
                    RoundedCornerShape(48.dp)
                )
                .padding(24.dp)
        ) {
            Column(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.SpaceBetween,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = flashcard.question.orEmpty(),
                    style = MaterialTheme.typography.headlineMedium.copy(
                        fontWeight = FontWeight.Bold,
                        fontSize = 24.sp
                    ),
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(20.dp))

                Text(
                    text = flashcard.answer,
                    style = MaterialTheme.typography.bodyMedium.copy(
                        fontSize = 14.sp
                    ),
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditFlashcardBottomSheet(
    viewModel: DeckDetailsScreenViewModel,
    flashcard: Flashcard,
    onDismiss: () -> Unit,
    onSave: (Flashcard, String, String) -> Unit,
    onDelete: (Flashcard) -> Unit
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    var questionValue by remember { mutableStateOf(flashcard.question.orEmpty()) }
    var answerValue by remember { mutableStateOf(flashcard.answer.orEmpty()) }

    // NEW: state to show/hide the delete dialog
    var showDeleteDialog by remember { mutableStateOf(false) }

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
        },
    ) {
        val scrollState = rememberScrollState()
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 400.dp)
                .verticalScroll(scrollState)
                .padding(20.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Edit Flashcard",
                    style = MaterialTheme.typography.headlineSmall.copy(
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 18.sp
                    )
                )
                TextButton(
                    onClick = { showDeleteDialog = true }, // ← was calling a composable
                    colors = ButtonDefaults.textButtonColors(
                        contentColor = Color(0xFFF44336)
                    )
                ) { Text("Delete", fontSize = 14.sp) }
            }

            Spacer(Modifier.height(20.dp))

            Text("Question", style = MaterialTheme.typography.bodySmall.copy(fontSize = 12.sp))
            OutlinedTextField(
                value = questionValue,
                onValueChange = { questionValue = it },
                placeholder = { Text("Question") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = false,
                maxLines = 3
            )

            Spacer(Modifier.height(16.dp))

            Text("Answer", style = MaterialTheme.typography.bodySmall.copy(fontSize = 12.sp))
            OutlinedTextField(
                value = answerValue,
                onValueChange = { answerValue = it },
                placeholder = { Text("Answer") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = false,
                maxLines = 3
            )

            Spacer(Modifier.height(24.dp))

            Button(
                onClick = { onSave(flashcard, questionValue, answerValue) },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF2196F3)),
                shape = RoundedCornerShape(12.dp)
            ) {
                Icon(Icons.Default.Check, contentDescription = null, tint = Color.White)
                Spacer(Modifier.width(8.dp))
                Text("Save changes", color = Color.White)
            }
        }
    }

    // NEW: render the dialog *in* composition, controlled by state
    if (showDeleteDialog) {
        showDeleteFlashcardDialog(
            viewModel = viewModel,
            flashcard = flashcard,
            onCancel = { showDeleteDialog = false },
            onConfirm = {
                // keep behavior identical: let caller decide what to do
                onDelete(it)
                showDeleteDialog = false
            }
        )
    }
}

@Composable
fun showDeleteFlashcardDialog(
    viewModel: DeckDetailsScreenViewModel,
    flashcard: Flashcard,
    onCancel: () -> Unit,
    onConfirm: (Flashcard) -> Unit
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
//                        viewModel.deleteDeck(deck)
                        onConfirm(flashcard)
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