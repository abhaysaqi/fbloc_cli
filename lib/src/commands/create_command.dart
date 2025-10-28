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

  /// Support direct usage: `fbloc create <project_name>`
  ///
  /// If no subcommand is provided but one free argument exists, treat it
  /// as a project name and create a Flutter project directly. This is a
  /// convenience alias for `fbloc create project <project_name>`.
  @override
  Future<void> run() async {
    final rest = argResults?.rest ?? [];
    if (rest.isEmpty) {
      print('Usage:');
      print('  fbloc create <project_name>');
      print('  fbloc create project <project_name>');
      print('  fbloc create feature <feature_name>');
      return;
    }

    // Check if the first argument is a subcommand
    if (rest.first == 'project' || rest.first == 'feature') {
      // Let the subcommand handle it
      return;
    }

    // Treat as direct project creation
    final projectName = rest.first;
    await ProjectGenerator.generateProject(projectName, verbose: false);
    // Also generate auth feature for direct create path (quiet)
    await FeatureGenerator.generateFeature(
      'auth',
      projectPath: projectName,
      verbose: false,
    );
    ProjectGenerator.printProjectSummary(projectName,
        features: ['home', 'auth']);
  }
}

/// Subcommand to create a new Flutter project.
class CreateProjectSubcommand extends Command {
  @override
  final name = 'project';
  @override
  final description = 'Create a new Flutter project with auth feature included';

  /// Executes the project creation workflow.
  @override
  Future<void> run() async {
    if (argResults!.rest.isEmpty) {
      print('Usage: fbloc create project <project_name>');
      return;
    }

    final projectName = argResults!.rest.first;
    await ProjectGenerator.generateProject(projectName, verbose: false);

    // Automatically generate auth feature after project creation (quiet)
    await FeatureGenerator.generateFeature(
      'auth',
      projectPath: projectName,
      verbose: false,
    );

    ProjectGenerator.printProjectSummary(projectName,
        features: ['home', 'auth']);
  }
}

/// Subcommand to create a new feature module.
class CreateFeatureSubcommand extends Command {
  @override
  final name = 'feature';
  @override
  final description =
      'Create a new feature (use "auth" for authentication feature)';

  /// Executes the feature creation workflow.
  @override
  Future<void> run() async {
    if (argResults!.rest.isEmpty) {
      print('Usage: fbloc create feature <feature_name>');
      print('Example: fbloc create feature auth');
      print('Example: fbloc create feature profile');
      return;
    }

    final featureName = argResults!.rest.first;

    // Special handling for auth feature
    await FeatureGenerator.generateFeature(featureName, verbose: false);
    // Final concise output when generating only a feature
    print('\n✨ Feature generated: $featureName');
  }
}
