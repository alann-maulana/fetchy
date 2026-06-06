# fetchy — Agent Guide

Flutter mobile REST API client (like Postman for mobile).

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

No CI configured (no `.github/workflows`).

## Architecture

```
lib/
  config/         theme.dart, router.dart
  models/         ApiRequest, Collection, Environment (Hive + JSON), ApiResponse (JSON only)
  providers/      Riverpod StateNotifier + Notifier providers
  screens/        8 screens (home, request, collection list/detail, environment list/detail, settings)
  services/       HttpClientService (Dio), RequestService (auth/body), PostmanService (import/export)
  utils/          empty
  widgets/        KVEditor, BodyEditor, AuthEditor, ResponseViewer, JsonViewer
```

- **State**: Riverpod — `ProviderScope` wraps app at `main.dart`. Screens use `ConsumerWidget` / `ConsumerStatefulWidget`. Notifier providers with `ref.watch()` + `ref.read().notifier` pattern.
- **Routing**: go_router with `ShellRoute` + `NavigationBar` (4 tabs: Home, Collections, Environments, Settings). `/request` route outside shell (full-screen request editor).
- **Storage**: Hive — initialized in `main.dart`. Boxes: `requests`, `collections`, `environments`. Adapters registered before box open.
- **Models**: dual-annotated `@HiveType` + `@JsonSerializable`. Use `copyWith` for immutability. `ApiResponse` is `@JsonSerializable` only (not stored in Hive). Generated `.g.dart` files checked in.
- **HTTP**: Dio — `validateStatus: (s) => true` (accept all status codes). 5-minute connect/receive/send timeouts. `LogInterceptor` with request+response body on by default.
- **Postman**: `PostmanService` supports import/export of collections and environments (v2.1 schema).

## Codegen

After editing any `@HiveType` + `@JsonSerializable` model:

```bash
dart run build_runner build
```

## Testing

Test at `test/widget_test.dart` uses a temp Hive directory (`.test_hive`). setUp opens 3 boxes with adapter registration. tearDown deletes them from disk. App test expects `Text('Requests')`, `Text('No saved requests yet')`, `Text('New Request')` on home screen.

## Providers

All storage providers in `lib/providers/storage_provider.dart`:
- `savedRequestsProvider` / `SavedRequestsNotifier` — list of `ApiRequest` sorted by `updatedAt` desc. CRUD via `save`, `delete`, `rename`.
- `collectionsProvider` / `CollectionsNotifier` — list of `Collection` sorted by `updatedAt` desc. CRUD plus `addRequest` / `removeRequest`.
- `environmentsProvider` / `EnvironmentsNotifier` — list of `Environment`. CRUD plus `activate` (deactivates others, singleton active env).

`RequestEditorNotifier` in `lib/providers/request_provider.dart` manages the request compose screen state (method, URL, params, headers, body, auth, response). `KVEntry` helper for key-value list editing.
