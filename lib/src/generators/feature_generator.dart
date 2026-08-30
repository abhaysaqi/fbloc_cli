import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/cli_config.dart';
import '../utils/config_utils.dart';
import '../utils/file_utils.dart';
import '../utils/loading_utils.dart';
import '../utils/template_utils.dart';
import 'view_generator.dart';

class FeatureGenerator {
  static Future<void> generateFeature(String featureName,
      {String? projectPath, CliConfig? config, bool verbose = true}) async {
    // Load config if not provided
    final resolvedConfig = config ??
        await ConfigUtils.loadConfig(projectPath) ??
        CliConfig(
          networkPackage: 'http',
          stateManagement: 'bloc',
          navigation: 'go_router',
          useEquatable: true,
        );

    if (verbose) {
      await LoadingProgress.run(
        message: 'Scaffolding feature "$featureName"...',
        task: () => _performGenerateFeature(featureName,
            projectPath: projectPath, config: resolvedConfig, verbose: verbose),
      );
      print('\n✨ Feature generated: $featureName');
    } else {
      await _performGenerateFeature(featureName,
          projectPath: projectPath, config: resolvedConfig, verbose: verbose);
    }
  }

  static Future<void> _performGenerateFeature(String featureName,
      {String? projectPath, required CliConfig config, bool verbose = true}) async {
    // Check if this is auth feature generation
    if (featureName.toLowerCase() == 'auth') {
      await _generateAuthFeature(projectPath, config, verbose: verbose);
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
      'datasource',
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

    // Generate Datasource files
    await _generateDatasourceFiles(basePath, featureName, config);

    // Generate Repository files
    await _generateRepositoryFiles(basePath, featureName);

    // Generate Model files
    await _generateModelFiles(basePath, featureName, config);

    // Generate Response model
    await FileUtils.writeFile(
      path.join(basePath, 'model', '${featureName}_response.dart'),
      TemplateUtils.getResponseModelTemplate(featureName, config),
    );

    // Generate a default view for the new feature
    await ViewGenerator.generateView(
      '${featureName}_screen',
      featureName,
      projectPath: projectPath,
      config: config,
      verbose: false,
    );

    // Generate components for home feature
    if (featureName == 'home') {
      await _generateHomeComponents(basePath, projectPath);
    }
  }

  // NEW: Auth feature generation
  static Future<void> _generateAuthFeature(
      String? projectPath, CliConfig config,
      {bool verbose = true}) async {

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
      'datasource',
      'repository',
      'model',
      'view/screens',
      'view/widgets',
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

    // Generate datasources
    await FileUtils.writeFile(
      path.join(basePath, 'datasource', 'auth_remote_datasource.dart'),
      TemplateUtils.getAuthRemoteDatasourceTemplate(config),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'datasource', 'auth_local_datasource.dart'),
      TemplateUtils.getAuthLocalDatasourceTemplate(config),
    );

    // Generate repository
    await FileUtils.writeFile(
      path.join(basePath, 'repository', 'auth_repository.dart'),
      TemplateUtils.getAuthRepositoryTemplate(config),
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
      path.join(basePath, 'view', 'widgets', 'auth_text_field.dart'),
      TemplateUtils.getAuthTextFieldTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'view', 'widgets', 'password_field.dart'),
      TemplateUtils.getPasswordFieldTemplate(),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'view', 'widgets', 'otp_input_field.dart'),
      TemplateUtils.getOtpInputFieldTemplate(),
    );

    if (verbose) {
      print('Auth feature generated successfully with 5 screens!');
    }
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
  }

  static Future<void> _generateDatasourceFiles(
      String basePath, String featureName, CliConfig config) async {
    await FileUtils.writeFile(
      path.join(basePath, 'datasource', '${featureName}_remote_datasource.dart'),
      TemplateUtils.getRemoteDatasourceTemplate(featureName, config),
    );
    await FileUtils.writeFile(
      path.join(basePath, 'datasource', '${featureName}_local_datasource.dart'),
      TemplateUtils.getLocalDatasourceTemplate(featureName, config),
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
    // Create widgets directory
    final widgetsPath = path.join(basePath, 'view', 'widgets');
    await FileUtils.createDirectory(widgetsPath);

    // Generate bottom navbar
    await FileUtils.writeFile(
      path.join(widgetsPath, 'bottom_navbar.dart'),
      TemplateUtils.getBottomNavbarTemplate(),
    );

    // Generate app drawer
    await FileUtils.writeFile(
      path.join(widgetsPath, 'app_drawer.dart'),
      TemplateUtils.getAppDrawerTemplate(),
    );
  }
}
