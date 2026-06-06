# fetchy

Mobile REST API client for Flutter — like Postman, on your phone.

Send HTTP requests, manage collections, organize environments, and import/export Postman v2.1 collections.

## Quick start

```bash
flutter pub get
flutter run
```

## Development

| Command | Purpose |
|---|---|
| `flutter test` | Run all tests |
| `flutter analyze` | Lint / static analysis |
| `dart run build_runner build` | Regenerate `.g.dart` after model changes |

## Stack

- **Framework**: Flutter (Dart SDK ^3.12.1)
- **State**: Riverpod — `Notifier`/`StateNotifier` providers
- **Routing**: go_router — `ShellRoute` with bottom nav (4 tabs) + full-screen request editor
- **HTTP**: Dio — accepts all status codes, 5-minute timeouts, request/response logging
- **Storage**: Hive — local boxes for requests, collections, environments
- **Codegen**: `json_serializable` + `hive_generator` for model serialization
