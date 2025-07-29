package com.synergyboat.flutterai.presentation.components.buttons

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.LocalIndication
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.*
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TileMode
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun LiquidGradientButton(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    tooltip: String? = null,
    colors: List<Color> = listOf(Color(0xff0c7fff), Color(0xffcbfcff)),
    padding: Dp = 16.dp,
    content: @Composable BoxScope.() -> Unit,
) {
    val gradient = Brush.radialGradient(
        colors = colors,
        center = Offset(0f, -0.8f),
        radius = 380f,
        tileMode = TileMode.Clamp
    )

    Box(
        modifier = modifier
            .shadow(18.dp, CircleShape)
            .clip(CircleShape)
            .background(gradient)
            .border(BorderStroke(0.5.dp, Color.Transparent), CircleShape)
            .clickable(
                interactionSource = MutableInteractionSource(),
                indication = LocalIndication.current,
                onClick = onClick
            )
            .padding(padding),
        contentAlignment = Alignment.Center,
        content = content
    )
}