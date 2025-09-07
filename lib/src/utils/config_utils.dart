import 'dart:io';
import 'package:interact/interact.dart';
import '../models/cli_config.dart';

class ConfigUtils {
  static Future<CliConfig> promptForConfiguration() async {
    print('🔧 Let\'s configure your project:\n');

    // Network package selection
    final networkOptions = ['http', 'dio'];
    final networkIndex = Select(
      prompt: 'Choose network package:',
      options: networkOptions,
      initialIndex: 0, // default: http
    ).interact();
    final networkPackage = networkOptions[networkIndex];

    // State management selection
    final stateOptions = ['bloc', 'cubit'];
    final stateIndex = Select(
      prompt: 'Choose state management:',
      options: stateOptions,
      initialIndex: 0, // default: bloc
    ).interact();
    final stateManagement = stateOptions[stateIndex];

    // Navigation selection
    final navigationOptions = ['go_router', 'navigator'];
    final navigationIndex = Select(
      prompt: 'Choose navigation:',
      options: navigationOptions,
      initialIndex: 0, // default: go_router
    ).interact();
    final navigation = navigationOptions[navigationIndex];

    // Equatable confirmation
    final useEquatable = Confirm(
      prompt: 'Use Equatable for value equality?',
      defaultValue: true, // default: yes
    ).interact();

    return CliConfig(
      networkPackage: networkPackage,
      stateManagement: stateManagement,
      navigation: navigation,
      useEquatable: useEquatable,
    );
  }

  static Future<void> saveConfig(String projectPath, CliConfig config) async {
    final configFile = File('$projectPath/.cli_config.json');
    await configFile.writeAsString(config.toJsonString());
  }

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
