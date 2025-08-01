package com.synergyboat.flashcardAi.presentation.components.buttons

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun GradientButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    width: Dp = 200.dp,
    height: Dp = 50.dp,
    enabled: Boolean = true,
    gradientColors: List<Color> = listOf(Color(0xFF2196F3), Color(0xFF64B5F6)),
    disabledGradientColors: List<Color> = listOf(Color.Gray, Color.LightGray)
) {
    val appliedColors = if (enabled) gradientColors else disabledGradientColors
    val clickModifier = if (enabled) Modifier.clickable(onClick = onClick) else Modifier

    Box(
        modifier = modifier
            .width(width)
            .height(height)
            .clip(RoundedCornerShape(30.dp))
            .background(
                brush = Brush.verticalGradient(colors = appliedColors)
            )
            .then(clickModifier)
            .shadow(
                elevation = 8.dp,
                shape = RoundedCornerShape(30.dp),
                ambientColor = Color(0xFF448AFF).copy(alpha = 0.4f)
            ),
        contentAlignment = Alignment.Center
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
            }
            Text(
                text = text,
                fontSize = 16.sp,
                color = Color.White
            )
        }
    }
}