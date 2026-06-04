# Architecture Explanation

This project follows **Clean Architecture** to ensure maintainability, testability, and scalability.

## Layers

### 1. Domain Layer
Contains the core business logic and entities. It is independent of any other layer.
- **Models**: Plain Dart classes representing the data (e.g., `AlarmModel`).
- **Repositories**: Abstract interfaces defining how data should be accessed.

### 2. Data Layer
Handles data persistence and external API calls.
- **Repositories Implementation**: Implements the interfaces defined in the domain layer using local storage (Hive) or network services.
- **Adapters**: Hive TypeAdapters for serializing/deserializing models.

### 3. Presentation Layer
Contains the UI and state management.
- **Screens**: Full-page widgets.
- **Widgets**: Reusable UI components.
- **Providers**: Riverpod providers for managing UI state and exposing business logic.

### 4. Core Layer
Contains infrastructure-level components used across the entire app.
- **Services**: Wrappers for external packages (Alarm, Notifications, Storage).
- **Theme**: App-wide styling and colors.
- **Utils**: Formatting and helper functions.

## Navigation
Navigation is handled by `GoRouter` using a `ShellRoute` to maintain a consistent bottom navigation bar across the main features.

## State Management
`Riverpod` is used for dependency injection and state management. It provides a robust way to listen to changes and update the UI efficiently.
