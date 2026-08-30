# fbloc CLI

A powerful scaffolding CLI for Flutter projects with feature-first architecture, BLoC/Cubit state management, clean architecture datasources, and dependency injection.

> **Tip**: Please use `fbloc_cli` v2.2.0 or newer for the latest clean architecture scaffolding with Hive CE local database support, split remote/local datasources, and centralized `get_it` DI.

## What it does

- Scaffolds a production-ready Flutter app with **Feature-First Architecture**
- Automatically configures state management (**BLoC** or **Cubit**)
- Supports multiple networking solutions (**Dio** or **http**) with unified exception handling
- Supports offline caching with **Hive CE** (`hive_ce_flutter`) and **Flutter Secure Storage**
- Scaffolds separate **remote** and **local** datasources for all features
- Implements value equality via **Equatable** or standard pure Dart `operator ==` / `hashCode`
- Generates default features: `home` and complete `auth` (with sign in, sign up, password reset, and session checking)
- Centralizes all Dependency Injection inside `app/core/di/injection_container.dart`
- Scaffolds additional features and views on demand
- Prints concise, user-friendly output with icons

## Installation

From pub.dev:

```bash
dart pub global activate fbloc_cli
```

From source (local path):

```bash
dart pub get
dart pub global activate --source path .
```

Ensure your pub cache `bin` is on PATH so `fbloc` is available globally.

## Usage

### Create a new project (recommended)

```bash
fbloc create project my_app
```

or the shorthand:

```bash
fbloc create my_app
```

Project creation will:

- Prompt for configuration (Network, State Management, Navigation, Equatable)
- Create the Flutter project structure
- Generate default `home` feature (with `home_screen`) and complete `auth` feature
- Configure `injection_container.dart` with all datasources, repositories, and blocs
- Save preferences in `.cli_config.json`

Final output looks like:

```
📦 Project "my_app" created successfully!

✨ Features generated:
   🧩 home, auth

📁 Generated folders:
   📂 app/features/home/ (with home_screen)
   📂 app/features/auth/
   📂 app/core/theme/
   📂 app/core/utils/
   📂 app/core/errors/
   📂 app/core/network/
   📂 app/core/storage/
   📂 app/core/di/
   📂 app/routes/

➡️  Next steps:
   ➤ cd my_app
   ➤ flutter pub get
   ➤ flutter run
```

### Initialize an existing project

If you already have an existing Flutter project and want to scaffold `fbloc_cli` architecture:

```bash
cd my_existing_app
fbloc init
```

What `fbloc init` does:

- Prompts for configuration (Network, State Management, Navigation, Equatable) if `.cli_config.json` is missing.
- Creates the expected `lib/app` structure (`core/`, `routes/`, `features/`) without overwriting existing files.
- Generates core helpers (`AppTheme`, `AppColors`, `LocalDbService`, `SecureStorageService`, `ApiResponse`, `ApiEndpoints`, DI, routes) only if they don't already exist.

### Create a new feature

```bash
fbloc feature profile
```

Scaffolds:
- `bloc/` (or `cubit/`)
- `datasource/profile_remote_datasource.dart` & `datasource/profile_local_datasource.dart`
- `repository/profile_repository.dart`
- `model/profile_model.dart`
- `view/profile_screen.dart`

### Create a new view

```bash
fbloc view login on auth
```

## Configuration

On first project creation or `fbloc init`, you will be prompted to configure:

- **Network package**: `http` (default) or `dio`
- **State management**: `bloc` (default) or `cubit`
- **Navigation**: `go_router` (default) or `navigator`
- **Equatable**: `yes` (default) or `no` (generates standard Dart `operator ==` & `hashCode`)

Configuration is saved in `.cli_config.json` and reused across commands.

## Generated Architecture

```
lib/
└── app/
  ├── features/
  │   ├── home/
  │   │   ├── bloc/ (or cubit/)
  │   │   ├── datasource/
  │   │   │   ├── home_remote_datasource.dart
  │   │   │   └── home_local_datasource.dart
  │   │   ├── repository/
  │   │   │   └── home_repository.dart
  │   │   ├── model/
  │   │   │   └── home_model.dart
  │   │   └── view/
  │   │       └── home_screen.dart
  │   └── auth/
  │       ├── bloc/ (or cubit/)
  │       ├── datasource/
  │       │   ├── auth_remote_datasource.dart
  │       │   └── auth_local_datasource.dart
  │       ├── repository/
  │       │   └── auth_repository.dart
  │       ├── model/
  │       │   ├── auth_tokens.dart
  │       │   └── user_model.dart
  │       └── view/
  │           └── sign_in_screen.dart
  ├── core/
  │   ├── di/
  │   │   └── injection_container.dart # Centralized GetIt DI
  │   ├── constants/                   # API endpoints, assets, app texts
  │   ├── errors/
  │   │   ├── exceptions.dart
  │   │   ├── failures.dart
  │   │   └── handler/                 # Unified AppExceptionHandler
  │   ├── network/
  │   │   ├── api_response.dart
  │   │   ├── connection_checker.dart
  │   │   └── client/                  # DioClient or HttpClient
  │   ├── storage/
  │   │   ├── local_db_service.dart    # Hive CE local storage
  │   │   ├── secure_storage_service.dart
  │   │   └── storage_keys.dart
  │   ├── extensions/                  # Theme & date extensions
  │   ├── theme/                       # App colors, styles, & themes
  │   ├── utils/                       # Helpers & AppLogger
  │   └── widgets/                     # Reusable widgets
  └── routes/
      ├── app_routes.dart
      └── route_names.dart
```
