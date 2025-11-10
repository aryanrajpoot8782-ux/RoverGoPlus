# RoverGo (Rider App)

This is the RoverGo Flutter 3 mobile project scaffolded for riders.

Getting started
1. Install Flutter 3.x and platform toolchains (Android Studio / Xcode)
2. From this folder:
	- flutter pub get
	- flutter run

Build for Android / iOS
- Android APK: flutter build apk --release
- iOS: flutter build ipa --release (requires macOS + Xcode)

Build web (optional, used by Dockerfile to serve a web build):
- flutter build web --release

Docker (builds web output and serves with nginx):
1. docker build -t rovergo-web .
2. docker run -p 8081:8080 rovergo-web

Notes
- Mobile-specific integrations (Firebase, Google Maps, Razorpay) are placeholders.
- Add your API keys and environment values in a safe way (do not commit secrets).

Project structure
- `lib/` — Flutter source
- `android/`, `ios/` — platform projects
- `web/` — generated when building web

Replace this README with project-specific instructions as you add features.
# rovergo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
