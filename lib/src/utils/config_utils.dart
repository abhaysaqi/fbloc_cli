import 'dart:io';
import '../models/cli_config.dart';

/// Utilities for prompting, saving, and loading CLI configuration.
class ConfigUtils {
  /// Prompts the user for configuration via stdin/stdout.
  static Future<CliConfig> promptForConfiguration() async {
    print('🔧 Let\'s configure your project:\n');

    // Network package selection
    final networkOptions = ['http', 'dio'];
    final networkPackage = _promptSelect(
      label: 'Choose network package (http/dio)',
      options: networkOptions,
      defaultValue: 'http',
    );

    // State management selection
    final stateOptions = ['bloc', 'cubit'];
    final stateManagement = _promptSelect(
      label: 'Choose state management (bloc/cubit)',
      options: stateOptions,
      defaultValue: 'bloc',
    );

    // Navigation selection
    final navigationOptions = ['go_router', 'navigator'];
    final navigation = _promptSelect(
      label: 'Choose navigation (go_router/navigator)',
      options: navigationOptions,
      defaultValue: 'go_router',
    );

    // Equatable confirmation
    final useEquatable = _promptConfirm(
      label: 'Use Equatable for value equality? (Y/n)',
      defaultValue: true,
    );

    return CliConfig(
      networkPackage: networkPackage,
      stateManagement: stateManagement,
      navigation: navigation,
      useEquatable: useEquatable,
    );
  }

  /// Saves the configuration JSON to `.cli_config.json` in [projectPath].
  static Future<void> saveConfig(String projectPath, CliConfig config) async {
    final configFile = File('$projectPath/.cli_config.json');
    await configFile.writeAsString(config.toJsonString());
  }

  /// Loads configuration from `.cli_config.json`.
  /// If [projectPath] is provided, loads from that directory; otherwise, CWD.
  static Future<CliConfig?> loadConfig([String? projectPath]) async {
    final configPath = projectPath != null
        ? '$projectPath/.cli_config.json'
        : '.cli_config.json';

    final configFile = File(configPath);
    if (!await configFile.exists()) return null;

    try {
      final content = await configFile.readAsString();
      return CliConfig.fromJsonString(content);
    } catch (e) {
      print('⚠️  Warning: Could not load project configuration: $e');
      return null;
    }
  }
}

String _promptLine(String label, {String? defaultValue}) {
  stdout.write(defaultValue == null ? '$label: ' : '$label [$defaultValue]: ');
  final input = stdin.readLineSync()?.trim();
  if (input == null || input.isEmpty) {
    return defaultValue ?? '';
  }
  return input;
}

String _promptSelect({
  required String label,
  required List<String> options,
  required String defaultValue,
}) {
  while (true) {
    final raw = _promptLine(label, defaultValue: defaultValue).toLowerCase();
    if (options.contains(raw)) return raw;
    print('Please enter one of: ${options.join(', ')}');
  }
}

bool _promptConfirm({
  required String label,
  required bool defaultValue,
}) {
  while (true) {
    final def = defaultValue ? 'Y' : 'n';
    final raw = _promptLine(label, defaultValue: def).toLowerCase();
    if (raw.isEmpty) return defaultValue;
    if (raw == 'y' || raw == 'yes') return true;
    if (raw == 'n' || raw == 'no') return false;
    print('Please answer Y or n.');
  }
}
