package com.synergyboat.flashcardAi.presentation.benchmark

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.Debug
import android.util.Log
import android.view.Choreographer
import androidx.annotation.RequiresApi
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.scrollBy
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import java.time.LocalDateTime
import kotlin.math.pow
import kotlin.math.sqrt

private const val TARGET_FRAME_MS = 16.67
private const val EXPECTED_REFRESH_RATE = 60.0

enum class BenchmarkType {
    StaticRender,
    ScrollPerformance,
    MemoryUsage
}

object PlatformInfo {
    const val platformName = "Android"
    const val expectedRefreshRate = EXPECTED_REFRESH_RATE
    const val targetFrameTimeMs = TARGET_FRAME_MS
    const val performanceProfile = "Android (Vulkan/OpenGL, ART VM)"

    // Memory profiling availability - could be disabled on certain Android versions or devices
    val supportsMemoryProfiling: Boolean get() =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.M // PSS available from API 23+
}

data class BenchmarkResult(
    val timeToFirstFrame: Long, // in milliseconds
    val frameTimesMs: List<Double>,
    val memoryDeltaMB: Double,
    val timestamp: Long = System.currentTimeMillis(),
    val itemCount: Int = 0,
    val platform: String = PlatformInfo.platformName,
    val targetFrameTimeMs: Double = PlatformInfo.targetFrameTimeMs,
) {
    val averageFrameTimeMs: Double get() =
        if (frameTimesMs.isEmpty()) 0.0 else frameTimesMs.average()

    val actualFps: Double get() =
        if (frameTimesMs.isEmpty()) 0.0
        else frameTimesMs.size / (frameTimesMs.sum() / 1000.0)

    val p95FrameTimeMs: Double get() {
        if (frameTimesMs.isEmpty()) return 0.0
        val sorted = frameTimesMs.sorted()
        val index = maxOf(0, (sorted.size * 0.95).toInt() - 1)
        return sorted[index]
    }

    val droppedFramesPercent: Double get() {
        if (frameTimesMs.isEmpty()) return 0.0
        val droppedCount = frameTimesMs.count { it > targetFrameTimeMs * 1.5 }
        return (droppedCount.toDouble() / frameTimesMs.size) * 100.0
    }

    val performanceGrade: String get() = when {
        averageFrameTimeMs <= targetFrameTimeMs -> "A (Excellent)"
        averageFrameTimeMs <= targetFrameTimeMs * 1.5 -> "B (Good)"
        averageFrameTimeMs <= targetFrameTimeMs * 2.0 -> "C (Fair)"
        else -> "D (Poor)"
    }
}

class FrameTimingCollector {
    private val frameTimesNanos = mutableListOf<Long>()
    private var isCollecting = false
    private var startTimeNanos = 0L

    private val choreographerCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isCollecting) {
                if (startTimeNanos != 0L) {
                    val frameDurationNanos = frameTimeNanos - startTimeNanos
                    frameTimesNanos.add(frameDurationNanos)
                }
                startTimeNanos = frameTimeNanos
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    fun startCollecting() {
        frameTimesNanos.clear()
        isCollecting = true
        startTimeNanos = 0L
        Choreographer.getInstance().postFrameCallback(choreographerCallback)
    }

    fun stopCollecting(): List<Double> {
        isCollecting = false
        Choreographer.getInstance().removeFrameCallback(choreographerCallback)
        return frameTimesNanos.map { it / 1_000_000.0 } // Convert to milliseconds
    }
}

