# SmartPack Frontend

Flutter mobile application for SmartPack.

## Setup

### Prerequisites
- Flutter 3.0+
- Dart SDK
- Android Studio / Xcode (for emulators)

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Make sure backend is running:
```bash
# In another terminal, from smartpack/backend/
python manage.py runserver
```

3. Run the app:
```bash
flutter run
```

## Project Structure
```
lib/
├── main.dart              # App entry point
├── config/
│   └── api_config.dart   # API configuration
├── models/               # Data models (User, Trip, etc.)
├── services/             # API services
├── screens/              # UI screens
├── widgets/              # Reusable widgets
└── utils/                # Helper functions
```

## API Connection

The app connects to the local backend at `http://127.0.0.1:8000`.

Make sure the Django backend is running before starting the app!

## Available Scripts
```bash
# Run app
flutter run

# Run tests
flutter test

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Clean build
flutter clean
```
