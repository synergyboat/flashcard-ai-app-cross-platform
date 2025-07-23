# 📱 Flutter Flashcard AI App (SynergyBoat Benchmark)

This is the **Flutter** implementation of the Cross-Platform AI Flashcard App Benchmark — built to compare development speed, native performance, and AI integration across platforms.

Part of the open-source benchmark by [SynergyBoat](https://synergyboat.com/?utm_source=github&utm_medium=repo&utm_campaign=flashcard-benchmark).

---

## 🚀 App Overview

This Flutter app demonstrates:

- AI-powered flashcard generation using **OpenAI**
- Clean native UI with **flip animations**
- Built-in **performance logging** (cold start, memory, AI latency)
- Benchmark parity with React Native, SwiftUI, and Kotlin/Compose counterparts

---

## 🛠️ Getting Started

Make sure you have Flutter installed (`flutter --version` ≥ 3.10)

1. Install dependencies

    flutter pub get

2. Run the app

    flutter run

> ⚠️ Replace `sk-REPLACE_ME` in `openai_service.dart` with your actual OpenAI API key. Use `.env` or secrets manager in production.

---

## 📦 Project Structure

- `lib/`
  - `main.dart` – App entry point
  - `models/` – Flashcard data models
  - `services/` – OpenAI service + performance hooks
  - `ui/` – Flip animation widgets and screens
  - `benchmark/` – Cold start & latency logging

---

## ⚙️ Benchmark Instrumentation

This build includes hooks for:

- **Cold Start Time** (logged via `FlutterBenchmark.start()`)
- **AI Response Latency** (roundtrip to OpenAI)
- **Memory Usage** (monitor using DevTools)
- **Network Payload Size** (log request/response)

You can inspect performance using:

- `flutter run --profile`
- `flutter logs`
- Flutter DevTools

---

## 🤖 AI Integration

This app uses the OpenAI Chat Completion API:

    {
      "model": "gpt-3.5-turbo",
      "messages": [
        { "role": "user", "content": "Create 10 flashcards on AI ethics" }
      ]
    }

For secure API key usage in production:
- Use `flutter_dotenv`
- Or fetch keys from remote storage with encryption

---

## 🧪 Testing

To run basic widget tests:

    flutter test

To profile performance:

    flutter run --profile --trace-startup

---

## 🙌 Contributions Welcome

See the root [README](../README.md) for contribution guidelines.

---

Built with 💙 using Flutter  
By [SynergyBoat](https://synergyboat.com/?utm_source=github&utm_medium=repo&utm_campaign=flashcard-benchmark)
