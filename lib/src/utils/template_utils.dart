import '../models/cli_config.dart';
import 'file_utils.dart';

class TemplateUtils {
  // Pubspec Template
  static String getPubspecTemplate(String projectName, CliConfig config) {
    final dependencies = <String>[
      'flutter:\n    sdk: flutter',
      'flutter_bloc: ^9.1.1',
    ];

    if (config.useEquatable) dependencies.add('equatable: ^2.0.7');
    if (config.networkPackage == 'dio') {
      dependencies.add('dio: ^5.9.0');
    } else {
      dependencies.add('http: ^1.4.0');
    }
    if (config.navigation == 'go_router') {
      dependencies.add('go_router: ^16.0.0');
    }

    return '''
name: $projectName
description: A Flutter project generated with fbloc CLI.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  ${dependencies.join('\n  ')}

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
''';
  }

  // Main Template
  static String getMainTemplate(CliConfig config) {
    final stateFolder = config.stateManagement == 'bloc' ? 'bloc' : 'cubit';
    final stateClassSuffix =
        config.stateManagement == 'bloc' ? 'Bloc' : 'Cubit';

    if (config.navigation == 'go_router') {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/features/home/$stateFolder/home_${config.stateManagement}.dart';
import 'app/features/home/repository/home_repository.dart';
import 'app/features/home/repository/home_repository_impl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HomeRepository>(create: (_) => HomeRepositoryImpl()),
        RepositoryProvider<ApiService>(create: (_) => ApiService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => Home$stateClassSuffix(
            context.read<HomeRepository>(),
          )${config.stateManagement == 'bloc' ? '..add(HomeStarted())' : '..loadData()'}),
        ],
        child: MaterialApp.router(
          title: 'Flutter Demo',
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
''';
    } else {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/route_names.dart';
import 'app/features/home/$stateFolder/home_${config.stateManagement}.dart';
import 'app/features/home/repository/home_repository.dart';
import 'app/features/home/repository/home_repository_impl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HomeRepository>(create: (_) => HomeRepositoryImpl()),
        RepositoryProvider<ApiService>(create: (_) => ApiService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => Home$stateClassSuffix(
            context.read<HomeRepository>(),
          )${config.stateManagement == 'bloc' ? '..add(HomeStarted())' : '..loadData()'}),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute: RouteNames.home,
        ),
      ),
    );
  }
}
''';
    }
  }

  // Core Templates
  static String getAppColorsTemplate() {
    return '''
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
}
''';
  }

  static String getAppThemeTemplate() {
    return '''
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
''';
  }

  static String getConstantsTemplate() {
    return '''
class AppConstants {
  static const String appName = 'Flutter App';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const String baseUrl = 'https://api.example.com';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
}
''';
  }

  static String getStringsTemplate() {
    return '''
class AppStrings {
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String ok = 'OK';
  static const String save = 'Save';
  static const String delete = 'Delete';
}
''';
  }

  static String getStylesTemplate() {
    return '''
import 'package:flutter/material.dart';

class AppStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}
''';
  }

  // API Service Template
  static String getApiServiceTemplate(CliConfig config) {
    if (config.networkPackage == 'dio') {
      return '''
import 'package:dio/dio.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.timeoutDuration,
      receiveTimeout: AppConstants.timeoutDuration,
      headers: {'Content-Type': 'application/json'},
    ));
  }

  late final Dio _dio;

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Network error: \${e.message}');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Network error: \${e.message}');
    }
  }
}
''';
    } else {
      return '''
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('\${AppConstants.baseUrl}\$endpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(AppConstants.timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: \$e');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('\${AppConstants.baseUrl}\$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(AppConstants.timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: \$e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw HttpException('HTTP \${response.statusCode}: \${response.body}');
    }
  }
}
''';
    }
  }

  // Routes Templates
  static String getAppRoutesTemplate(CliConfig config) {
    if (config.navigation == 'go_router') {
      return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/view/home_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
  ],
);
''';
    } else {
      return '''
import 'package:flutter/material.dart';
import '../features/home/view/home_screen.dart';
import 'route_names.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
}
''';
    }
  }

  static String getRouteNamesTemplate() {
    return '''
