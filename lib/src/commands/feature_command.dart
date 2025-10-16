import 'package:args/command_runner.dart';
import '../generators/feature_generator.dart';

/// Command alias to quickly scaffold a feature without using the create group.
class FeatureCommand extends Command {
  @override
  final name = 'feature';
  @override
  final description = 'Create a new feature (alias for create feature)';

  /// Executes the feature generation.
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
