# fbloc CLI

A scaffolding CLI for Flutter projects with feature-first architecture and BLoC/Cubit state management.

## What it does

- Creates a new Flutter app with opinionated structure
- Generates default features: `home` and `auth`
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

Ensure your pub cache bin is on PATH so `fbloc` is available.

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
- Create Flutter project structure
- Generate default `home` feature (with `home_screen`) and the full `auth` feature
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
   📂 app/core/service/
   📂 app/routes/

➡️  Next steps:
   ➤ cd my_app
   ➤ flutter pub get
   ➤ flutter run
```

### Create a new feature

```bash
fbloc create feature auth
```

or

```bash
fbloc feature auth
```

Final output (concise):

```
✨ Feature generated: auth
```

### Create a new view

```bash
fbloc view login on auth
```

Final output (concise):

```
🖼️ View generated: login on auth
```

## Configuration

On first project creation, you'll be prompted to configure:

- **Network package**: http (default) or dio
- **State management**: bloc (default) or cubit
- **Navigation**: go_router (default) or navigator
- **Equatable**: yes (default) or no

Configuration is saved in `.cli_config.json` and used for all subsequent feature/view generation.

## Generated Structure

```
lib/
└── app/
  ├── features/
  │   ├── home/
  │   │   ├── bloc/ or cubit/
  │   │   ├── repository/
  │   │   ├── model/
  │   │   └── view/
  │   └── auth/
  │       ├── bloc/ or cubit/
  │       ├── repository/
  │       ├── model/
  │       └── view/
  ├── core/
  │   ├── theme/
  │   ├── utils/
  │   └── service/
  └── routes/
```
