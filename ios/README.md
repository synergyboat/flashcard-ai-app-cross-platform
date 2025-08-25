# Swift iOS Flashcard Benchmark App

This repository contains the **native Swift UIKit** implementation of the Flashcard Benchmark used to compare realistic UX, runtime behavior, and developer ergonomics across Flutter, React Native, Kotlin Compose, and Swift iOS. This iOS app intentionally mirrors features and flows in the sibling projects to keep the benchmark apples-to-apples.

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

A UIKit app for generating, organizing, and studying flashcards with **built-in instrumentation** for cold start, list rendering, and AI round-trip latency. Screen flows, data shapes, and interactions are kept **feature-parity** with the other platform implementations to ensure repeatable, comparable numbers.

## Key Features

- **AI deck generation flow**
  - Prompt to deck generation with preview and confirmation
  - Provider boundary via `AIService` for parity across platforms

- **Deterministic UI surfaces**
  - Reusable `UIView` components for cards, gradients, and buttons
  - Stable layouts to reduce variance during scroll and compose benchmarks

- **Benchmark surfaces**
  - Row size and list rendering benchmark screens
  - Execution and DB size loggers to capture measurements

- **Local persistence**
  - Lightweight database service for decks and flashcards
  - Simple repository-style access to keep I/O paths comparable

## Tech Stack

- **Language**: Swift 5.9+
- **UI**: UIKit with Storyboards
- **Concurrency**: GCD and main-thread orchestration
- **Logging**: Unified logging with OSLog signposts
- **Build**: Xcode 15+, iOS 16+ target

## Project Structure

```text
FlashcardAI/
├─ Config/                  # API keys, prompts, theme, app config
├─ Core/Benchmark/          # DbSizeLogger, ExecutionLogger, RowSizeBenchmark
├─ Models/                  # Domain models for Deck and Flashcard
├─ Services/                # AIService, DatabaseService
├─ ViewControllers/         # Home, Deck Details, AI Generate, Preview, Study, Benchmark
├─ Views/                   # Reusable UI components like GradientButton, FlashcardView
├─ Base.lproj/              # Main.storyboard, LaunchScreen.storyboard
├─ Assets.xcassets/         # AppIcon and colors
└─ AppDelegate.swift, SceneDelegate.swift, Info.plist
```

## Getting Started

### Prerequisites

- Xcode 15 or newer
- iOS 16 SDK or newer
- A physical device or iOS Simulator

### Setup

1. Open `FlashcardAI.xcodeproj` or `FlashcardAI.xcworkspace` in Xcode.
2. Select the **FlashcardAI** scheme.
3. Confirm signing is set to your team for device builds.

## Configuration

The AI provider key is managed behind `AIService` and `Config` files for clean parity.

**Option A: Hardcoded in `APIConfig.swift` for local runs**  
Edit the placeholder and avoid committing secrets:

```swift
enum APIConfig {
    static let openAIKey: String = "sk-REPLACE_ME"
}
```

**Option B: Xcode Scheme Environment Variable**  
1. Edit Scheme → Run → Arguments → Environment Variables.  
2. Add `OPENAI_API_KEY` and read it from `ProcessInfo.processInfo.environment` inside `AIService`.

Keep all network specifics behind `AIService` so swapping models or providers does not impact call sites.

## Build and Run

Using Xcode:
1. Select a simulator or device.
2. Hit **Run**.

Using CLI:

```bash
# Clean build for Debug
xcodebuild -scheme FlashcardAI -configuration Debug -sdk iphonesimulator clean build

# Archive for Release (codesigning required for device)
xcodebuild -scheme FlashcardAI -configuration Release -sdk iphoneos archive -archivePath build/FlashcardAI.xcarchive
```

App artifacts will be available under `build/` or through Xcode’s Organizer.

## Benchmarking Workflow

Use Release or Profile builds for meaningful numbers.

1. **Cold start**
   - Kill the app from the switcher
   - Launch from SpringBoard or via `xcrun simctl launch`
   - Record first-render and startup timestamps from logs

2. **List rendering benchmark**
   - Open the Benchmark screen
   - Run predefined list sizes
   - Capture frame times, dropped frames, and jank counts from Instruments

3. **AI latency**
   - Navigate to AI Generate Deck
   - Trigger deck creation with a standard prompt
   - Record request start, response end, and payload sizes in logs

4. **Repeatability**
   - Fix device conditions: low notifications, stable network, consistent refresh rate
   - Run 3 to 5 iterations and use medians
   - Keep prompts, list sizes, and dataset identical across platforms

### Suggested Instruments

- **Time Profiler** for CPU hot paths
- **Core Animation** for frame pacing
- **OSLog/Points of Interest** to correlate signposts with UI phases

## Performance Tips

- Reuse cells and views, prefer explicit `prepareForReuse`
- Avoid heavy work on the main thread during scrolling
- Batch DB reads and writes, prefer background queues for I/O
- Cache images and expensive gradients
- Use lightweight view hierarchies and avoid over-constraining Auto Layout

## Troubleshooting

- **No AI response**  
  Verify the API key in `APIConfig.swift` or your scheme environment. Confirm network entitlements and ATS settings if using non HTTPS endpoints.

- **Storyboard or nib not loading**  
  Confirm module ownership and storyboard IDs match the view controller classes.

- **Database migration errors**  
  Clear app data on simulator or reset the store in development while iterating on schema changes.

- **Jank in benchmark**  
  Check cell reuse identifiers, avoid synchronous I/O in `UICollectionViewDataSource`, and validate that gradient layers are not being recreated unnecessarily.

## License

Add your preferred license if you plan to publish benchmark results. For internal use, document how result artifacts are shared and reviewed.

---

## 🙌 Contributions Welcome

See the root [README](../README.md) for contribution guidelines.

---

Built with 💙 using Flutter  
By [SynergyBoat](https://synergyboat.com/?utm_source=github&utm_medium=repo&utm_campaign=flashcard-benchmark)
