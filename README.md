# MemoryCompass

Pin your photos to the place they were taken, on a world map. MemoryCompass
reads GPS coordinates from a photo's EXIF metadata when available, falls back
to manual placement when it isn't, and can back up your library to Google
Drive so you can get it back if you lose your phone.

## Features

- World map (OpenStreetMap via `flutter_map`) showing every pinned memory as
  a photo thumbnail marker.
- Pick a photo from the gallery; if it has embedded GPS data the pin is
  placed automatically, otherwise tap the map to place it yourself.
- Tap a pin to view the photo, title, note and delete it.
- Connect a Google account (`drive.file` scope only - the app can only see
  files it creates) and sync your memories to a `MemoryCompass` folder in
  Drive. Reconnecting the same account on a new device finds that folder and
  restores your data.

## Architecture

Clean Architecture, organized by feature:

```
lib/
  core/                     # cross-feature building blocks
    database/               # Drift (SQLite) schema + AppDatabase
    di/                     # app-wide Riverpod providers
    error/                  # Failure (domain-safe errors) and exceptions
    theme/, constants/, utils/
  features/
    memories/
      domain/               # MemoryPin entity, MemoryRepository interface, usecases
      data/                 # Drift-backed datasource, repository impl, mappers
      presentation/         # Riverpod providers/controllers, map + add-memory pages
    drive_sync/
      domain/               # SyncStatus/DriveAccount entities, repository interface, usecases
      data/                 # google_sign_in + googleapis Drive datasources, repository impl
      presentation/         # settings page, sync controller
```

Dependencies point inward: `presentation` and `data` depend on `domain`,
never the reverse. Each feature's `domain` layer only depends on `core` and
plain Dart, so it's testable without Flutter, Drift or Google APIs - see
`test/features/memories/domain/usecases/add_memory_pin_test.dart` for an
example using a mocked repository.

State management is Riverpod; errors flow through the layers as
`Either<Failure, T>` (via `fpdart`) rather than exceptions, except at the
edges (datasources) where the underlying SDKs throw.

## Google Drive setup

The app code is complete, but Google Sign-In requires an OAuth client that
only you can create (it's tied to your own Google Cloud project). See
[`SETUP.md`](SETUP.md) for the steps.

## Development

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerate Drift/Freezed/json_serializable code
flutter analyze
flutter test
flutter run
```

Run `dart run build_runner watch --delete-conflicting-outputs` while editing
entities, tables or DTOs so generated `*.g.dart` / `*.freezed.dart` files
stay in sync.
