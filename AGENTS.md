# fetchy — Agent Guide

Flutter mobile REST API client (like Postman for mobile). Phase 1: skeleton with placeholder screens.

## Commands

| Command | Purpose |
|---|---|
| `flutter run` | Launch app (Android/iOS) |
| `flutter test` | Run all tests |
| `flutter test test/widget_test.dart` | Single test |
| `flutter analyze` | Lint / static analysis |
| `flutter pub get` | Install / update deps |
| `dart run build_runner build` | Regenerate `.g.dart` after model changes |
| `dart run build_runner build --delete-conflicting-outputs` | Force regenerate on conflicts |

**CI**: none configured yet (no `.github/workflows`).

## Architecture

```
lib/
  config/         theme.dart, router.dart
  models/         ApiRequest, Collection, Environment, ApiResponse
  screens/        home, collections, environments, settings
  services/       HttpClientService (Dio wrapper)
```

- **State**: Riverpod — `ProviderScope` wraps app at `main.dart`. All dependent widgets use `ConsumerWidget` or `ref.watch`.
- **Routing**: go_router with `ShellRoute` + `NavigationBar` (4 tabs).
- **Storage**: Hive — init in `main.dart`. Adapter registration + box opening currently commented out (phase 1).
- **Models**: dual-annotated `@HiveType` + `@JsonSerializable`. Use `copyWith` for immutability. `ApiResponse` is JSON-only (not stored).
- **HTTP**: Dio — `validateStatus: (s) => true` (accepts all status codes). 30s timeouts. `LogInterceptor` on by default.

## Codegen

Models use `@HiveType` and `@JsonSerializable`. Generated `.g.dart` files are checked in. After editing any annotated model:

```bash
dart run build_runner build
```

## Project state

Phase 1 skeleton — all screens are `StatelessWidget` with placeholder text. `widgets/` directory exists but empty. `providers/` directory does not exist yet (place alongside `screens/` or at `lib/providers/` when added). Hive adapter registration + box opening are commented out in `main.dart` — uncomment when adapters are generated.
