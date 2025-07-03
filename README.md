# 🧠 Flashcard AI App — Multi-Platform Benchmarking Project

An AI-powered flashcard learning app built in **Flutter**, **React Native**, **Swift (iOS)**, and **Kotlin (Android)** to benchmark modern mobile development platforms.

> Built by [SynergyBoat](https://www.synergyboat.com) to evaluate build time, performance, native integration, and developer experience across platforms.

---

## ✨ Features

- 📇 Manual flashcard creation (Question & Answer)
- 🤖 AI flashcard generation (via OpenAI)
- 🔁 Flip animations for study mode
- 📊 Embedded performance benchmarking points
- 💡 Modern, futuristic UI for AI experience

---

## 🚀 Platforms Implemented

| Platform        | Status | Language & Framework          |
|----------------|--------|-------------------------------|
| Flutter         | ✅     | Dart + Flutter                |
| React Native    | ✅     | JavaScript + React Native     |
| iOS Native      | ✅     | Swift + SwiftUI               |
| Android Native  | ✅     | Kotlin + Jetpack Compose      |

Each version includes AI integration, flip animations, and clean UI using platform-native patterns.

---

## 📦 Project Structure

```
📁 flashcard-ai-app/
├── flutter_flashcard_ai.zip
├── react_native_flashcard_ai.zip
├── ios_flashcard_ai_full_project.zip
├── kotlin_flashcard_ai.zip
└── README.md
```

> Each `.zip` file contains a full working project or main source file.

---

## 🔧 Requirements

To run the apps locally, ensure the following:

### ✅ Flutter
```bash
flutter pub get
flutter run
```

### ✅ React Native
```bash
npm install
npx react-native run-ios # or run-android
```

### ✅ iOS (SwiftUI)
- Open `FlashcardAI.xcodeproj` in Xcode 14+
- Set your signing team and run on device/simulator

### ✅ Android (Kotlin)
- Open in Android Studio Arctic Fox+
- Sync Gradle and run the app

---

## 🤖 AI Integration

We use the **OpenAI Chat Completions API**:
```json
{
  "model": "gpt-3.5-turbo",
  "messages": [{ "role": "user", "content": "Generate 5 flashcards on quantum computing..." }]
}
```

> ⚠️ Be sure to replace `sk-REPLACE_ME` in each source file with your own OpenAI API key.

---

## 🧪 Benchmarks Captured

Each version optionally logs:
- App load/start time
- AI call duration
- Memory/CPU usage (where supported)
- Network payload size

These are visible via debug logs or profiler tools native to each platform.

---

## 📸 Screenshots (Coming Soon)

> Want to contribute better designs or a dark mode? PRs are welcome 🚀

---

## 💬 About SynergyBoat

We help startups and enterprises build smarter products using **AI agents**, **LLMs**, and **cloud-native engineering**.

🌐 [Visit SynergyBoat →](https://www.synergyboat.com)

---

## 📄 License

MIT © 2025 SynergyBoat
