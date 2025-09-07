import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/cli_config.dart';
import '../utils/config_utils.dart';
import '../utils/file_utils.dart';
import '../utils/template_utils.dart';
import 'feature_generator.dart';
import 'view_generator.dart';

class ProjectGenerator {
  static Future<void> generateProject(String projectName) async {
    print('🚀 Creating Flutter project: $projectName');

    // Check if project directory already exists
    final projectDir = Directory(projectName);
    if (await projectDir.exists()) {
      print('❌ Error: Directory $projectName already exists');
      return;
    }

    // Step 1: Interactive setup prompts
    final config = await ConfigUtils.promptForConfiguration();

    // Step 2: Create Flutter project using flutter CLI
    print('📦 Creating base Flutter project...');
    final result = await _runFlutterCreate(projectName);

    if (result.exitCode != 0) {
      print('❌ Error creating Flutter project:');
      print('STDOUT: ${result.stdout}');
      print('STDERR: ${result.stderr}');
      return;
    }

    // Step 3: Save CLI configuration
    await ConfigUtils.saveConfig(projectName, config);

    // Step 4: Replace lib/ directory and pubspec.yaml
    await _replaceProjectStructure(projectName, config);

    // Step 5: Generate default home feature
    await FeatureGenerator.generateFeature('home',
        projectPath: projectName, config: config);

    // Step 6: Generate default home_screen view
    await ViewGenerator.generateView('home_screen', 'home',
        projectPath: projectName, config: config);

    print('✅ Project $projectName created successfully!');
    print('📁 Configuration saved in .cli_config.json');

    // Auto run flutter pub get
    print('📦 Running flutter pub get...');
    final pubGetResult = await _runPubGet(projectName);

    if (pubGetResult.exitCode == 0) {
      print('✅ Dependencies installed successfully!');
    } else {
      print('⚠️  Warning: Could not run pub get automatically');
      print('   Please run: cd $projectName && flutter pub get');
    }
    _printProjectSummary(config, projectName);
  }

  static Future<ProcessResult> _runPubGet(String projectName) async {
    try {
      return await Process.run(
        'C:\\flutter\\bin\\flutter.bat',
        ['pub', 'get'],
        workingDirectory: projectName,
      );
    } catch (e) {
      try {
        return await Process.run(
          'flutter',
          ['pub', 'get'],
          workingDirectory: projectName,
        );
      } catch (e2) {
        return ProcessResult(0, 1, '', 'Could not run pub get');
      }
    }
  }

  // Updated method for your specific Flutter path
  static Future<ProcessResult> _runFlutterCreate(String projectName) async {
    print('🔍 Attempting to run Flutter create...');

    try {
      // Use your exact Flutter path first
      print('🔍 Trying: C:\\flutter\\bin\\flutter.bat');
      final result = await Process.run(
          'C:\\flutter\\bin\\flutter.bat', ['create', projectName]);
      if (result.exitCode == 0) {
        print('✅ Success with direct path!');
        return result;
      }
    } catch (e) {
      print('❌ Direct path failed: $e');
    }

    try {
      // Try flutter.bat command
      print('🔍 Trying: flutter.bat');
      final result = await Process.run('flutter.bat', ['create', projectName]);
      if (result.exitCode == 0) {
        print('✅ Success with flutter.bat!');
        return result;
      }
    } catch (e) {
      print('❌ flutter.bat failed: $e');
    }

    try {
      // Try through cmd shell with your path
      print('🔍 Trying: cmd /c with your Flutter path');
      final result = await Process.run(
        'cmd',
        ['/c', 'C:\\flutter\\bin\\flutter.bat', 'create', projectName],
        runInShell: true,
      );
      if (result.exitCode == 0) {
        print('✅ Success with cmd shell!');
        return result;
      }
    } catch (e) {
      print('❌ cmd shell failed: $e');
    }

    // If all attempts fail
    return ProcessResult(
        0, 1, '', 'Could not execute flutter create command with any method');
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

    // Service
    await FileUtils.writeFile(
      path.join(basePath, 'core/service/api_service.dart'),
      TemplateUtils.getApiServiceTemplate(config),
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
    print('\n🎉 Project "$projectName" created successfully!');
    print('\n📋 Project Configuration:');
    print('   🌐 Network: ${config.networkPackage}');
    print('   🏗️  State Management: ${config.stateManagement}');
    print('   🧭 Navigation: ${config.navigation}');
    print('   ⚖️  Equatable: ${config.useEquatable ? "Yes" : "No"}');
    print('\n🎯 Generated Features:');
    print('   📁 lib/app/features/home/ (with home_screen)');
    print('   📁 lib/app/core/ (theme, utils, service)');
    print('   📁 lib/app/routes/ (routing configuration)');
    print('\n🚀 Next steps:');
    print('   cd $projectName');
    print('   flutter pub get');
    print('   flutter run');
  }
}
