import 'package:args/command_runner.dart';
import 'src/commands/create_command.dart';
import 'src/commands/feature_command.dart';
import 'src/commands/view_command.dart';

class FblocCli {
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
      print('Error: $e');
    }
  }
}
