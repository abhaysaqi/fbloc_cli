import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/cli_config.dart';
import '../utils/config_utils.dart';
import '../utils/file_utils.dart';
import '../utils/template_utils.dart';
import 'feature_generator.dart';

class ProjectGenerator {
  static Future<void> generateProject(String projectName) async {
    print('Creating Flutter project: $projectName');

    // Check if project directory already exists
    final projectDir = Directory(projectName);
    if (await projectDir.exists()) {
      print('Error: Directory $projectName already exists');
      return;
    }

    // Verify Flutter is available on PATH (no static paths)
    if (!await _isFlutterAvailable()) {
      print('Error: Flutter not found on PATH.');
      print(
          '   Ensure Flutter is installed and `flutter` is available in your PATH.');
      return;
    }

    // Step 1: Interactive setup prompts
    final config = await ConfigUtils.promptForConfiguration();

    // Step 2: Create Flutter project using flutter CLI
    final result = await _runFlutterCreate(projectName);

    if (result.exitCode != 0) {
      print('Error creating Flutter project');
      // Clean up any partial directory if it was created
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
      return;
    }

    try {
      // Step 3: Save CLI configuration
      await ConfigUtils.saveConfig(projectName, config);

      // Step 4: Replace lib/ directory and pubspec.yaml
      await _replaceProjectStructure(projectName, config);

      // Step 5: Generate default home feature
      await FeatureGenerator.generateFeature('home',
          projectPath: projectName, config: config);

      print('Project $projectName created successfully!');
      _printProjectSummary(config, projectName);
    } catch (e) {
      print('Error during project setup: $e');
      // Clean up the project directory if setup fails
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
    }
  }

  static Future<bool> _isFlutterAvailable() async {
    try {
      final r = await Process.run('flutter', ['--version']);
      if (r.exitCode == 0) return true;
    } catch (_) {}
    try {
      final r = await Process.run('flutter.bat', ['--version']);
      if (r.exitCode == 0) return true;
    } catch (_) {}
    return false;
  }

  // Use PATH-based flutter create (with Windows fallback)
  static Future<ProcessResult> _runFlutterCreate(String projectName) async {
    // Try `flutter` first (macOS/Linux/Windows when PATH resolves)
    try {
      final result = await Process.run('flutter', ['create', projectName]);
      if (result.exitCode == 0) {
        return result;
      }
    } catch (e) {
      // Continue to fallback
    }

    // Fallback for Windows where flutter.bat is on PATH
    try {
      final result = await Process.run('flutter.bat', ['create', projectName]);
      if (result.exitCode == 0) {
        return result;
      }
    } catch (e) {
      // Continue to error
    }

    return ProcessResult(
        0, 1, '', 'Could not execute flutter create from PATH');
  }

  static Future<void> _replaceProjectStructure(
      String projectName, CliConfig config) async {
    // Remove default lib directory
    final libDir = Directory(path.join(projectName, 'lib'));
    if (await libDir.exists()) {
      await libDir.delete(recursive: true);
    }

    // Create custom project structure
    await _createProjectStructure(projectName, config);

    // Replace pubspec.yaml
    await FileUtils.writeFile(
      path.join(projectName, 'pubspec.yaml'),
      TemplateUtils.getPubspecTemplate(projectName, config),
    );
  }

  static Future<void> _createProjectStructure(
      String projectName, CliConfig config) async {
    final basePath = path.join(projectName, 'lib', 'app');

    // Create directories
    final dirs = [
      'core/theme',
      'core/utils',
      'core/service',
      'routes',
      'features',
    ];

    for (final dir in dirs) {
      await FileUtils.createDirectory(path.join(basePath, dir));
    }

    // Create core files
    await _createCoreFiles(basePath, config);
    await _createRouteFiles(basePath, config);
    await _createMainFile(projectName, config);
  }

  static Future<void> _createCoreFiles(
      String basePath, CliConfig config) async {
    // Theme files
    await FileUtils.writeFile(
      path.join(basePath, 'core/theme/app_colors.dart'),
      TemplateUtils.getAppColorsTemplate(),
    );

    await FileUtils.writeFile(
      path.join(basePath, 'core/theme/app_theme.dart'),
      TemplateUtils.getAppThemeTemplate(),
    );

    // Utils files
    await FileUtils.writeFile(
      path.join(basePath, 'core/utils/constants.dart'),
      TemplateUtils.getConstantsTemplate(),
    );

    await FileUtils.writeFile(
      path.join(basePath, 'core/utils/strings.dart'),
      TemplateUtils.getStringsTemplate(),
    );

    await FileUtils.writeFile(
      path.join(basePath, 'core/utils/styles.dart'),
      TemplateUtils.getStylesTemplate(),
    );

    await FileUtils.writeFile(
      path.join(basePath, 'core/utils/api_response.dart'),
      TemplateUtils.getCommonResponseTemplate(),
    );

    // Service
    await FileUtils.writeFile(
      path.join(basePath, 'core/service/api_service.dart'),
      TemplateUtils.getApiServiceTemplate(config),
    );

    // API Endpoints
    await FileUtils.writeFile(
      path.join(basePath, 'core/service/api_endpoints.dart'),
      TemplateUtils.getApiEndpointsTemplate(config),
    );
  }

  static Future<void> _createRouteFiles(
      String basePath, CliConfig config) async {
    await FileUtils.writeFile(
      path.join(basePath, 'routes/app_routes.dart'),
      TemplateUtils.getAppRoutesTemplate(config),
    );

    await FileUtils.writeFile(
      path.join(basePath, 'routes/route_names.dart'),
      TemplateUtils.getRouteNamesTemplate(),
    );
  }

  static Future<void> _createMainFile(
      String projectName, CliConfig config) async {
    await FileUtils.writeFile(
      path.join(projectName, 'lib/main.dart'),
      TemplateUtils.getMainTemplate(config),
    );
  }

  static void _printProjectSummary(CliConfig config, String projectName) {
    print('\nProject "$projectName" created successfully!');
    print('\nGenerated folders:');
    print('   lib/app/features/home/ (with home_screen)');
    print('   lib/app/core/ (theme, utils, service)');
    print('   lib/app/routes/ (routing configuration)');
    print('\nNext steps:');
    print('   cd $projectName');
    print('   flutter pub get');
    print('   flutter run');
  }
}
