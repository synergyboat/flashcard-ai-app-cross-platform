package com.synergyboat.flashcardAi.presentation.benchmark

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material3.AssistChip
import androidx.compose.material3.AssistChipDefaults
import androidx.compose.material3.DividerDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kotlin.math.min

private const val TARGET_FRAME_MS = 16.67
private const val ITEM_HEIGHT = 80

@RequiresApi(Build.VERSION_CODES.O)
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BenchmarkHistoryScreen(results: List<BenchmarkResult>) {
    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Benchmark History") })
        }
    ) { padding ->
        if (results.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
                Text("No benchmark data available")
            }
        } else {
            LazyColumn(modifier = Modifier.padding(padding)) {
                itemsIndexed(results) { index, result ->
                    ExpansionTileCompose(index, result)
                    HorizontalDivider(Modifier, DividerDefaults.Thickness, DividerDefaults.color)
                }
            }
        }
    }
}

@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun ExpansionTileCompose(index: Int, result: BenchmarkResult) {
    var expanded by remember { mutableStateOf(false) }
    Column(modifier = Modifier
        .fillMaxWidth()
        .padding(8.dp)
        .background(Color(0xFFF5F5F5), MaterialTheme.shapes.medium)) {
        ListItem(
            headlineContent = {
                Text("Iteration ${index + 1} - ${java.time.Instant.ofEpochMilli(result.timestamp).toString().split("T")[0]}", fontWeight = FontWeight.Bold)
            },
            supportingContent = {
                Text("Avg Frame: ${"%.2f".format(result.averageFrameTimeMs)}ms | FPS: ${"%.1f".format(result.actualFps)} | Mem Δ: ${"%.2f".format(result.memoryDeltaMB)}MB | Frames: ${result.frameTimesMs.size}", style = MaterialTheme.typography.bodySmall)
            },
            trailingContent = {
                IconButton(onClick = { expanded = !expanded }) {
                    Icon(if (expanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore, contentDescription = null)
                }
            }
        )
        if (expanded) {
            Column(modifier = Modifier.padding(16.dp)) {
                StatRow("⏱️ Time to First Frame", "${result.timeToFirstFrame} ms")
                StatRow("📊 Avg Frame Time", "${"%.2f".format(result.averageFrameTimeMs)} ms")
                StatRow("🎯 P95 Frame Time", "${"%.2f".format(result.p95FrameTimeMs)} ms")
                StatRow("⚠️ Dropped Frames", "${"%.2f".format(result.droppedFramesPercent)}%")
                StatRow("🧠 Memory Delta", "${"%.2f".format(result.memoryDeltaMB)} MB")
                StatRow("💡 Performance Grade", result.performanceGrade)
                Spacer(modifier = Modifier.height(8.dp))
                Text("Frame Durations (ms):", fontWeight = FontWeight.Bold)
                FlowRow {
                    buildWindowedFrameChips(result, windowSize = 5)
                }
            }
        }
    }
}

@Composable
fun StatRow(label: String, value: String) {
    Row(modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp)) {
        Text(label, fontWeight = FontWeight.Medium)
        Spacer(modifier = Modifier.weight(1f))
        Text(value)
    }
}

@Composable
fun FlowRow(content: @Composable RowScope.() -> Unit) {
    Column {
        Row(modifier = Modifier.fillMaxWidth().wrapContentHeight(), content = content)
    }
}

@Composable
fun buildWindowedFrameChips(result: BenchmarkResult, windowSize: Int = 5) {
    val frames = result.frameTimesMs
    val windowedAverages = mutableListOf<Double>()
    for (i in frames.indices step windowSize) {
        val window = frames.subList(i, min(i + windowSize, frames.size))
        val avg = window.average()
        windowedAverages.add(avg)
    }
    windowedAverages.forEach { avg ->
        AssistChip(
            onClick = {},
            label = { Text("${"%.1f".format(avg)}") },
            colors = if (avg > result.targetFrameTimeMs * 1.5) AssistChipDefaults.assistChipColors(containerColor = Color.Red.copy(alpha = 0.2f))
            else AssistChipDefaults.assistChipColors(containerColor = Color.Green.copy(alpha = 0.2f)),
            modifier = Modifier.padding(end = 4.dp, bottom = 4.dp)
        )
    }
}

// Existing ListRenderBenchmarkScreen and other logic remains the same from previous code
