# Alarm Clock App Implementation Plan

Build a comprehensive Alarm Clock App similar to Google Clock with advanced features using Flutter and Clean Architecture.

## Proposed Changes

### Dependencies and Infrastructure
#### [pubspec.yaml](file:///C:/Users/KIIT/StudioProjects/alarmi/pubspec.yaml)
- Add dependencies: `flutter_riverpod`, `go_router`, `hive_flutter`, `isar`, `flutter_local_notifications`, `timezone`, `alarm`, `permission_handler`, `audio_service`, `just_audio`, `intl`, `riverpod_annotation`, `path_provider`, `equatable`, `json_annotation`.
- Add dev_dependencies: `build_runner`, `riverpod_generator`, `hive_generator`, `isar_generator`, `json_serializable`.

### Core Layer
- **Constants**: App colors, strings, dimensions.
- **Theme**: Material 3 light and dark themes.
- **Services**:
    - `StorageService`: Hive/Isar initialization and basic CRUD.
    - `NotificationService`: Wrapper for `flutter_local_notifications`.
    - `AlarmService`: Wrapper for `alarm` package.
- **Utils**: Time formatting, permissions helper.

### Features

#### Alarms
- **Domain**: `AlarmSettings` model (customized), `AlarmRepository` interface.
- **Data**: Hive-based `AlarmRepository` implementation.
- **Presentation**:
    - `AlarmListScreen`: ListView of alarms.
    - `AlarmEditScreen`: Form for creating/editing alarms.
    - `AlarmRingScreen`: Full-screen overlay when alarm triggers.
- **Providers**: `alarmListProvider`, `alarmEditProvider`.

#### World Clock
- **Domain**: `CityTime` model.
- **Presentation**: `WorldClockScreen` with city search.

#### Stopwatch
- **Logic**: Riverpod-based stopwatch controller.
- **Presentation**: `StopwatchScreen` with lap timing.

#### Timer
- **Logic**: Riverpod-based timer controller.
- **Presentation**: `TimerScreen` with duration picker.

#### Settings
- **Logic**: App settings state (theme mode, 24h format).
- **Presentation**: `SettingsScreen`.

### Routing
#### [routes/app_router.dart](file:///C:/Users/KIIT/StudioProjects/alarmi/lib/routes/app_router.dart) [NEW]
- Define GoRouter with paths for Alarms, World Clock, Stopwatch, Timer, and Settings.

## Verification Plan

### Automated Tests
- Run `flutter test` for unit tests (models, logic).
- Repository tests using mock storage.

### Manual Verification
- Verify alarm triggers in foreground, background, and when app is closed.
- Test snooze/dismiss functionality.
- Test theme switching.
- Test timer and stopwatch accuracy.
