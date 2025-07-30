package com.synergyboat.flashcardAi.presentation.home

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.PI
import com.synergyboat.flashcardAi.R

@Composable
fun HomeEmptyState() {
    Box(modifier = Modifier.fillMaxSize()) {
        // Center Message
        Text(
            text = "No decks found. \nCreate a new deck to get started.",
            textAlign = TextAlign.Center,
            fontSize = 14.sp,
            color = Color.Black.copy(alpha = 0.54f),
            modifier = Modifier.align(Alignment.Center)
        )

        // Bottom right AI hint and squiggly arrow
        Column(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(bottom = 0.dp, end = 32.dp),
            horizontalAlignment = Alignment.End
        ) {
            Text(
                text = "Generate using AI",
                fontSize = 14.sp,
                color = Color.Black.copy(alpha = 0.38f)
            )

            Spacer(modifier = Modifier.height(16.dp))

            Image(
                painter = painterResource(id = R.drawable.curved_arrow), // You must place this in res/drawable
                contentDescription = "Squiggly Arrow",
                modifier = Modifier
                    .graphicsLayer {
                        scaleX = -1f
                        rotationZ = -(PI / 2.9).toFloat() * (180f / PI.toFloat()) // Convert radians to degrees
                    }
                    .height(80.dp)
                    .alpha(0.25f)
            )
        }
    }
}