# Android Jetpack Compose Flashcard Benchmark App

This is the Android Jetpack Compose implementation of the cross-platform Flashcard Benchmark used to compare real-world UX, runtime behavior, and developer ergonomics across Flutter, React Native, Kotlin/Compose, and SwiftUI. The app keeps feature parity to ensure fair, repeatable comparisons.

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Build and Run](#build-and-run)
- [Benchmarking Workflow](#benchmarking-workflow)
- [Performance Tips](#performance-tips)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Overview

Compose app for generating, organizing, and studying flashcards, with built-in instrumentation for cold start, list rendering, and AI latency. Screens, data flow, and interactions match the sister apps to keep benchmarks comparable.

## Key Features

- **AI deck generation flow**
  - Prompt to deck generation with preview before save
  - Configurable provider boundary for parity with other platforms

- **Deterministic UI surfaces**
  - Reusable components for buttons, cards, grids, bars, and inputs
  - Stable layouts that reduce visual variance during benchmarks

- **Benchmark surfaces**
  - List Render Benchmark to stress composition and scrolling
  - Benchmark History to review prior runs

- **Local persistence**
  - Room database for decks and flashcards
  - Simple repository layer to keep I/O paths comparable

## Tech Stack

- **Language**: Kotlin 1.9+
- **UI**: Jetpack Compose, Material 3
- **DI**: Hilt
- **Persistence**: Room
- **Async**: Kotlin Coroutines, Flows
- **Networking**: OkHttp or Ktor (behind an interface)
- **Build**: Gradle Kotlin DSL, AGP 8.x

## Project Structure

```text
android/
├─ app/
│  ├─ src/main/java/com/synergyboat/flashcardAi/
│  │  ├─ core/
│  │  │  └─ benchmark/          # Frame timing, DB size, execution logging
│  │  ├─ data/
│  │  │  ├─ dao/                # Room DAOs
│  │  │  ├─ entities/           # Room entities
│  │  │  ├─ repository/         # Repositories incl. AI repo
│  │  │  └─ services/
│  │  │     ├─ database/        # Room database
│  │  │     └─ openai/          # OpenAI service boundary
│  │  ├─ domain/
│  │  │  ├─ entities/           # Domain models
│  │  │  ├─ repository/         # Repository contracts
│  │  │  └─ usecase/            # Deck, flashcard, AI use cases
│  │  └─ presentation/
│  │     ├─ components/         # Buttons, cards, containers, inputs
│  │     ├─ benchmark/          # List benchmark + history screens
│  │     ├─ home/               # Home screen + VM
│  │     ├─ deck/               # Deck details + VM
│  │     └─ router/             # AppRouter, Routes
│  ├─ src/main/AndroidManifest.xml
│  └─ build.gradle.kts
├─ build.gradle.kts
├─ settings.gradle.kts
├─ gradle.properties
└─ gradle/wrapper/
```

## Getting Started

### Prerequisites

- Android Studio Ladybug or newer
- JDK 17
- Android SDK with a recent emulator or a physical device

### Setup

```bash
# From repository root or android/ directory
./gradlew --version
./gradlew tasks
```

Open the project in Android Studio and let Gradle sync.

## Configuration

The AI provider key can be injected via `local.properties` or environment variables, then exposed as a `BuildConfig` field.

**Option A: local.properties**

1. Add to `local.properties`:
   ```
   OPENAI_API_KEY=sk-REPLACE_ME
   ```
2. In `app/build.gradle.kts`:
   ```kotlin
   android {
       defaultConfig {
           buildConfigField(
               "String",
               "OPENAI_API_KEY",
               ""${properties["OPENAI_API_KEY"] ?: ""}""
           )
       }
   }
   ```

**Option B: Environment variable passthrough**

Use a Gradle property or CI secret and map to `BuildConfig` similarly. Keep provider calls behind `services/openai` so swapping models or endpoints does not change call sites.

## Build and Run

```bash
# Debug install
./gradlew :app:installDebug

# Launch on device
adb shell am start -n com.synergyboat.flashcardAi/.MainActivity

# Release build
./gradlew :app:assembleRelease
```

APK outputs are under `app/build/outputs/apk/`. Use Android Studio for quick iteration.

## Benchmarking Workflow

Use profileable or release builds for meaningful numbers.

1. **Cold start**
   - Clear app from recents
   - Launch via launcher or `adb shell am start ...`
   - Record first render timestamp and startup logs

2. **List rendering benchmark**
   - Open the List Render Benchmark screen
   - Run predefined list sizes
   - Capture frame times and jank counts from logs

3. **AI latency**
   - Navigate to AI Generate Deck
   - Trigger deck creation with a standard prompt
   - Record request start, response end, and payload size

4. **Repeatability**
   - Fix device conditions: refresh rate, battery range, network
   - Run 3 to 5 iterations and use medians
   - Keep identical prompts and list sizes across platforms

## Performance Tips

- Use `remember` and `derivedStateOf` for stable list item composition
- Avoid heavyweight work in `@Composable` bodies
- Batch DB writes for deck and flashcard inserts
- Prefer immutable models in hot paths
- Keep navigation simple to reduce extraneous recompositions

## Troubleshooting

- **No AI response**: confirm `BuildConfig.OPENAI_API_KEY` is non empty, check network permissions
- **Room migration errors**: clear app data during schema changes in development
- **Jank in list benchmark**: verify item keys, avoid nested scroll where possible
- **Release signing issues**: set up a release keystore or use debug builds for local validation

## License

Add your preferred license if you plan to publish results. For internal usage, add guidelines for sharing benchmark artifacts.

---

## 🙌 Contributions Welcome

See the root [README](../README.md) for contribution guidelines.

---

Built with 💙 using Flutter  
By [SynergyBoat](https://synergyboat.com/?utm_source=github&utm_medium=repo&utm_campaign=flashcard-benchmark)
