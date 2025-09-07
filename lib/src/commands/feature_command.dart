import 'package:args/command_runner.dart';
import '../generators/feature_generator.dart';

class FeatureCommand extends Command {
  @override
  final name = 'feature';
  @override
  final description = 'Create a new feature (alias for create feature)';

  @override
  Future<void> run() async {
    if (argResults!.rest.isEmpty) {
      print('Usage: fbloc feature <feature_name>');
      return;
    }

    final featureName = argResults!.rest.first;
    await FeatureGenerator.generateFeature(featureName);
  }
}
