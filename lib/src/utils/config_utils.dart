import 'dart:io';
import 'package:interact/interact.dart' as interact;
import '../models/cli_config.dart';

/// Utilities for prompting, saving, and loading CLI configuration.
class ConfigUtils {
  /// Prompts the user for configuration via stdin/stdout.
  static Future<CliConfig> promptForConfiguration() async {
    print('🔧 Let\'s configure your project:\n');

    // Network package selection (arrow-key toggle)
    final networkOptions = ['http', 'dio'];
    final networkIndex = interact.Select(
      prompt: 'Choose network package',
      options: networkOptions,
      initialIndex: 0,
    ).interact();
    final networkPackage = networkOptions[networkIndex];

    // State management selection
    final stateOptions = ['bloc', 'cubit'];
    final stateIndex = interact.Select(
      prompt: 'Choose state management',
      options: stateOptions,
      initialIndex: 0,
    ).interact();
    final stateManagement = stateOptions[stateIndex];

    // Navigation selection
    final navigationOptions = ['go_router', 'navigator'];
    final navIndex = interact.Select(
      prompt: 'Choose navigation',
      options: navigationOptions,
      initialIndex: 0,
    ).interact();
    final navigation = navigationOptions[navIndex];

    // Equatable confirmation
    final useEquatable = interact.Confirm(
      prompt: 'Use Equatable for value equality?',
      defaultValue: true,
    ).interact();

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

// Legacy stdin helpers removed in favor of arrow-key interactions via `interact`.