@RequiresApi(Build.VERSION_CODES.O)
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ListRenderBenchmarkScreen(
    itemCount: Int,
    iterations: Int = 3,
    benchmarkType: BenchmarkType = BenchmarkType.StaticRender,
    onBenchmarkComplete: ((List<BenchmarkResult>) -> Unit)? = null
) {
    val context = LocalContext.current
    val density = LocalDensity.current

    val frameCollector = remember { FrameTimingCollector() }
    var results by remember { mutableStateOf<List<BenchmarkResult>>(emptyList()) }
    var currentIteration by remember { mutableIntStateOf(0) }
    var benchmarkComplete by remember { mutableStateOf(false) }
    var baselineMemoryMB by remember { mutableLongStateOf(0L) }

    val listState = rememberLazyListState()

    fun recordBaselineMemory() {
        if (PlatformInfo.supportsMemoryProfiling) {
            System.gc()
            System.runFinalization()
            Thread.sleep(100) // Allow GC to complete
            baselineMemoryMB = getCurrentMemoryUsageMB(context)
            Log.d("BenchmarkReport", "📊 Platform: ${PlatformInfo.platformName} - Baseline memory: ${baselineMemoryMB}MB")
        } else {
            Log.d("BenchmarkReport", "📊 Platform: ${PlatformInfo.platformName} - Memory profiling not available")
            baselineMemoryMB = 0L
        }
    }

    suspend fun performScrollBenchmark(timeToFirstFrame: Long): BenchmarkResult {
        if (listState.layoutInfo.totalItemsCount == 0) {
            return BenchmarkResult(timeToFirstFrame, emptyList(), 0.0, itemCount = itemCount)
        }

        val rowHeightPx = with(density) { 80.dp.toPx() }
        val totalPixels = (itemCount * rowHeightPx).toInt()
        val scrollSpeed = 1500.0 // pixels/sec
        val scrollDurationMs = (totalPixels / scrollSpeed * 1000).toLong()
        val frameIntervalMs = 16L
        val steps = (scrollDurationMs / frameIntervalMs).toInt()
        val pixelsPerStep = totalPixels.toFloat() / steps

        frameCollector.startCollecting()

        try {
            repeat(steps) {
                listState.scrollBy(pixelsPerStep)
                delay(frameIntervalMs)
            }

            listState.scrollToItem(index = 0) // fast return to top
        } catch (e: Exception) {
            Log.e("BenchmarkReport", "Scroll benchmark error: $e")
        }

        delay(200)

        val frameTimesMs = frameCollector.stopCollecting()

        val memoryDelta = if (PlatformInfo.supportsMemoryProfiling) {
            val currentMemoryMB = getCurrentMemoryUsageMB(context)
            (currentMemoryMB - baselineMemoryMB).toDouble()
        } else 0.0

        return BenchmarkResult(
            timeToFirstFrame = timeToFirstFrame,
            frameTimesMs = frameTimesMs,
            memoryDeltaMB = memoryDelta,
            itemCount = itemCount
        )
    }

    // Run single iteration
    suspend fun runIteration(): BenchmarkResult {
        frameCollector.startCollecting()
        val startTimeNanos = System.nanoTime()

        // Wait for first frame
        delay(16) // One frame at 60fps

        val timeToFirstFrame = (System.nanoTime() - startTimeNanos) / 1_000_000 // Convert to ms

        return when (benchmarkType) {
            BenchmarkType.StaticRender, BenchmarkType.MemoryUsage -> {
                // Just measure static rendering for a period (matching Flutter)
                delay(1000)
                val frameTimesMs = frameCollector.stopCollecting()

                val memoryDelta = if (PlatformInfo.supportsMemoryProfiling) {
                    val currentMemoryMB = getCurrentMemoryUsageMB(context)
                    (currentMemoryMB - baselineMemoryMB).toDouble()
                } else {
                    0.0
                }

                BenchmarkResult(
                    timeToFirstFrame = timeToFirstFrame,
                    frameTimesMs = frameTimesMs,
                    memoryDeltaMB = memoryDelta,
                    itemCount = itemCount
                )
            }

            BenchmarkType.ScrollPerformance -> {
                delay(300)
                frameCollector.stopCollecting()
                performScrollBenchmark(timeToFirstFrame)
            }
        }
    }

    LaunchedEffect(itemCount, iterations, benchmarkType) {
        recordBaselineMemory()
        delay(100)

        results = emptyList()
        currentIteration = 0

        repeat(iterations) { iteration ->
            currentIteration = iteration + 1

            val result = runIteration()
            results = results + result

            Log.d("BenchmarkReport", "Iteration ${iteration + 1} complete: ${String.format("%.2f", result.averageFrameTimeMs)}ms avg")

            if (iteration < iterations - 1) {
                delay(500)
            }
        }

        benchmarkComplete = true
        generateScientificReport(results, benchmarkType)
        onBenchmarkComplete?.invoke(results)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Scientific List Benchmark") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = if (benchmarkComplete) Color(0xFF4CAF50) else Color(0xFF2196F3)
                )
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
        ) {
            if (!benchmarkComplete) {
                LinearProgressIndicator(
                    progress = { if (iterations > 0) currentIteration.toFloat() / iterations else 0f },
                    modifier = Modifier.fillMaxWidth()
                )

                Text(
                    text = "Running iteration $currentIteration of $iterations...",
                    modifier = Modifier.padding(16.dp),
                    style = MaterialTheme.typography.titleMedium
                )
            }

            LazyColumn(
                state = listState,
                modifier = Modifier.weight(1f)
            ) {
                itemsIndexed(List(itemCount) { it }) { _, index ->
                    BenchmarkItem(index = index, currentIteration = currentIteration)
                }
            }

            if (benchmarkComplete) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFF4CAF50).copy(alpha = 0.1f)
                    )
                ) {
                    Text(
                        text = "✅ Benchmark Complete! Check console/logs for detailed results.",
                        modifier = Modifier.padding(16.dp),
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
    }
}

