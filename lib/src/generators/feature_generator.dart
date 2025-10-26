import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/cli_config.dart';
import '../utils/config_utils.dart';
import '../utils/file_utils.dart';
import '../utils/template_utils.dart';
import 'view_generator.dart';

class FeatureGenerator {
  static Future<void> generateFeature(String featureName,
      {String? projectPath, CliConfig? config}) async {
    print('Generating feature: $featureName');

    // Load config if not provided
    config ??= await ConfigUtils.loadConfig(projectPath);
    if (config == null) {
      print('Warning: No project configuration found. Using default settings.');
      config = CliConfig(
        networkPackage: 'http',
        stateManagement: 'bloc',
        navigation: 'go_router',
        useEquatable: true,
      );
    }

    // Check if this is auth feature generation
    if (featureName.toLowerCase() == 'auth') {
      await _generateAuthFeature(projectPath, config);
      return;
    }

    final basePath = projectPath != null
        ? path.join(projectPath, 'lib', 'app', 'features', featureName)
        : path.join('lib', 'app', 'features', featureName);

    // Check if feature already exists
    if (await Directory(basePath).exists()) {
      print('Error: Feature $featureName already exists');
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

    // Generate Response model
    await FileUtils.writeFile(
      path.join(basePath, 'model', '${featureName}_response.dart'),
      TemplateUtils.getResponseModelTemplate(featureName, config),
    );

    // Generate a default view (home_screen) for the new feature
    await ViewGenerator.generateView(
      '${featureName}_screen',
      featureName,
      projectPath: projectPath,
      config: config,
    );

    // Generate components for home feature
    if (featureName == 'home') {
      await _generateHomeComponents(basePath, projectPath);
    }

    print('Feature $featureName generated successfully!');
  }

  // NEW: Auth feature generation
  static Future<void> _generateAuthFeature(
      String? projectPath, CliConfig config) async {
    print('Generating Auth feature with all screens...');

    final basePath = projectPath != null
        ? path.join(projectPath, 'lib', 'app', 'features', 'auth')
        : path.join('lib', 'app', 'features', 'auth');

    // Check if auth feature already exists
    if (await Directory(basePath).exists()) {
      print('Error: Auth feature already exists');
      return;
    }

    final isBloc = config.stateManagement == 'bloc';
    final stateDir = isBloc ? 'bloc' : 'cubit';

    // Create auth directory structure
    final dirs = [
      stateDir,
      'repository',
      'model',
      'view/screens',
      'view/components',
    ];

    for (final dir in dirs) {
      await FileUtils.createDirectory(path.join(basePath, dir));
    }

    // Generate models
    await FileUtils.writeFile(
      path.join(basePath, 'model', 'user_model.dart'),
      TemplateUtils.getUserModelTemplate(config),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'model', 'auth_tokens.dart'),
      TemplateUtils.getAuthTokensModelTemplate(config),
    );

    // Generate repository
    await FileUtils.writeFile(
      path.join(basePath, 'repository', 'auth_repository.dart'),
      TemplateUtils.getAuthRepositoryTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'repository', 'auth_repository_impl.dart'),
      TemplateUtils.getAuthRepositoryImplTemplate(config),
    );

    // Generate BLoC or Cubit
    if (isBloc) {
      await FileUtils.writeFile(
        path.join(basePath, 'bloc', 'auth_event.dart'),
        TemplateUtils.getAuthBlocEventTemplate(config),
      );
      await FileUtils.writeFile(
        path.join(basePath, 'bloc', 'auth_state.dart'),
        TemplateUtils.getAuthBlocStateTemplate(config),
      );
      await FileUtils.writeFile(
        path.join(basePath, 'bloc', 'auth_bloc.dart'),
        TemplateUtils.getAuthBlocTemplate(config),
      );
    } else {
      await FileUtils.writeFile(
        path.join(basePath, 'cubit', 'auth_cubit_state.dart'),
        TemplateUtils.getAuthCubitStateTemplate(config),
      );
      await FileUtils.writeFile(
        path.join(basePath, 'cubit', 'auth_cubit.dart'),
        TemplateUtils.getAuthCubitTemplate(config),
      );
    }

    // Generate screens
    await FileUtils.writeFile(
      path.join(basePath, 'view', 'screens', 'sign_in_screen.dart'),
      TemplateUtils.getSignInScreenTemplate(config),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'view', 'screens', 'sign_up_screen.dart'),
      TemplateUtils.getSignUpScreenTemplate(config),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'view', 'screens', 'forgot_password_screen.dart'),
      TemplateUtils.getForgotPasswordScreenTemplate(config),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'view', 'screens', 'otp_screen.dart'),
      TemplateUtils.getOtpScreenTemplate(config),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'view', 'screens', 'reset_password_screen.dart'),
      TemplateUtils.getResetPasswordScreenTemplate(config),
    );

    // Generate components
    await FileUtils.writeFile(
      path.join(basePath, 'view', 'components', 'auth_text_field.dart'),
      TemplateUtils.getAuthTextFieldTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'view', 'components', 'password_field.dart'),
      TemplateUtils.getPasswordFieldTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'view', 'components', 'otp_input_field.dart'),
      TemplateUtils.getOtpInputFieldTemplate(),
    );

    print('Auth feature generated successfully with 5 screens!');
  }

  static Future<void> _generateBlocFiles(
      String basePath, String featureName, CliConfig config) async {
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

  static Future<void> _generateCubitFiles(
      String basePath, String featureName, CliConfig config) async {
    await FileUtils.writeFile(
      path.join(basePath, 'cubit', '${featureName}_cubit.dart'),
      TemplateUtils.getCubitTemplate(featureName, config),
    );

    await FileUtils.writeFile(
      path.join(basePath, 'cubit', '${featureName}_state.dart'),
      TemplateUtils.getCubitStateTemplate(featureName, config),
    );
  }

  static Future<void> _generateRepositoryFiles(
      String basePath, String featureName) async {
    await FileUtils.writeFile(
      path.join(basePath, 'repository', '${featureName}_repository.dart'),
      TemplateUtils.getRepositoryTemplate(featureName),
    );

    await FileUtils.writeFile(
      path.join(basePath, 'repository', '${featureName}_repository_impl.dart'),
      TemplateUtils.getRepositoryImplTemplate(featureName),
    );
  }

  static Future<void> _generateModelFiles(
      String basePath, String featureName, CliConfig config) async {
    await FileUtils.writeFile(
      path.join(basePath, 'model', '${featureName}_model.dart'),
      TemplateUtils.getModelTemplate(featureName, config),
    );
  }

  static Future<void> _generateHomeComponents(
      String basePath, String? projectPath) async {
    // Create components directory
    final componentsPath = path.join(basePath, 'view', 'components');
    await FileUtils.createDirectory(componentsPath);

    // Generate bottom navbar
    await FileUtils.writeFile(
      path.join(componentsPath, 'bottom_navbar.dart'),
      TemplateUtils.getBottomNavbarTemplate(),
    );

    // Generate app drawer
    await FileUtils.writeFile(
      path.join(componentsPath, 'app_drawer.dart'),
      TemplateUtils.getAppDrawerTemplate(),
    );
  }
}
