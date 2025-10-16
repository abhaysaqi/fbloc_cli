# fbloc CLI

A scaffolding CLI for Flutter projects with feature-first architecture and BLoC/Cubit state management.

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

### Create a new project

```bash
fbloc create project my_app
```

This will:

- Prompt for configuration (Network, State Management, Navigation, Equatable)
- Create Flutter project structure
- Generate default home feature and view
- Save preferences in `.cli_config.json`

### Create a new feature

```bash
fbloc create feature auth
```

or

```bash
fbloc feature auth
```

### Create a new view

```bash
fbloc view login on auth
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
│ └── home/
│ ├── bloc/ or cubit/
│ ├── repository/
│ ├── model/
│ └── view/
├── core/
│ ├── theme/
│ ├── utils/
│ └── service/
└── routes/
```