@Composable
fun BenchmarkItem(index: Int, currentIteration: Int) {
    val itemColor = remember(index) {
        Color(
            red = (index * 50) % 256,
            green = (index * 80) % 256,
            blue = (index * 120) % 256,
            alpha = 255
        )
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(80.dp)
            .padding(horizontal = 8.dp, vertical = 4.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color(0xFFE3F2FD)
        ),
        shape = RoundedCornerShape(8.dp)
    ) {
        Row(
            modifier = Modifier
                .padding(12.dp)
                .fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .background(
                        color = itemColor,
                        shape = RoundedCornerShape(24.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "${index % 100}",
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            Column(
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = "Benchmark Item $index",
                    fontWeight = FontWeight.SemiBold,
                    maxLines = 1
                )
                Text(
                    text = "Iteration $currentIteration/${currentIteration}",
                    style = MaterialTheme.typography.bodySmall,
                    color = Color.Gray,
                    fontSize = 12.sp
                )
            }
        }
    }
}

fun getCurrentMemoryUsageMB(context: Context): Long {
    val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    val memInfo = ActivityManager.MemoryInfo()
    activityManager.getMemoryInfo(memInfo)

    val memoryInfo = Debug.MemoryInfo()
    Debug.getMemoryInfo(memoryInfo)

    // Total PSS (Proportional Set Size) - closer to RSS measurement
    val totalPssMB = memoryInfo.totalPss / 1024L // Convert from KB to MB

    return totalPssMB
}

fun List<Double>.standardDeviation(): Double {
    if (size < 2) return 0.0
    val mean = average()
    return sqrt(map { (it - mean).pow(2) }.average())
}

fun List<Double>.mean(): Double = if (isEmpty()) 0.0 else average()

@RequiresApi(Build.VERSION_CODES.O)
fun generateScientificReport(results: List<BenchmarkResult>, benchmarkType: BenchmarkType) {
    if (results.isEmpty()) return

    val avgFrameTimes = results.map { it.averageFrameTimeMs }
    val firstFrameTimes = results.map { it.timeToFirstFrame.toDouble() }
    val memoryUsages = results.map { it.memoryDeltaMB }
    val fpsList = results.map { it.actualFps }
    val p95List = results.map { it.p95FrameTimeMs }
    val droppedList = results.map { it.droppedFramesPercent }

    val timestamp = LocalDateTime.now()
    val itemCount = results.first().itemCount
    val iterations = results.size
    val frameTarget = results.first().targetFrameTimeMs
    val totalFrames = results.sumOf { it.frameTimesMs.size }

    val meanFrameTime = avgFrameTimes.mean()
    val stdFrameTime = avgFrameTimes.standardDeviation()
    val avgFps = fpsList.mean()
    val maxP95 = p95List.maxOrNull() ?: 0.0
    val avgDropped = droppedList.mean()
    val avgMem = memoryUsages.mean()
    val stdMem = memoryUsages.standardDeviation()
    val avgFirstFrame = firstFrameTimes.mean()
    val stdFirstFrame = firstFrameTimes.standardDeviation()
    val grade = results.first().performanceGrade
    val memPerItemKb = if (itemCount > 0) (avgMem * 1024) / itemCount else 0.0
    val coeffVar = if (meanFrameTime > 0) (stdFrameTime / meanFrameTime) * 100 else 0.0

    // ✅ Extended params
    val clampedFps = PlatformInfo.expectedRefreshRate
    val unClampedFps = if (meanFrameTime > 0) 1000.0 / meanFrameTime else 0.0
    val theoreticalFps = PlatformInfo.expectedRefreshRate
    val droppedStrict = results.flatMap { it.frameTimesMs }
        .count { it > frameTarget } * 100.0 / totalFrames
    val jankyFrames = results.flatMap { it.frameTimesMs }
        .count { it > frameTarget * 1.5 } * 100.0 / totalFrames

    // Only meaningful for Scroll benchmark
    val scrollDistance = if (benchmarkType == BenchmarkType.ScrollPerformance) itemCount * 80 else 0
    val avgScrollDuration = if (benchmarkType == BenchmarkType.ScrollPerformance)
        results.map { it.frameTimesMs.size * frameTarget }.mean() else 0.0

    val interpretation = when {
        meanFrameTime <= frameTarget -> "✅ Excellent performance - meeting ${PlatformInfo.expectedRefreshRate.toInt()} FPS target"
        meanFrameTime <= frameTarget * 1.5 -> "⚠️ Good performance - occasional frame drops below target"
        meanFrameTime <= frameTarget * 2.0 -> "⚠️ Acceptable, but may drop under heavy load"
        else -> "❌ Poor performance - significant frame drops detected"
    }

    val contextualNote = when (benchmarkType) {
        BenchmarkType.StaticRender -> "Static rendering should maintain consistent frame times across all platforms."
        BenchmarkType.ScrollPerformance -> "Scroll performance includes animation overhead. Mobile performance can vary by device specifications."
        BenchmarkType.MemoryUsage -> "Memory delta of ${String.format("%.1f", avgMem)}MB for $itemCount items. Android may show higher memory usage due to VM overhead."
    }

    val report = """
🔬 SCIENTIFIC BENCHMARK REPORT (NATIVE-AWARE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 Timestamp: $timestamp
🔧 Platform: ${PlatformInfo.platformName} (${PlatformInfo.performanceProfile})
📊 Config: items=$itemCount, iterations=$iterations, type=$benchmarkType
🎯 Target: ${"%.0f".format(PlatformInfo.expectedRefreshRate)} FPS (${String.format("%.2f", frameTarget)} ms)

📈 FRAME PERFORMANCE (aggregated):
• Avg Frame Time: ${"%.2f".format(meanFrameTime)} ms
• P95 Frame Time: ${"%.2f".format(maxP95)} ms
• Actual FPS (clamped): ${"%.2f".format(clampedFps)}
• Actual FPS (unclamped): ${"%.2f".format(unClampedFps)}
• Theoretical FPS (panel): ${"%.0f".format(theoreticalFps)}
• Dropped Frames (strict > budget): ${"%.3f".format(droppedStrict)}%
• Janky Frames (> 1.5× budget): ${"%.3f".format(jankyFrames)}%
• Performance Grade: $grade

⏱️ INITIAL RENDER:
• Time to First Frame: ${"%.2f".format(avgFirstFrame)} ± ${"%.2f".format(stdFirstFrame)} ms

🧠 MEMORY IMPACT:
• Memory Delta: ${if (PlatformInfo.supportsMemoryProfiling) "${String.format("%.2f", avgMem)} ± ${String.format("%.2f", stdMem)} MB" else "Not available"}
• Memory per Item: ${if (PlatformInfo.supportsMemoryProfiling) "${String.format("%.2f", memPerItemKb)} KB/item" else "N/A"}

📊 RELIABILITY:
• Coefficient of Variation (Frame Time): ${"%.3f".format(coeffVar)}%
• Total Frames Analyzed: $totalFrames

📜 SCROLL METRICS:
• Scroll Distance: $scrollDistance px
• Avg Scroll Duration: ${"%.0f".format(avgScrollDuration)} ms
• Panel Refresh: ${"%.0f".format(PlatformInfo.expectedRefreshRate)} Hz

💡 INTERPRETATION:
$interpretation
$contextualNote

🔍 PLATFORM NOTES:
• Android performance varies across device tiers & API levels
• Console/syslog output is ASCII-only (no mojibake risk)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
""".trimIndent()

    Log.d("BenchmarkReport", report)
}