# React Native Flashcard Benchmark App

This is the React Native implementation of the cross-platform Flashcard Benchmark. It mirrors the feature set and flows used in the Flutter, Android Jetpack Compose, and Swift iOS apps to enable fair, repeatable comparisons of developer ergonomics, runtime behavior, and user experience.

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Run and Build](#run-and-build)
- [Benchmarking Workflow](#benchmarking-workflow)
- [Performance Tips](#performance-tips)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Overview

React Native app for generating, organizing, and studying flashcards with instrumentation for cold start, list rendering, database row size, and AI round-trip latency. Screens, navigation, data boundaries, and prompts are intentionally kept consistent across platforms to make results comparable.

## Key Features

- **AI deck generation**
  - Prompt to deck flow with preview before saving
  - Provider boundary in `services/ai.ts` for easy model swapping

- **Deterministic UI surfaces**
  - Reusable components for cards, stacks, gradients, and buttons
  - Stable layouts designed for reliable list and gesture benchmarks

- **Built-in benchmarks**
  - List Render Benchmark screen for composition and scroll stress
  - Database row-size calculation and execution duration logging
  - Native frame and memory profilers bridged via custom plugins

- **Local persistence**
  - Lightweight ORM layer with repositories and DAOs for parity

## Tech Stack

- **Runtime**: React Native with TypeScript
- **Navigation and UI**: React Native core, custom components
- **Persistence**: Local database service with simple ORM abstractions
- **AI Integration**: HTTP client behind `services/ai.ts`
- **Native Plugins**: Android and iOS modules for frame and memory profiling
- **Build Tools**: Gradle (Android), Xcode (iOS), Metro bundler, npm

## Project Structure

```text
react-native/
├─ plugins/
│  ├─ android/app/src/main/java/com/anonymous/flashcardaiapp/
│  │  ├─ BenchmarkPackage.java
│  │  ├─ FrameProfilerModule.java
│  │  └─ MemoryProfilerModule.java
│  └─ ios/FlashcardAIApp/
│     ├─ BenchmarkLogger.m
│     ├─ FrameProfiler.{h,m}
│     ├─ MemoryProfiler.{h,m}
│     └─ BenchmarkLooger.swift
├─ src/
│  ├─ components/
│  │  ├─ CardStack.tsx
│  │  ├─ DeckCard.tsx
│  │  ├─ EditFlashcardModal.tsx
│  │  ├─ Flashcard.tsx
│  │  ├─ GradientBackground.tsx
│  │  └─ GradientButton.tsx
│  ├─ config/
│  │  ├─ api.config.ts
│  │  ├─ database.config.ts
│  │  ├─ general.config.ts
│  │  ├─ prompts.config.ts
│  │  └─ theme.config.ts
│  ├─ core/benchmark/
│  │  ├─ getDbRowSize.ts
│  │  ├─ logDbRowSize.ts
│  │  └─ logExecDuration.ts
│  ├─ orm/
│  │  ├─ base-entity.ts
│  │  ├─ base-repository.ts
│  │  ├─ dao/{deck-dao.ts, flashcard-dao.ts}
│  │  ├─ entities/{deck-entity.ts, flashcard-entity.ts}
│  │  ├─ repositories/{deck-repository.ts, flashcard-repository.ts}
│  │  └─ database-service.ts
│  ├─ screens/
│  │  ├─ HomeScreen.tsx
│  │  ├─ DeckDetailsScreen.tsx
│  │  ├─ AIGenerateScreen.tsx
│  │  ├─ ListRenderBenchmarkScreen.tsx
│  │  └─ StudyScreen.tsx
│  ├─ services/
│  │  ├─ ai.ts
│  │  ├─ benchmark-db.ts
│  │  └─ database-orm.ts
│  └─ types/index.ts
├─ android/                    # Native Android project
├─ ios/                        # Native iOS project
├─ package.json
└─ scripts.sh                  # Utility scripts for profiling
```

## Getting Started

### Prerequisites

- Node 18 or newer
- npm 9 or newer
- Xcode 15 or newer for iOS builds
- Android SDK + a device or emulator for Android builds
- CocoaPods for iOS: `sudo gem install cocoapods`

### Install

```bash
npm install
# iOS pods
cd ios && pod install && cd ..
```

## Configuration

The app expects an AI provider key. Keep secrets out of source control.

**Option A - .env via transformer**

1) Create `.env` in the project root:
```
OPENAI_API_KEY=sk-REPLACE_ME
```
2) Use a babel transformer or `react-native-config` to expose the key to JS.
3) Read it in `src/config/api.config.ts`.

**Option B - Static dev config**

Edit `src/config/api.config.ts` for local development only:
```ts
export const API_CONFIG = {
  openaiKey: process.env.OPENAI_API_KEY ?? "sk-REPLACE_ME",
};
```

All network calls should remain behind `services/ai.ts` to preserve parity if the provider changes.

## Run and Build

```bash
# Start Metro
npm start

# Android
npm run android

# iOS
npm run ios
```

Create platform release builds:

```bash
# Android release APK/AAB
cd android && ./gradlew assembleRelease  # or bundleRelease
cd ..

# iOS archive from Xcode or CLI
xcodebuild -scheme react-native -configuration Release -sdk iphoneos archive
```

## Benchmarking Workflow

Use profileable or release builds for meaningful numbers.

1. **Cold start**
   - Quit the app from the switcher
   - Launch cold from the launcher or `xcrun simctl launch` on iOS, `adb shell am start` on Android
   - Capture first render times and startup logs

2. **List rendering benchmark**
   - Open **ListRenderBenchmarkScreen**
   - Run the predefined list sizes
   - Record frame times and dropped frames from logs and native profilers

3. **AI latency**
   - Open **AIGenerateScreen**
   - Trigger deck creation with a standard prompt
   - Record request start, response end, and payload size

4. **Database measurements**
   - Use `core/benchmark/getDbRowSize.ts` and `logDbRowSize.ts` helpers
   - Compare row sizes and execution times across platforms

5. **Native profilers**
   - Android: `plugins/android/.../FrameProfilerModule` and `MemoryProfilerModule`
   - iOS: `plugins/ios/FlashcardAIApp/FrameProfiler` and `MemoryProfiler`
   - Pipe logs to files for side-by-side analysis

Repeat each step 3 to 5 times, use medians, keep device conditions fixed, and reuse identical prompts.

## Performance Tips

- Prefer memoization for heavy components in lists
- Keep item keys stable and avoid unnecessary re-renders
- Batch inserts and updates through repository methods
- Avoid synchronous I/O or JSON parsing in render paths
- Keep navigation simple to reduce reconciliation overhead

## Troubleshooting

- **No AI results**
  Verify `OPENAI_API_KEY` is available in the runtime environment and correctly read by `api.config.ts`.

- **iOS build fails on pods**
  Run `cd ios && pod repo update && pod install`.

- **Android release signing issues**
  Ensure keystore and `gradle.properties` are configured; use debug builds for local validation.

- **Jank on list benchmark**
  Check that list items are lightweight, keys are stable, and heavy work is off the UI thread.

## License

Add your preferred license if you plan to publish results. For internal usage, include guidance for sharing and reviewing benchmark artifacts.

---

## 🙌 Contributions Welcome

See the root [README](../README.md) for contribution guidelines.

---

Built with 💙 using Flutter  
By [SynergyBoat](https://synergyboat.com/?utm_source=github&utm_medium=repo&utm_campaign=flashcard-benchmark)