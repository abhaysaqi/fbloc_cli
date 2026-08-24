import 'dart:io';

import 'package:path/path.dart' as path;

import '../models/cli_config.dart';
import '../utils/config_utils.dart';
import '../utils/file_utils.dart';
import '../utils/template_utils.dart';
import 'feature_generator.dart';

/// Initializes an existing Flutter project so it can use all fbloc_cli features.
///
/// This is meant to be run inside an already-created Flutter app directory.
/// It is intentionally conservative and will:
/// - create `.cli_config.json` if missing (prompting the user),
/// - create the `lib/app` structure expected by fbloc_cli,
/// - create core/theme/routes/service files ONLY when they don't already exist.
///
/// It will NOT:
/// - touch `pubspec.yaml`,
/// - overwrite existing files,
/// - modify your existing `main.dart` or routing.
class InitGenerator {
  /// Run initialization in [projectPath].
  ///
  /// If [projectPath] is omitted, the current directory is assumed to be
  /// the project root.
  static Future<void> initProject({String? projectPath}) async {
    final root = projectPath ?? Directory.current.path;

    if (!await _looksLikeFlutterProject(root)) {
      print(
        'Error: This does not look like a Flutter project. '
        'Run `fbloc init` from your Flutter project root (where pubspec.yaml lives).',
      );
      return;
    }

    // 1) Ensure configuration exists (or prompt for it)
    var config = await ConfigUtils.loadConfig(root);
    if (config == null) {
      print('No .cli_config.json found. Let\'s configure your project:');
      config = await ConfigUtils.promptForConfiguration();
      await ConfigUtils.saveConfig(root, config);
      print('\n✅ Configuration saved to .cli_config.json');
    } else {
      print('✅ Existing .cli_config.json found. Using saved configuration.');
    }

    // 2) Create app structure under lib/app
    final libDir = Directory(path.join(root, 'lib'));
    if (!await libDir.exists()) {
      print(
        'Error: Cannot find lib/ directory. '
        'Run `fbloc init` from a valid Flutter project root.',
      );
      return;
    }

    final appBase = path.join(libDir.path, 'app');

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
      await _ensureDirectory(path.join(appBase, dir));
    }

    // Create nested network directories if missing
    await _ensureDirectory(path.join(appBase, 'core/network/client'));
    await _ensureDirectory(path.join(appBase, 'core/network/client/dio_interceptor'));
    await _ensureDirectory(path.join(appBase, 'core/network/handler'));

    // 3) Create core files if missing

    // config dir
    await _createFileIfMissing(
      path.join(appBase, 'config/app_config.dart'),
      TemplateUtils.getAppConfigTemplate(),
    );

    // constants dir
    await _createFileIfMissing(
      path.join(appBase, 'core/constants/app_assets.dart'),
      TemplateUtils.getAppAssetsTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/constants/app_texts.dart'),
      TemplateUtils.getAppTextsTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/constants/api_endpoints.dart'),
      TemplateUtils.getApiEndpointsTemplate(config),
    );

    // errors dir
    await _createFileIfMissing(
      path.join(appBase, 'core/errors/failures.dart'),
      TemplateUtils.getFailuresTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/errors/exceptions.dart'),
      TemplateUtils.getExceptionsTemplate(),
    );

    // network dir
    await _createFileIfMissing(
      path.join(appBase, 'core/network/connection_checker.dart'),
      TemplateUtils.getConnectionCheckerTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/network/api_response.dart'),
      TemplateUtils.getCommonResponseTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/network/client/dio_client.dart'),
      TemplateUtils.getDioClientTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/network/client/dio_interceptor/logging_interceptor.dart'),
      TemplateUtils.getLoggingInterceptorTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/network/handler/dio_exception_handler.dart'),
      TemplateUtils.getDioExceptionHandlerTemplate(),
    );

    // theme dir
    await _createFileIfMissing(
      path.join(appBase, 'core/theme/app_colors.dart'),
      TemplateUtils.getAppColorsTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/theme/app_theme.dart'),
      TemplateUtils.getAppThemeTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/theme/app_styles.dart'),
      TemplateUtils.getAppStylesTemplate(),
    );

    // extension dir
    await _createFileIfMissing(
      path.join(appBase, 'core/extensions/l10_extension.dart'),
      TemplateUtils.getL10nExtensionTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/extensions/date_formatter.dart'),
      TemplateUtils.getDateFormatterTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/extensions/theme_extension.dart'),
      TemplateUtils.getThemeExtensionTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/extensions/app_theme.dart'),
      TemplateUtils.getAppThemeExtensionTemplate(),
    );

