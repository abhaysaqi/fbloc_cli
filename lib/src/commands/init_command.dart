import 'package:args/command_runner.dart';

import '../generators/init_generator.dart';

/// Command to initialize an existing Flutter project for use with fbloc_cli.
///
/// Usage:
///   fbloc init
///
/// Run this from the root of an existing Flutter project (where pubspec.yaml
/// lives). It will create `.cli_config.json` and the `lib/app` structure
/// expected by fbloc_cli without overwriting existing files.
class InitCommand extends Command<void> {
  @override
  final String name = 'init';

  @override
  final String description =
      'Initialize an existing Flutter project for use with fbloc_cli';

  @override
  Future<void> run() async {
    // We intentionally ignore any extra args; just init current project.
    await InitGenerator.initProject();
  }
}


