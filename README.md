# Personalized Communication Companion

A Flutter-based AAC (Augmentative and Alternative Communication) app designed to assist non-verbal users in expressing themselves through tappable pictograms, voice synthesis, and speech recognition.

## ✨ Features

- 🎙️ **Listen Mode**: Tap the microphone to transcribe spoken phrases and suggest relevant pictograms or categories.
- 🧠 **AI-Powered Suggestions**: Detect user intent from speech and filter pictograms by category.
- 🔈 **Text-to-Speech (TTS)**: Tap a tile and hear the phrase spoken aloud.
- 📸 **Pictogram Tiles**: Scrollable grid of images with customizable categories like Food, Drink, Emotions, etc.
- 🎨 **Customize Companion**: Modify voice settings, themes, tile images, and more through a dedicated settings screen.

## 📁 Project Structure

```
lib/
├── main.dart                   # Main app UI & logic
├── pages/
│   └── customize_page.dart     # Settings screen
├── services/
│   ├── ai_service.dart         # AI intent and category detection
│   ├── stt_service.dart        # Speech-to-text integration
│   └── tts_service.dart        # Text-to-speech functionality
assets/
└── images/                     # Tile image assets (e.g., carrot.png, donut.png)
```

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A device or emulator (iOS/Android)

### Installation

```bash
git clone https://github.com/your-org/personalized_communication_companion.git
cd personalized_communication_companion
flutter pub get
flutter run
```

### Voice & Audio Setup

Ensure microphone and speaker permissions are enabled for both development and deployment targets.

## 🧪 Testing

```bash
flutter test
```

## ⚠️ Requirements
* macOS
* Xcode installed (xcode-select --install)
* CocoaPods installed (sudo gem install cocoapods)


## 📷 Screenshots

| Home Screen | Customize Page |
|-------------|----------------|
| ![Home](screenshots/home.png) | ![Customize](screenshots/customize.png) |

## 🔧 Configuration

You can extend the app by editing:
- `tileOptions` for new pictograms
- `categories` for new categories
- `ai_service.dart` to enhance AI-based filtering

## 👩‍💻 Contributing

1. Fork the repo
2. Create a new branch (`git checkout -b feature-name`)
3. Make your changes
4. Commit and push (`git commit -m 'Add new feature'`)
5. Open a Pull Request

## 📄 License

MIT License. See `LICENSE` for details.

---

Built with ❤️ using Flutter.
