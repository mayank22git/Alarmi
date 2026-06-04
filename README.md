# Alarmi - Advanced Alarm Clock App

A complete Alarm Clock application built with Flutter, following Clean Architecture and modern Material 3 design principles.

## Features

- **Alarm Management**: Create, edit, delete, and toggle alarms.
- **Repeat Options**: Set alarms for specific days of the week.
- **Alarm Ring Screen**: Full-screen overlay with snooze and dismiss options.
- **World Clock**: View current time across different time zones.
- **Stopwatch**: Precise timing with lap tracking.
- **Timer**: Countdown timer with notification support.
- **Modern UI**: Material 3 design with responsive layouts and dark mode.

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: Hive
- **Alarms**: `alarm` package
- **Notifications**: `flutter_local_notifications`
- **Utilities**: `timezone`, `intl`, `permission_handler`

## Clean Architecture

The project is organized into layers:
- **Core**: Services, constants, theme, and common widgets.
- **Features**: Modular features (alarms, stopwatch, etc.) each with its own domain, data, and presentation layers.
- **Routes**: Navigation configuration.
- **App**: Main application widget and entry point.

## Setup Instructions

1.  **Clone the repository**.
2.  **Add assets**: Place an alarm sound file at `assets/audio/alarm.mp3`.
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Platform Specific Setup**:
    - **Android**: Ensure `AndroidManifest.xml` has the required permissions and services (already configured in this project).
    - **iOS**: Enable "Background Modes" (Audio, Fetch) in Xcode.
5.  **Run the app**:
    ```bash
    flutter run
    ```

## Generation

To regenerate Hive adapters (if modified):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
