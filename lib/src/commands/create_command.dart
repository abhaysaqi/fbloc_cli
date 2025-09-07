import 'package:args/command_runner.dart';
import '../generators/project_generator.dart';
import '../generators/feature_generator.dart';

class CreateCommand extends Command {
  @override
  final name = 'create';
  @override
  final description = 'Create a new Flutter project or feature';

  CreateCommand() {
    addSubcommand(CreateProjectSubcommand());
    addSubcommand(CreateFeatureSubcommand());
  }
}

class CreateProjectSubcommand extends Command {
  @override
  final name = 'project';
  @override
  final description = 'Create a new Flutter project';

  @override
  Future<void> run() async {
    if (argResults!.rest.isEmpty) {
      print('Usage: fbloc create project <project_name>');
      return;
    }

    final projectName = argResults!.rest.first;
    await ProjectGenerator.generateProject(projectName);
  }
}

class CreateFeatureSubcommand extends Command {
  @override
  final name = 'feature';
  @override
  final description = 'Create a new feature';

  @override
  Future<void> run() async {
    if (argResults!.rest.isEmpty) {
      print('Usage: fbloc create feature <feature_name>');
      return;
    }

    final featureName = argResults!.rest.first;
    await FeatureGenerator.generateFeature(featureName);
  }
}
