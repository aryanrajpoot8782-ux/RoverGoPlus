# RoverGo Captain (Driver App)

This is the RoverGo Captain Flutter 3 mobile project scaffolded for captains/drivers.

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
1. docker build -t rovergocaptain-web .
2. docker run -p 8082:8080 rovergocaptain-web

Notes
- This app should include driver-specific flows: KYC upload, online/offline toggle, ride accept/reject.
- Add sensitive keys (Firebase, Razorpay) via environment variables and secure stores.

Project structure
- `lib/` — Flutter source
- `android/`, `ios/` — platform projects
- `web/` — generated when building web

Replace this README with project-specific instructions as you add features.
# rovergo_captain

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
