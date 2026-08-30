## 2.2.0

- Added `hive_ce_flutter` support with `LocalDbService` in `core/storage/local_db_service.dart`
- Scaffolds separate `remote_datasource.dart` and `local_datasource.dart` for all features
- Centralized all DI registrations in `app/core/di/injection_container.dart` and cleaned up `main.dart`
- Added standard Dart `operator ==` and `hashCode` overrides for models, states, and events when `equatable: false`
- Streamlined `DioClient` and `HttpClient` to expose direct instances

## 2.1.0

- New default features on project create: `home` and `auth`
- Concise, icon-based output with clear next steps
- Quiet mode for generators to reduce noise (only final messages)
- Dynamic summary showing generated features and folders (without lib prefix)
- Improved README with usage and tips

## 1.0.3

- Make CLI platform-agnostic by replacing `interact` with stdin/stdout prompts
- Add dartdoc to public API (commands, config, core)
- Improve pubspec metadata (repository, issue tracker, topics)
- Update README with pub activation instructions

## 1.0.0

- Initial version.
