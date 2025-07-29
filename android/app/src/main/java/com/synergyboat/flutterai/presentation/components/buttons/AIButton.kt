package com.synergyboat.flutterai.presentation.components.buttons

import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AutoAwesome
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

@Composable
fun AIButton(
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    LiquidGradientButton(
        onClick = onClick,
        modifier = modifier,
        tooltip = "Generate using AI"
    ) {
        Icon(
            imageVector = Icons.Outlined.AutoAwesome,
            contentDescription = "AI Sparkle",
            tint = Color.White,
            modifier = Modifier.size(24.dp)
        )
    }
}