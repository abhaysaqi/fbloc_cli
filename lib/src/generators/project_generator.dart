import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/cli_config.dart';
import '../utils/config_utils.dart';
import '../utils/file_utils.dart';
import '../utils/template_utils.dart';
import 'feature_generator.dart';

class ProjectGenerator {
  static Future<void> generateProject(String projectName,
      {bool verbose = false}) async {
    if (verbose) {
      print('Creating Flutter project: $projectName');
    }

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
          projectPath: projectName, config: config, verbose: false);
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
      'config',
      'core/constants',
      'core/errors',
      'core/network',
      'core/theme',
      'core/extensions',
      'core/storage',
      'core/utils',
      'core/widgets',
      'core/di',
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
    // config dir (outside core)
    await FileUtils.writeFile(
      path.join(basePath, 'config/app_config.dart'),
      TemplateUtils.getAppConfigTemplate(),
    );

    // constants dir
    await FileUtils.writeFile(
      path.join(basePath, 'core/constants/app_assets.dart'),
      TemplateUtils.getAppAssetsTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/constants/app_texts.dart'),
      TemplateUtils.getAppTextsTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/constants/api_endpoints.dart'),
      TemplateUtils.getApiEndpointsTemplate(config),
    );

    // errors dir
    await FileUtils.writeFile(
      path.join(basePath, 'core/errors/failures.dart'),
      TemplateUtils.getFailuresTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/errors/exceptions.dart'),
      TemplateUtils.getExceptionsTemplate(),
    );

    // network dir
    await FileUtils.writeFile(
      path.join(basePath, 'core/network/connection_checker.dart'),
      TemplateUtils.getConnectionCheckerTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/network/api_response.dart'),
      TemplateUtils.getCommonResponseTemplate(),
    );
    if (config.networkPackage == 'dio') {
      await FileUtils.writeFile(
        path.join(basePath, 'core/network/client/dio_client.dart'),
        TemplateUtils.getDioClientTemplate(),
      );
      await FileUtils.writeFile(
        path.join(basePath, 'core/network/client/dio_interceptor/logging_interceptor.dart'),
        TemplateUtils.getLoggingInterceptorTemplate(),
      );
      await FileUtils.writeFile(
        path.join(basePath, 'core/errors/handler/exception_handler.dart'),
        TemplateUtils.getAppExceptionHandlerTemplate(),
      );
    } else {
      await FileUtils.writeFile(
        path.join(basePath, 'core/network/client/http_client.dart'),
        TemplateUtils.getHttpClientTemplate(),
      );
    }

    // theme dir
    await FileUtils.writeFile(
      path.join(basePath, 'core/theme/app_colors.dart'),
      TemplateUtils.getAppColorsTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/theme/app_theme.dart'),
      TemplateUtils.getAppThemeTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/theme/app_styles.dart'),
      TemplateUtils.getAppStylesTemplate(),
    );

    // extension dir
    await FileUtils.writeFile(
      path.join(basePath, 'core/extensions/l10_extension.dart'),
      TemplateUtils.getL10nExtensionTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/extensions/date_formatter.dart'),
      TemplateUtils.getDateFormatterTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/extensions/theme_extension.dart'),
      TemplateUtils.getThemeExtensionTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/extensions/app_theme.dart'),
      TemplateUtils.getAppThemeExtensionTemplate(),
    );

    // storage dir
    await FileUtils.writeFile(
      path.join(basePath, 'core/storage/local_db_service.dart'),
      TemplateUtils.getLocalDbServiceTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/storage/secure_storage_service.dart'),
      TemplateUtils.getSecureStorageServiceTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/storage/storage_keys.dart'),
      TemplateUtils.getStorageKeysTemplate(),
    );

    // utils dir
    await FileUtils.writeFile(
      path.join(basePath, 'core/utils/helper.dart'),
      TemplateUtils.getAppHelperTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/utils/logger.dart'),
      TemplateUtils.getAppLoggerTemplate(),
    );

    // widgets dir
    await FileUtils.writeFile(
      path.join(basePath, 'core/widgets/custom_button.dart'),
      TemplateUtils.getCustomButtonTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/widgets/custom_appbar.dart'),
      TemplateUtils.getCustomAppBarTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/widgets/custom_back_button.dart'),
      TemplateUtils.getCustomBackButtonTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/widgets/custom_dialog.dart'),
      TemplateUtils.getCustomDialogTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/widgets/custom_drawer.dart'),
      TemplateUtils.getCustomDrawerTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'core/widgets/social_button.dart'),
      TemplateUtils.getSocialButtonTemplate(),
    );

    // di dir
    await FileUtils.writeFile(
      path.join(basePath, 'core/di/injection_container.dart'),
      TemplateUtils.getInjectionContainerTemplate(config),
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

  static void printProjectSummary(String projectName,
      {List<String> features = const ['home']}) {
    // Project name
    print('\n📦 Project "$projectName" created successfully!');

    // Features
    if (features.isNotEmpty) {
      print('\n✨ Features generated:');
      print('   🧩 ${features.join(', ')}');
    }

    // Folders
    print('\n📁 Generated folders:');
    for (final f in features) {
      print('   📂 app/features/$f/');
    }
    print('   📂 app/config/');
    print('   📂 app/core/theme/');
    print('   📂 app/core/utils/');
    print('   📂 app/core/constants/');
    print('   📂 app/core/errors/');
    print('   📂 app/core/network/');
    print('   📂 app/core/extensions/');
    print('   📂 app/core/storage/');
    print('   📂 app/core/widgets/');
    print('   📂 app/core/di/');
    print('   📂 app/routes/');

    // Next steps
    print('\n➡️  Next steps:');
    print('   ➤ cd $projectName');
    print('   ➤ flutter pub get');
    print('   ➤ flutter run');
  }
}
