/// Entry point library for the fbloc CLI.
///
/// This library exposes the `FblocCli` class which coordinates
/// of command-line arguments and dispatching to sub-commands.
library fbloc_cli;

import 'package:args/command_runner.dart';
import 'src/commands/create_command.dart';
import 'src/commands/feature_command.dart';
import 'src/commands/view_command.dart';

/// The main coordinator for the `fbloc` command-line interface.
class FblocCli {
  /// Runs the CLI with the provided [arguments].
  ///
  /// This sets up the command runner and delegates to sub-commands
  /// like `create`, `feature`, and `view`.
  Future<void> run(List<String> arguments) async {
    final runner = CommandRunner<void>(
      'fbloc',
      'A scaffolding CLI for Flutter projects with feature-first architecture',
    );

    runner
      ..addCommand(CreateCommand())
      ..addCommand(FeatureCommand())
      ..addCommand(ViewCommand());

    try {
      await runner.run(arguments);
    } catch (e) {
      // Print a user-friendly error without stack traces for CLI UX.
      print('Error: $e');
    }
  }
}
