package com.synergyboat.flashcardAi.presentation.home

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.synergyboat.flashcardAi.presentation.components.buttons.AIButton

@Composable
fun HomeEmptyState(
    onGenerateClicked: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 16.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "No decks found. \nCreate a new deck to get started.",
                fontSize = 14.sp,
                color = Color.Black.copy(alpha = 0.54f),
                textAlign = TextAlign.Center
            )
            Spacer(modifier = Modifier.height(24.dp))
            AIButton(
                showText = true,
                onClick = onGenerateClicked
            )
        }
    }
}