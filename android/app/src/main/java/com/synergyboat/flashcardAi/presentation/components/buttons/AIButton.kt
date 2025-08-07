package com.synergyboat.flashcardAi.presentation.components.buttons

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AutoAwesome
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.graphics.Color

@Composable
fun AIButton(
    modifier: Modifier = Modifier,
    showText: Boolean = false,
    onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .height(56.dp),
        contentAlignment = Alignment.CenterStart
    ) {
        LiquidGradientTextButton(
            onClick = onClick,
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Start,
                modifier = Modifier.padding(horizontal = 8.dp)
            ) {
                Icon(
                    imageVector = Icons.Rounded.AutoAwesome,
                    contentDescription = "Sparkles Icon",
                    tint = Color.White,
                    modifier = Modifier.size(24.dp)
                )
                if (showText) {
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Generate with AI",
                        color = Color.White,
                        fontSize = 16.sp
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                }
            }
        }
    }
}