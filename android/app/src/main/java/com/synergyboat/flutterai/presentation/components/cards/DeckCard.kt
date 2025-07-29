package com.synergyboat.flutterai.presentation.components.cards

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.sp
import com.synergyboat.flutterai.domain.entities.Deck
import com.synergyboat.flutterai.presentation.components.modifiers.noRippleClickable

@Composable
fun DeckCard(
    deck: Deck,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .padding(16.dp)
            .aspectRatio(0.85f) // Enforce aspect ratio here
            .noRippleClickable { onClick() }, // Custom modifier to disable ripple
        contentAlignment = Alignment.Center
    ) {

        Card(
            modifier = Modifier
                .scale(0.9f)
                .offset(x = 15.dp)
                .rotate(11.5f),
            shape = RoundedCornerShape(32.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            border = BorderStroke(0.5.dp, Color.Gray.copy(alpha = 0.4f)),
            elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
        ) {
            Box(modifier = Modifier.fillMaxSize())
        }

        Card(
            modifier = Modifier
                .scale(0.95f)
                .offset(x = (-10).dp, y = 10.dp)
                .rotate(-11.5f),
            shape = RoundedCornerShape(32.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            border = BorderStroke(0.5.dp, Color.Gray.copy(alpha = 0.4f)),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
        ) {
            Box(modifier = Modifier.fillMaxSize())
        }

        Card(
            shape = RoundedCornerShape(32.dp),
            border = BorderStroke(0.5.dp, Color.Gray.copy(alpha = 0.4f)),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(8.dp)
            ) {
                Text(
                    text = "\"${deck.name}\"",
                    fontSize = 12.sp,
                    color = Color.Black.copy(alpha = 0.87f),
                    fontWeight = FontWeight.W400,
                    textAlign = TextAlign.Center,
                    lineHeight = 16.sp
                )
            }
        }
    }
}