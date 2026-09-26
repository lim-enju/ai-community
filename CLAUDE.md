# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

`ai_community` is a Flutter application in its initial scaffold state (created via `flutter create`, package name `ai_community`). The codebase currently consists only of the default counter-app demo (`lib/main.dart`) and its default widget test (`test/widget_test.dart`) — no custom architecture, routing, state management, or data layer exists yet. When adding features, there is no established pattern to follow yet in this repo; pick a reasonable Flutter convention and stay consistent as the app grows.

Dart SDK constraint: `^3.13.4` (see `pubspec.yaml`).

## Commands

```bash
# Install/update dependencies (run after any pubspec.yaml change)
flutter pub get

# Run the app
flutter run -d chrome     # web (Chrome) — this repo is commonly run in-browser
flutter run -d macos      # macOS desktop
flutter run                # prompts for a connected device if none specified

# Static analysis (uses flutter_lints via analysis_options.yaml)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Build (release) artifacts
flutter build web
flutter build macos
```

`flutter devices` lists available run targets (this machine has `macos` and `chrome` available).

## Linting

`analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` with no project-specific rule overrides yet. The `build/`, `android/`, `ios/`, `web/`, `windows/`, `macos/`, and `linux/` directories are excluded from analysis.

## Editor / hot reload

`.vscode/settings.json` sets `dart.flutterHotReloadOnSave: "always"`. This only takes effect when the app is launched through VS Code's Flutter debugger (F5 / Run → Start Debugging), not when `flutter run` is started from an external terminal — in that case, trigger reload manually with `r` (hot reload) or `R` (hot restart) in the running session.

## Platform targets

Standard Flutter multi-platform scaffolding is present for `android`, `ios`, `linux`, `macos`, `windows`, and `web`. Treat these as generated platform boilerplate (not hand-authored app code) unless a task specifically requires editing native/platform configuration.
