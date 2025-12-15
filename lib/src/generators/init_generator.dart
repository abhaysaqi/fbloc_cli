import 'dart:io';

import 'package:path/path.dart' as path;

import '../utils/config_utils.dart';
import '../utils/file_utils.dart';
import '../utils/template_utils.dart';

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
    await _ensureDirectory(path.join(appBase, 'core', 'theme'));
    await _ensureDirectory(path.join(appBase, 'core', 'utils'));
    await _ensureDirectory(path.join(appBase, 'core', 'service'));
    await _ensureDirectory(path.join(appBase, 'routes'));
    await _ensureDirectory(path.join(appBase, 'features'));

    // 3) Create core files if missing
    await _createFileIfMissing(
      path.join(appBase, 'core', 'theme', 'app_colors.dart'),
      TemplateUtils.getAppColorsTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core', 'theme', 'app_theme.dart'),
      TemplateUtils.getAppThemeTemplate(),
    );

    await _createFileIfMissing(
      path.join(appBase, 'core', 'utils', 'constants.dart'),
      TemplateUtils.getConstantsTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core', 'utils', 'strings.dart'),
      TemplateUtils.getStringsTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core', 'utils', 'styles.dart'),
      TemplateUtils.getStylesTemplate(),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core', 'utils', 'api_response.dart'),
      TemplateUtils.getCommonResponseTemplate(),
    );

    await _createFileIfMissing(
      path.join(appBase, 'core', 'service', 'api_service.dart'),
      TemplateUtils.getApiServiceTemplate(config),
    );
    await _createFileIfMissing(
      path.join(appBase, 'core', 'service', 'api_endpoints.dart'),
      TemplateUtils.getApiEndpointsTemplate(config),
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

    print('\n✅ fbloc_cli initialized for this project.');
    print('You can now use:');
    print('  ➤ fbloc feature <name>');
    print('  ➤ fbloc create feature <name>');
    print('  ➤ fbloc view <view_name> on <feature_name>');
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


