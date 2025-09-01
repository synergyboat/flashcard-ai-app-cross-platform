# 🚀 Cross-Platform AI Flashcard App Benchmark (Flutter, React Native, SwiftUI, Kotlin)

Compare performance, AI integration, and native experience across four platforms — in one unified AI-powered learning app.

Built by **SynergyBoat** — your partner in AI consulting, product innovation, and digital transformation.  
🔗 [synergyboat.com](https://synergyboat.com/?utm_source=github&utm_medium=repo&utm_campaign=flashcard-benchmark)

---

## 📘 Overview

This repository benchmarks a production-ready AI-powered flashcard app built with:

- **Flutter**
- **React Native**
- **SwiftUI (iOS)**
- **Jetpack Compose (Android)**

We designed this to help teams and founders evaluate:

- ⏱️ **Build times** and **developer velocity**  
- ⚙️ **Runtime performance** and **memory usage**  
- 🎯 **AI integration patterns** (OpenAI Completions API)  
- 🧑‍💻 **Platform-native UX** and animations  

Whether you're comparing frameworks for your next EdTech, productivity, or GenAI app — this benchmark gives you side-by-side insights.

📖 Full write-up:  
📝 [**Multi-Platform Flashcard AI Benchmark**](https://www.synergyboat.com/blog/flutter-vs-react-native-vs-native-performance-benchmark-2025?utm_campaign=brand&utm_medium=social&utm_source=github&utm_content=repo_link)

---

## ✨ Core Features

- **Manual & AI-Generated Cards**  
  Create flashcards by hand or auto-generate them via OpenAI.

- **Smooth Flip Animations**  
  Native transitions for a polished, delightful study experience.

- **Benchmark Hooks**  
  Logs for cold start, AI latency, memory/CPU usage, and network payload.

- **Futuristic UI**  
  Clean layouts adapted to each platform’s design system.

---

## 🧪 Supported Platforms

| Platform         | Status | Language / Framework        | Setup Guide                  |
|------------------|--------|------------------------------|------------------------------|
| Flutter          | ✅     | Dart + Flutter               | `/flutter/README.md`         |
| React Native     | ✅     | JavaScript + React Native    | `/react-native/README.md`    |
| iOS (SwiftUI)    | ✅     | Swift + SwiftUI              | `/ios/README.md`             |
| Android (Kotlin) | ✅     | Kotlin + Jetpack Compose     | `/android/README.md`         |

Each subfolder contains:
- A fully working app
- CI scripts
- Benchmark instrumentation
- Platform-specific documentation

---

## 🔧 Quick Start

Clone the repository:

    git clone https://github.com/synergyboat/flashcard-ai-benchmark.git
    cd flashcard-ai-benchmark

### 1. Flutter

    cd flutter
    flutter pub get
    flutter run

### 2. React Native

    cd react-native
    npm ci
    npx react-native run-ios    # or run-android

### 3. iOS (SwiftUI)

    • Open `FlashcardAI.xcodeproj` in Xcode 14+
    • Set your signing team
    • Build & run

### 4. Android (Kotlin)

    • Open the project in Android Studio Arctic Fox+
    • Sync Gradle
    • Run on emulator or device

> 🔐 Replace `sk-REPLACE_ME` with your actual OpenAI API key.

---

## 🤖 AI Integration

Each app uses the OpenAI Chat Completions API to generate flashcards.

Example request:

    {
      "model": "gpt-3.5-turbo",
      "messages": [
        { "role": "user", "content": "Create 10 flashcards on sustainable energy" }
      ]
    }

💡 Store your API key in `.env`, Keychain, or a secure variable — never hardcoded.

---

## 📈 Benchmark Metrics

What we measure:

- ⏱️ **Startup Time** — Time to first render
- ⚡ **AI Latency** — Roundtrip time to OpenAI
- 🧠 **Memory & CPU** — Profiler snapshots
- 🌐 **Network Payload** — Request and response sizes

Each platform’s CI defines how these metrics are collected. See individual setup files for details.

---

## 🖼️ Screenshots & Demos

📸 Coming soon!

We welcome PRs for:
- Dark mode
- Accessibility features
- UI improvements
- Architectural Improvements

---

## 🤝 Contributing

1. Fork this repo  
2. Create a branch:  
       git checkout -b feature/your-feature-name  
3. Commit your changes:  
       git commit -m "feat: describe your feature"  
4. Push your branch:  
       git push origin feature/your-feature-name  
5. Open a Pull Request

Please follow our `Code of Conduct` and `Contributing Guide`.

---

## 📄 License

**MIT** © 2025 [SynergyBoat](https://synergyboat.com/?utm_source=github&utm_medium=repo&utm_campaign=flashcard-benchmark)

---

Built with passion by  
**SynergyBoat** — [shaping the future of AI-powered product experiences](https://synergyboat.com/?utm_source=github&utm_medium=repo&utm_campaign=flashcard-benchmark)
