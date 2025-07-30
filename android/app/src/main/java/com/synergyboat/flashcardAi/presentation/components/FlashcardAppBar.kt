package com.synergyboat.flashcardAi.presentation.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.*
import androidx.core.view.WindowInsetsCompat
import androidx.navigation.NavController

@Composable
fun FlashcardAppBar(
    navController: NavController,
    title: String? = null,
    leadingContent: (@Composable (() -> Unit))? = null,
    actions: (@Composable RowScope.() -> Unit)? = null,
    height: Dp = 56.dp,
) {
    val route = navController.currentDestination?.route ?: "/"
    val defaultTitle = when (route) {
        "/" -> "Home"
        "deck" -> "Your Decks"
        "settings" -> "Settings"
        else -> "Flashcard AI"
    }

    val resolvedTitle = title ?: defaultTitle
    val view = LocalView.current
    val topPadding = with(LocalDensity.current) {
        WindowInsetsCompat.toWindowInsetsCompat(view.rootWindowInsets)
            .getInsets(WindowInsetsCompat.Type.statusBars()).top.toDp()
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(height + topPadding + 24.dp)
            .padding(top = topPadding)
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            // Center title
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.Center),
                horizontalArrangement = Arrangement.Center
            ) {
                Text(
                    text = resolvedTitle,
                    style = MaterialTheme.typography.titleMedium.copy(
                        color = Color.Black,
                        fontWeight = FontWeight.Medium
                    )
                )
            }

            // Leading & actions
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(height),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (leadingContent != null) {
                    leadingContent()
                } else if (navController.previousBackStackEntry != null) {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = Color.Black)
                    }
                } else {
                    Spacer(modifier = Modifier.width(16.dp))
                }

                if (actions != null) {
                    Row(content = actions)
                } else {
                    Spacer(modifier = Modifier.width(16.dp))
                }
            }
        }
    }
}