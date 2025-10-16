import 'package:args/command_runner.dart';
import '../generators/view_generator.dart';

class ViewCommand extends Command {
  @override
  final name = 'view';
  @override
  final description = 'Create a new view inside a feature';

  @override
  Future<void> run() async {
    final args = argResults!.rest;

    if (args.length < 3 || args[1] != 'on') {
      print('Usage: fbloc view <view_name> on <feature_name>');
      return;
    }

    final viewName = args[0];
    final featureName = args[2];

    await ViewGenerator.generateView(viewName, featureName);
  }
}
