import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/cli_config.dart';
import '../utils/config_utils.dart';
import '../utils/file_utils.dart';
import '../utils/template_utils.dart';

class FeatureGenerator {
  static Future<void> generateFeature(String featureName, {String? projectPath, CliConfig? config}) async {
    print('🔧 Generating feature: $featureName');
    
    // Load config if not provided
    config ??= await ConfigUtils.loadConfig(projectPath);
    if (config == null) {
      print('⚠️  Warning: No project configuration found. Using default settings.');
      config = CliConfig(
        networkPackage: 'http',
        stateManagement: 'bloc',
        navigation: 'go_router',
        useEquatable: true,
      );
    }
    
    final basePath = projectPath != null 
        ? path.join(projectPath, 'lib', 'app', 'features', featureName)
        : path.join('lib', 'app', 'features', featureName);
    
    // Check if feature already exists
    if (await Directory(basePath).exists()) {
      print('❌ Error: Feature $featureName already exists');
      return;
    }
    
    // Create feature directories
    final stateDir = config.stateManagement == 'bloc' ? 'bloc' : 'cubit';
    final dirs = [
      stateDir,
      'repository',
      'model',
      'view',
    ];
    
    for (final dir in dirs) {
      await FileUtils.createDirectory(path.join(basePath, dir));
    }
    
    // Generate state management files
    if (config.stateManagement == 'bloc') {
      await _generateBlocFiles(basePath, featureName, config);
    } else {
      await _generateCubitFiles(basePath, featureName, config);
    }
    
    // Generate Repository files
    await _generateRepositoryFiles(basePath, featureName);
    
    // Generate Model files
    await _generateModelFiles(basePath, featureName, config);
    
    print('✅ Feature $featureName generated successfully!');
  }

  static Future<void> _generateBlocFiles(String basePath, String featureName, CliConfig config) async {
    await FileUtils.writeFile(
      path.join(basePath, 'bloc', '${featureName}_bloc.dart'),
      TemplateUtils.getBlocTemplate(featureName, config),
    );
    
    await FileUtils.writeFile(
      path.join(basePath, 'bloc', '${featureName}_event.dart'),
      TemplateUtils.getBlocEventTemplate(featureName, config),
    );
    
    await FileUtils.writeFile(
      path.join(basePath, 'bloc', '${featureName}_state.dart'),
      TemplateUtils.getBlocStateTemplate(featureName, config),
    );
  }

  static Future<void> _generateCubitFiles(String basePath, String featureName, CliConfig config) async {
    await FileUtils.writeFile(
      path.join(basePath, 'cubit', '${featureName}_cubit.dart'),
      TemplateUtils.getCubitTemplate(featureName, config),
    );
    
    await FileUtils.writeFile(
      path.join(basePath, 'cubit', '${featureName}_state.dart'),
      TemplateUtils.getCubitStateTemplate(featureName, config),
    );
  }

  static Future<void> _generateRepositoryFiles(String basePath, String featureName) async {
    await FileUtils.writeFile(
      path.join(basePath, 'repository', '${featureName}_repository.dart'),
      TemplateUtils.getRepositoryTemplate(featureName),
    );
    
    await FileUtils.writeFile(
      path.join(basePath, 'repository', '${featureName}_repository_impl.dart'),
      TemplateUtils.getRepositoryImplTemplate(featureName),
    );
  }

  static Future<void> _generateModelFiles(String basePath, String featureName, CliConfig config) async {
    await FileUtils.writeFile(
      path.join(basePath, 'model', '${featureName}_model.dart'),
      TemplateUtils.getModelTemplate(featureName, config),
    );
  }
}
