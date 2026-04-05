# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (requires connected device or emulator)
flutter run

# Build for release
flutter build apk          # Android
flutter build ios          # iOS (requires macOS + Xcode)

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Lint / analyze
flutter analyze
```

> Native platform folders (`android/`, `ios/`) are not yet generated. Run `flutter create .` from the project root to scaffold them before building for a specific platform.

## Architecture

This is a minimal Flutter app. Currently there is only one file:

- [lib/main.dart](lib/main.dart) — entry point; renders a single `MaterialApp` with a placeholder screen.

The app targets Flutter SDK `>=2.5.0` with Dart SDK `>=2.17.0 <3.0.0`. It uses Material Design (`uses-material-design: true`). No state management, routing, or additional packages are configured yet.