class RouteNames {
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';
}
''';
  }

  // Feature Templates
  static String getBlocTemplate(String featureName, CliConfig config) {
    final pascalName = FileUtils.toPascalCase(featureName);
    final equatableImport =
        config.useEquatable ? "import 'package:equatable/equatable.dart';" : '';

    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
$equatableImport
import '../repository/${featureName}_repository.dart';
import '${featureName}_event.dart';
import '${featureName}_state.dart';

class ${pascalName}Bloc extends Bloc<${pascalName}Event, ${pascalName}State> {
  final ${pascalName}Repository _repository;

  ${pascalName}Bloc(this._repository) : super(${pascalName}Initial()) {
    on<${pascalName}Started>(_onStarted);
  }

  Future<void> _onStarted(${pascalName}Started event, Emitter<${pascalName}State> emit) async {
    emit(${pascalName}Loading());
    try {
      await _repository.get${pascalName}s();
      emit(${pascalName}Loaded());
    } catch (e) {
      emit(${pascalName}Error(e.toString()));
    }
  }
}
''';
  }

  static String getBlocEventTemplate(String featureName, CliConfig config) {
    final pascalName = FileUtils.toPascalCase(featureName);
    final equatableExtends = config.useEquatable ? ' extends Equatable' : '';
    final propsOverride = config.useEquatable
        ? '''

  @override
  List<Object> get props => [];'''
        : '';

    return '''
${config.useEquatable ? "import 'package:equatable/equatable.dart';" : ''}

abstract class ${pascalName}Event$equatableExtends {
  const ${pascalName}Event();$propsOverride
}

class ${pascalName}Started extends ${pascalName}Event {}
''';
  }

  static String getBlocStateTemplate(String featureName, CliConfig config) {
    final pascalName = FileUtils.toPascalCase(featureName);
    final equatableExtends = config.useEquatable ? ' extends Equatable' : '';
    final propsOverride = config.useEquatable
        ? '''
  
  @override
  List<Object> get props => [];'''
        : '';

    return '''
${config.useEquatable ? "import 'package:equatable/equatable.dart';" : ''}

abstract class ${pascalName}State$equatableExtends {
  const ${pascalName}State();$propsOverride
}

class ${pascalName}Initial extends ${pascalName}State {}

class ${pascalName}Loading extends ${pascalName}State {}

class ${pascalName}Loaded extends ${pascalName}State {}

class ${pascalName}Error extends ${pascalName}State {
  final String message;
  
  const ${pascalName}Error(this.message);${config.useEquatable ? '''
  
  @override
  List<Object> get props => [message];''' : ''}
}
''';
  }

  static String getCubitTemplate(String featureName, CliConfig config) {
    final pascalName = FileUtils.toPascalCase(featureName);

    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/${featureName}_repository.dart';
import '${featureName}_state.dart';

class ${pascalName}Cubit extends Cubit<${pascalName}State> {
  final ${pascalName}Repository _repository;

  ${pascalName}Cubit(this._repository) : super(${pascalName}Initial());

  Future<void> loadData() async {
    emit(${pascalName}Loading());
    try {
      await _repository.get${pascalName}s();
      emit(${pascalName}Loaded());
    } catch (e) {
      emit(${pascalName}Error(e.toString()));
    }
  }

  void showError(String message) {
    emit(${pascalName}Error(message));
  }
}
''';
  }

  static String getCubitStateTemplate(String featureName, CliConfig config) {
    final pascalName = FileUtils.toPascalCase(featureName);
    final equatableExtends = config.useEquatable ? ' extends Equatable' : '';
    final propsOverride = config.useEquatable
        ? '''
  
  @override
  List<Object> get props => [];'''
        : '';

    return '''
${config.useEquatable ? "import 'package:equatable/equatable.dart';" : ''}

abstract class ${pascalName}State$equatableExtends {
  const ${pascalName}State();$propsOverride
}

class ${pascalName}Initial extends ${pascalName}State {}

class ${pascalName}Loading extends ${pascalName}State {}

class ${pascalName}Loaded extends ${pascalName}State {}

class ${pascalName}Error extends ${pascalName}State {
  final String message;
  
  const ${pascalName}Error(this.message);${config.useEquatable ? '''
  
  @override
  List<Object> get props => [message];''' : ''}
}
''';
  }

  static String getRepositoryTemplate(String featureName) {
    final pascalName = FileUtils.toPascalCase(featureName);

    return '''
import '../model/${featureName}_model.dart';

abstract class ${pascalName}Repository {
  Future<List<${pascalName}Model>> get${pascalName}s();
  Future<${pascalName}Model> get${pascalName}ById(String id);
  Future<${pascalName}Model> create$pascalName(${pascalName}Model $featureName);
  Future<${pascalName}Model> update$pascalName(${pascalName}Model $featureName);
  Future<void> delete$pascalName(String id);
}
''';
  }

  static String getRepositoryImplTemplate(String featureName) {
    final pascalName = FileUtils.toPascalCase(featureName);

    return '''
import '../../../core/service/api_service.dart';
import '../model/${featureName}_model.dart';
import '${featureName}_repository.dart';

class ${pascalName}RepositoryImpl implements ${pascalName}Repository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<${pascalName}Model>> get${pascalName}s() async {
    try {
      final response = await _apiService.get('/${featureName}s');
      final List<dynamic> data = response['data'];
      return data.map((json) => ${pascalName}Model.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch ${featureName}s: \$e');
    }
  }

  @override
  Future<${pascalName}Model> get${pascalName}ById(String id) async {
    try {
      final response = await _apiService.get('/${featureName}s/\$id');
      return ${pascalName}Model.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to fetch $featureName: \$e');
    }
  }

  @override
  Future<${pascalName}Model> create$pascalName(${pascalName}Model $featureName) async {
    try {
      final response = await _apiService.post('/${featureName}s', $featureName.toJson());
      return ${pascalName}Model.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to create $featureName: \$e');
    }
  }

  @override
  Future<${pascalName}Model> update$pascalName(${pascalName}Model $featureName) async {
    try {
      final response = await _apiService.post('/${featureName}s/\${$featureName.id}', $featureName.toJson());
      return ${pascalName}Model.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to update $featureName: \$e');
    }
  }

  @override
  Future<void> delete$pascalName(String id) async {
    try {
      await _apiService.get('/${featureName}s/\$id');
    } catch (e) {
      throw Exception('Failed to delete $featureName: \$e');
    }
  }
}
''';
  }

  static String getModelTemplate(String featureName, CliConfig config) {
    final pascalName = FileUtils.toPascalCase(featureName);
    final equatableExtends = config.useEquatable ? ' extends Equatable' : '';
    final equatableImport =
        config.useEquatable ? "import 'package:equatable/equatable.dart';" : '';
    final propsOverride = config.useEquatable
        ? '''

  @override
  List<Object> get props => [id, name, createdAt, updatedAt];'''
        : '';

    return '''
$equatableImport

class ${pascalName}Model$equatableExtends {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ${pascalName}Model({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ${pascalName}Model.fromJson(Map<String, dynamic> json) {
    return ${pascalName}Model(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ${pascalName}Model.fromMap(Map<String, dynamic> map) {
    return ${pascalName}Model(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  ${pascalName}Model copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ${pascalName}Model(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }$propsOverride
}
''';
  }

  // View Templates
  static String getScreenTemplate(
      String viewName, String featureName, CliConfig config) {
    final pascalViewName = FileUtils.toPascalCase(viewName);
    final pascalFeatureName = FileUtils.toPascalCase(featureName);
    final stateFolder = config.stateManagement == 'bloc' ? 'bloc' : 'cubit';
    final stateClass =
        '$pascalFeatureName${config.stateManagement == 'bloc' ? 'Bloc' : 'Cubit'}';

    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../$stateFolder/${featureName}_${config.stateManagement}.dart';
import '../$stateFolder/${featureName}_state.dart';
import '../$stateFolder/${featureName}_event.dart';
${viewName == 'home_screen' ? "import 'components/bottom_navbar.dart';" : ''}

class $pascalViewName extends StatelessWidget {
  const $pascalViewName({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<$stateClass>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('$pascalViewName'),
      ),
      body: BlocBuilder<$stateClass, ${pascalFeatureName}State>(
        builder: (context, state) {
          if (state is ${pascalFeatureName}Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ${pascalFeatureName}Error) {
            return Center(child: Text('Error: \${state.message}'));
          }
          
          if (state is ${pascalFeatureName}Loaded) {
            return const Center(
              child: Text('$pascalViewName Content'),
            );
          }
          
          return const Center(child: Text('Initial State'));
        },
      ),
      ${viewName == 'home_screen' ? 'bottomNavigationBar: const BottomNavbar(),' : ''}
    );
  }
}
''';
  }

  static String getBottomNavbarTemplate() {
    return '''
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
''';
  }
}
