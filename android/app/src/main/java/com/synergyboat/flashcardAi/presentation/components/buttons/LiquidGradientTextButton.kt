package com.synergyboat.flashcardAi.presentation.components.buttons

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

@Composable
fun LiquidGradientTextButton(
    onClick: () -> Unit,
    colors: List<Color> = listOf(
        Color(0xFF0C7FFF),
        Color(0xFF2794E5)
    ),
    content: @Composable () -> Unit
) {
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .sizeIn(minWidth = 56.dp)
            .height(56.dp)
            .shadow(
                elevation = 18.dp,
                shape = CircleShape,
                ambientColor = Color.Blue.copy(alpha = 0.6f),
                spotColor = Color.Blue.copy(alpha = 0.6f)
            )
            .background(
                brush = Brush.verticalGradient(colors = colors),
                shape = CircleShape
            )
            .border(
                width = 0.5.dp,
                color = Color.Blue.copy(alpha = 0f),
                shape = CircleShape
            )
            .clickable(onClick = onClick)
    ) {
        content()
    }
}
