// Entry point library for the fbloc CLI.
//
// This file exposes the `FblocCli` class which coordinates
// parsing of command-line arguments and dispatching to sub-commands.

import 'package:args/command_runner.dart';
import 'src/commands/create_command.dart';
import 'src/commands/feature_command.dart';
import 'src/commands/init_command.dart';
import 'src/commands/view_command.dart';

/// The main coordinator for the `fbloc` command-line interface.
class FblocCli {
  /// Runs the CLI with the provided [arguments].
  ///
  /// This sets up the command runner and delegates to sub-commands
  /// like `create`, `feature`, and `view`.
  Future<void> run(List<String> arguments) async {
    // Preprocess arguments to support `fbloc create <project_name>`
    final normalizedArgs = _normalizeArguments(arguments);

    final runner = CommandRunner<void>(
      'fbloc',
      'A scaffolding CLI for Flutter projects with feature-first architecture',
    )
      ..addCommand(CreateCommand())
      ..addCommand(FeatureCommand())
      ..addCommand(ViewCommand())
      ..addCommand(InitCommand());

    try {
      await runner.run(normalizedArgs);
    } catch (e) {
      // Print a user-friendly error without stack traces for CLI UX.
      print('Error: $e');
    }
  }

  /// Handles direct project creation: `fbloc create projectName`
  List<String> _normalizeArguments(List<String> args) {
    if (args.isEmpty) return args;
    if (args[0] != 'create') return args;

    // If already specifying a subcommand (project/feature), keep as-is
    if (args.length >= 2 && (args[1] == 'project' || args[1] == 'feature')) {
      return args;
    }

    // If exactly `create <name>` (or with additional trailing args), rewrite to use project subcommand
    if (args.length >= 2) {
      return ['create', 'project', ...args.sublist(1)];
    }

    return args;
  }
}
