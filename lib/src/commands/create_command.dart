import 'package:args/command_runner.dart';
import '../generators/project_generator.dart';
import '../generators/feature_generator.dart';

/// Top-level `create` command that groups subcommands for project and feature generation.
class CreateCommand extends Command {
  @override
  final name = 'create';
  @override
  final description = 'Create a new Flutter project or feature';

  /// Creates a new instance and registers subcommands.
  CreateCommand() {
    addSubcommand(CreateProjectSubcommand());
    addSubcommand(CreateFeatureSubcommand());
  }
}

/// Subcommand to create a new Flutter project.
class CreateProjectSubcommand extends Command {
  @override
  final name = 'project';
  @override
  final description = 'Create a new Flutter project';

  /// Executes the project creation workflow.
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

/// Subcommand to create a new feature module.
class CreateFeatureSubcommand extends Command {
  @override
  final name = 'feature';
  @override
  final description = 'Create a new feature';

  /// Executes the feature creation workflow.
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
