package com.synergyboat.flashcardAi.presentation.deck

import android.widget.Toast
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.synergyboat.flashcardAi.presentation.components.FlashcardAppBar
import com.synergyboat.flashcardAi.presentation.components.buttons.GradientButton
import com.synergyboat.flashcardAi.presentation.deck.viewModels.AIGenerateDeckViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AIGenerateDeckScreen(
    navController: NavController,
    viewModel: AIGenerateDeckViewModel = hiltViewModel()
) {
    val context = LocalContext.current
    viewModel.promptText
    val isGenerating = viewModel.isGenerating
    viewModel.numberOfCards

    Scaffold(
        topBar = {
            FlashcardAppBar(navController = navController)
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(horizontal = 16.dp, vertical = 8.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text("Generate Deck with AI", fontSize = 24.sp, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                "Enter a prompt to generate a deck of flashcards. The AI will create a deck based on your input.",
                fontSize = 12.sp,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(32.dp))

            Card(
                modifier = Modifier.fillMaxWidth(),
                elevation = CardDefaults.cardElevation(10.dp)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    OutlinedTextField(
                        value = viewModel.promptText,
                        onValueChange = { viewModel.promptText = it },
                        placeholder = { Text("Enter your prompt here") },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Select number of cards", fontSize = 12.sp)

                        val expanded = remember { mutableStateOf(false) }

                        Box {
                            Text(
                                text = "${viewModel.numberOfCards} Cards",
                                modifier = Modifier
                                    .clickable { expanded.value = true }
                                    .padding(8.dp),
                                fontSize = 16.sp
                            )
                            DropdownMenu(
                                expanded = expanded.value,
                                onDismissRequest = { expanded.value = false }
                            ) {
                                listOf(5, 10, 15, 20).forEach { count ->
                                    DropdownMenuItem(
                                        text = { Text("$count") },
                                        onClick = {
                                            viewModel.numberOfCards = count
                                            expanded.value = false
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(64.dp))
            GradientButton(
                text = "Generate Deck",
                onClick = {
                    viewModel.generateDeck(
                        onSuccess = { deck ->
                            Toast.makeText(
                                context,
                                "Deck generated successfully!",
                                Toast.LENGTH_SHORT
                            ).show()
                            navController.navigate("deck_preview/${deck.id}")
                        }
                    )
                },
                icon = Icons.Default.AutoAwesome, // Optional icon
                enabled = !isGenerating,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp)
            )
        }
    }
}