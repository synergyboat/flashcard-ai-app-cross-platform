package com.synergyboat.flashcardAi.presentation.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.core.view.WindowInsetsCompat

@Composable
fun FlashcardBottomActionBar(
    height: Dp = 80.dp, // kBottomNavigationBarHeight + 24 approx.
    leading: (@Composable (() -> Unit))? = null,
    center: (@Composable (() -> Unit))? = null,
    trailing: (@Composable (() -> Unit))? = null
) {
    val view = LocalView.current
    val density = LocalDensity.current

    val insets = WindowInsetsCompat.toWindowInsetsCompat(view.rootWindowInsets)
    val bottomPadding =
        with(density) { insets.getInsets(WindowInsetsCompat.Type.systemBars()).bottom.toDp() }
    val leftPadding =
        with(density) { insets.getInsets(WindowInsetsCompat.Type.systemBars()).left.toDp() }
    val rightPadding =
        with(density) { insets.getInsets(WindowInsetsCompat.Type.systemBars()).right.toDp() }
    val topPadding =
        with(density) { insets.getInsets(WindowInsetsCompat.Type.systemBars()).top.toDp() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                bottom = bottomPadding + 12.dp,
                start = leftPadding + 16.dp,
                end = rightPadding + 16.dp,
                top = topPadding + 8.dp
            ),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        leading?.invoke() ?: Spacer(modifier = Modifier.size(16.dp))
        center?.invoke() ?: Spacer(modifier = Modifier.size(16.dp))
        trailing?.invoke() ?: Spacer(modifier = Modifier.size(16.dp))
    }
}