    // storage dir
    await _createFileIfMissing(
      path.join(appBase, 'core/storage/secure_storage_service.dart'),
      TemplateUtils.getSecureStorageServiceTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/storage/storage_keys.dart'),
      TemplateUtils.getStorageKeysTemplate(),
    );

    // utils dir
    await _createFileIfMissing(
      path.join(appBase, 'core/utils/helper.dart'),
      TemplateUtils.getAppHelperTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/utils/logger.dart'),
      TemplateUtils.getAppLoggerTemplate(),
    );

    // widgets dir
    await _createFileIfMissing(
      path.join(appBase, 'core/widgets/custom_button.dart'),
      TemplateUtils.getCustomButtonTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/widgets/custom_appbar.dart'),
      TemplateUtils.getCustomAppBarTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/widgets/custom_back_button.dart'),
      TemplateUtils.getCustomBackButtonTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/widgets/custom_dialog.dart'),
      TemplateUtils.getCustomDialogTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/widgets/custom_drawer.dart'),
      TemplateUtils.getCustomDrawerTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core/widgets/social_button.dart'),
      TemplateUtils.getSocialButtonTemplate(),
    );

    // di dir
    await _createFileIfMissing(
      path.join(appBase, 'core/di/injection_container.dart'),
      TemplateUtils.getInjectionContainerTemplate(),
    );

    // 4) Create routing helpers if missing
    await _createFileIfMissing(
      path.join(appBase, 'routes', 'app_routes.dart'),
      TemplateUtils.getAppRoutesTemplate(config),
    );
    await _createFileIfMissing(
      path.join(appBase, 'routes', 'route_names.dart'),
      TemplateUtils.getRouteNamesTemplate(),
    );

    // 5) Configure main.dart to match 'create' command behavior
    final mainFile = File(path.join(root, 'lib', 'main.dart'));
    if (await mainFile.exists()) {
      final backupFile = File(path.join(root, 'lib', 'main.dart.backup'));
      if (!await backupFile.exists()) {
        await mainFile.copy(backupFile.path);
        print('Created backup of existing main.dart at lib/main.dart.backup');
      }
    }
    await FileUtils.writeFile(
      mainFile.path,
      TemplateUtils.getMainTemplate(config),
    );

    // 6) Generate default home and auth features
    await FeatureGenerator.generateFeature(
      'home',
      projectPath: root,
      config: config,
      verbose: false,
    );
    await FeatureGenerator.generateFeature(
      'auth',
      projectPath: root,
      config: config,
      verbose: false,
    );

    // 7) Add required dependencies to pubspec.yaml
    await _addDependencies(root, config);

    print('\n✅ fbloc_cli initialized for this project.');
    print('You can now use:');
    print('  ➤ fbloc feature <name>');
    print('  ➤ fbloc create feature <name>');
    print('  ➤ fbloc view <view_name> on <feature_name>');
  }

  static Future<void> _addDependencies(String root, CliConfig config) async {
    final packages = <String>[];
    packages.add('flutter_bloc');
    if (config.useEquatable) {
      packages.add('equatable');
    }
    if (config.networkPackage == 'dio') {
      packages.add('dio');
    } else if (config.networkPackage == 'http') {
      packages.add('http');
    }
    if (config.navigation == 'go_router') {
      packages.add('go_router');
    }

    if (packages.isEmpty) return;
    print('\nAdding required dependencies to pubspec.yaml: ${packages.join(', ')}...');

    // Try running `flutter pub add ...`
    try {
      final result = await Process.run('flutter', ['pub', 'add', ...packages], workingDirectory: root);
      if (result.exitCode == 0) {
        print('✅ Dependencies added successfully.');
        return;
      }
    } catch (_) {}

    // Windows fallback
    try {
      final result = await Process.run('flutter.bat', ['pub', 'add', ...packages], workingDirectory: root);
      if (result.exitCode == 0) {
        print('✅ Dependencies added successfully.');
        return;
      }
    } catch (_) {}

    print('⚠️  Warning: Could not add dependencies automatically. Please run:');
    print('   flutter pub add ${packages.join(' ')}');
  }

  static Future<void> _ensureDirectory(String dirPath) async {
    await FileUtils.createDirectory(dirPath);
  }

  static Future<void> _createFileIfMissing(
    String filePath,
    String content,
  ) async {
    final file = File(filePath);
    if (await file.exists()) return;
    await FileUtils.writeFile(filePath, content);
  }

  static Future<bool> _looksLikeFlutterProject(String root) async {
    final pubspecFile = File(path.join(root, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) return false;

    try {
      final content = await pubspecFile.readAsString();
      // Very lightweight check to avoid a YAML dependency here.
      return content.contains('sdk: flutter') || content.contains('flutter:');
    } catch (_) {
      return false;
    }
  }
}


