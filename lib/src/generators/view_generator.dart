import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/cli_config.dart';
import '../utils/config_utils.dart';
import '../utils/template_utils.dart';

class ViewGenerator {
  static Future<void> generateView(String viewName, String featureName,
      {String? projectPath, CliConfig? config}) async {
    print('🎨 Generating view: $viewName in feature: $featureName');

    // Load config if not provided
    config ??= await ConfigUtils.loadConfig(projectPath);
    if (config == null) {
      print(
          '⚠️  Warning: No project configuration found. Using default settings.');
      config = CliConfig(
        networkPackage: 'http',
        stateManagement: 'bloc',
        navigation: 'go_router',
        useEquatable: true,
      );
    }

    final featurePath = projectPath != null
        ? path.join(projectPath, 'lib', 'app', 'features', featureName)
        : path.join('lib', 'app', 'features', featureName);

    // Check if feature exists
    if (!await Directory(featurePath).exists()) {
      print(
          '❌ Error: Feature $featureName does not exist. Create it first using: fbloc create feature $featureName');
      return;
    }

    final viewPath = path.join(featurePath, 'view');
    final componentsPath = path.join(viewPath, 'components');

    // Create view and components directories ONLY if they don't exist
    await _ensureDirectoryExists(viewPath);
    await _ensureDirectoryExists(componentsPath);

    // Generate screen file ONLY if it doesn't exist
    final screenFilePath = path.join(viewPath, '$viewName.dart');
    await _createFileIfNotExists(
      screenFilePath,
      TemplateUtils.getScreenTemplate(viewName, featureName, config),
      'View file $viewName.dart',
    );

    // Generate sample component ONLY for home_screen and ONLY if it doesn't exist
    if (viewName == 'home_screen') {
      final bottomNavbarPath = path.join(componentsPath, 'bottom_navbar.dart');
      await _createFileIfNotExists(
        bottomNavbarPath,
        TemplateUtils.getBottomNavbarTemplate(),
        'Bottom navbar component',
      );
    }

    print('✅ View $viewName generated successfully in feature $featureName!');
  }

  // Helper method to ensure directory exists without overwriting
  static Future<void> _ensureDirectoryExists(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      print('📁 Created directory: $dirPath');
    }
  }

  // Helper method to create file only if it doesn't exist
  static Future<void> _createFileIfNotExists(
      String filePath, String content, String description) async {
    final file = File(filePath);
    if (!await file.exists()) {
      await file.writeAsString(content);
      print('📄 Created $description: $filePath');
    } else {
      print('⚠️  $description already exists, skipping: $filePath');
    }
  }
}
