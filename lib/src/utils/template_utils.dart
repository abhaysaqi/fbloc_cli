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
    final blocEventImport = config.stateManagement == 'bloc'
        ? "import 'app/features/home/bloc/home_event.dart';"
        : '';

    if (config.navigation == 'go_router') {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/features/home/$stateFolder/home_${config.stateManagement}.dart';
import 'app/features/home/repository/home_repository.dart';
import 'app/features/home/repository/home_repository_impl.dart';
import 'app/core/service/api_service.dart';
$blocEventImport

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
import 'app/core/service/api_service.dart';
$blocEventImport

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
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  
  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  
  // On colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  
  // Additional colors
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);
}
''';
  }

  static String getApiEndpointsTemplate() {
    return '''
class ApiEndpoints {
  // Base URL from environment
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://reqres.in/api');

  // 🏠 Home Endpoints
  static const String homes = "\$baseUrl/users";
  static String homeById(String id) => "\$baseUrl/users/\$id";

  // 👤 Auth Endpoints
  static const String login = "\$baseUrl/login";
  static const String register = "\$baseUrl/register";

  // 📰 Example extra endpoint (if you add more features later)
  static const String categories = "\$baseUrl/categories";
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
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://reqres.in/api');
  static const String apiKey = String.fromEnvironment('API_KEY', defaultValue: 'reqres-free-v1');
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
  // Common strings
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String ok = 'OK';
  static const String save = 'Save';
  static const String delete = 'Delete';
  
  // Home screen strings
  static const String homeScreen = 'Home';
  static const String noItemsFound = 'No items found';
  static const String initialState = 'Initial State';
  static const String errorPrefix = 'Error:';
  static const String idPrefix = 'ID:';
  
  // Drawer strings
  static const String welcomeUser = 'Welcome User';
  static const String userEmail = 'user@example.com';
  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String helpSupport = 'Help & Support';
  static const String logout = 'Logout';
  
  // Bottom navigation strings
  static const String search = 'Search';
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

  static String getCommonResponseTemplate() {
    return '''
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: fromJsonT != null && json['data'] != null 
          ? fromJsonT(json['data']) 
          : null,
      statusCode: json['status_code'] as int?,
    );
  }

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
''';
  }

  // API Service Template
  static String getApiServiceTemplate(CliConfig config) {
    if (config.networkPackage == 'dio') {
      return '''
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../utils/api_response.dart';
import 'api_endpoints.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: AppConstants.timeoutDuration,
      receiveTimeout: AppConstants.timeoutDuration,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer \${AppConstants.apiKey}',
      },
    ));
  }

  late final Dio _dio;

  Future<ApiResponse<T>> get<T>(String endpoint, T Function(dynamic)? fromJson) async {
    try {
      final response = await _dio.get(endpoint);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error('Network error: \${e.message}', statusCode: e.response?.statusCode);
    }
  }

  Future<ApiResponse<T>> post<T>(String endpoint, Map<String, dynamic> data, T Function(dynamic)? fromJson) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error('Network error: \${e.message}', statusCode: e.response?.statusCode);
    }
  }
}
''';
    } else {
      return '''
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/api_response.dart';
import 'api_endpoints.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<ApiResponse<T>> get<T>(String endpoint, T Function(dynamic)? fromJson) async {
    try {
      final response = await http.get(
        Uri.parse('\${ApiEndpoints.baseUrl}\$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \${AppConstants.apiKey}',
        },
      ).timeout(AppConstants.timeoutDuration);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: \$e');
    }
  }

  Future<ApiResponse<T>> post<T>(String endpoint, Map<String, dynamic> data, T Function(dynamic)? fromJson) async {
    try {
      final response = await http.post(
        Uri.parse('\${ApiEndpoints.baseUrl}\$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \${AppConstants.apiKey}',
        },
        body: jsonEncode(data),
      ).timeout(AppConstants.timeoutDuration);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: \$e');
    }
  }

  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(dynamic)? fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonData = jsonDecode(response.body);
      return ApiResponse.fromJson(jsonData, fromJson);
    } else {
      return ApiResponse.error('HTTP \${response.statusCode}: \${response.body}', statusCode: response.statusCode);
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
import '../repository/${featureName}_repository.dart';
import '${featureName}_event.dart';
import '${featureName}_state.dart';
import '../model/${featureName}_model.dart';

class ${pascalName}Bloc extends Bloc<${pascalName}Event, ${pascalName}State> {
  final ${pascalName}Repository _repository;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  final List<${pascalName}Model> _items = [];

  ${pascalName}Bloc(this._repository) : super(${pascalName}Initial()) {
    on<${pascalName}Started>(_onStarted);
    on<${pascalName}LoadMore>(_onLoadMore);
  }

  Future<void> _onStarted(${pascalName}Started event, Emitter<${pascalName}State> emit) async {
    if (_isLoading) return;
    _isLoading = true;
    emit(${pascalName}Loading());
    try {
      _currentPage = 1;
      _hasMore = true;
      _items.clear();
      final response = await _repository.get${pascalName}s(page: _currentPage, limit: 10);
      if (response.success && response.data != null) {
        _items.addAll(response.data!);
        _hasMore = response.data!.isNotEmpty;
        _currentPage++;
        emit(${pascalName}Loaded(List<${pascalName}Model>.from(_items), hasMore: _hasMore));
      } else {
        emit(${pascalName}Error(response.message));
      }
    } catch (e) {
      emit(${pascalName}Error(e.toString()));
    }
    _isLoading = false;
  }

  Future<void> _onLoadMore(${pascalName}LoadMore event, Emitter<${pascalName}State> emit) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    try {
      final response = await _repository.get${pascalName}s(page: _currentPage, limit: 10);
      if (response.success && response.data != null) {
        if (response.data!.isEmpty) {
          _hasMore = false;
        } else {
          _items.addAll(response.data!);
          _currentPage++;
        }
        emit(${pascalName}Loaded(List<${pascalName}Model>.from(_items), hasMore: _hasMore));
      } else {
        emit(${pascalName}Error(response.message));
      }
    } catch (e) {
      emit(${pascalName}Error(e.toString()));
    }
    _isLoading = false;
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

class ${pascalName}LoadMore extends ${pascalName}Event {}
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
import '../model/${featureName}_model.dart';

abstract class ${pascalName}State$equatableExtends {
  const ${pascalName}State();$propsOverride
}

class ${pascalName}Initial extends ${pascalName}State {}

class ${pascalName}Loading extends ${pascalName}State {}

class ${pascalName}Loaded extends ${pascalName}State {
  final List<${pascalName}Model> items;
  final bool hasMore;

  const ${pascalName}Loaded(this.items, {this.hasMore = true});
}

class ${pascalName}Error extends ${pascalName}State {
  final String message;
  
  const ${pascalName}Error(this.message);
}
''';
  }

  static String getCubitTemplate(String featureName, CliConfig config) {
    final pascalName = FileUtils.toPascalCase(featureName);

    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/${featureName}_repository.dart';
import '${featureName}_state.dart';
import '../model/${featureName}_model.dart';

class ${pascalName}Cubit extends Cubit<${pascalName}State> {
  final ${pascalName}Repository _repository;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  final List<${pascalName}Model> _items = [];

  ${pascalName}Cubit(this._repository) : super(${pascalName}Initial());

  Future<void> loadData({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    if (refresh) {
      _currentPage = 1;
      _items.clear();
      _hasMore = true;
      emit(${pascalName}Loading());
    }
    try {
      if (!_hasMore) {
        _isLoading = false;
        return;
      }
      final response = await _repository.get${pascalName}s(page: _currentPage, limit: 10);
      if (response.success && response.data != null) {
        if (response.data!.isEmpty) {
          _hasMore = false;
        } else {
          _items.addAll(response.data!);
          _currentPage++;
        }
        emit(${pascalName}Loaded(List<${pascalName}Model>.from(_items), hasMore: _hasMore));
      } else {
        emit(${pascalName}Error(response.message));
      }
    } catch (e) {
      emit(${pascalName}Error('Failed to load data'));
    }
    _isLoading = false;
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
import '../model/${featureName}_model.dart';

abstract class ${pascalName}State$equatableExtends {
  const ${pascalName}State();$propsOverride
}

class ${pascalName}Initial extends ${pascalName}State {}

class ${pascalName}Loading extends ${pascalName}State {}

class ${pascalName}Loaded extends ${pascalName}State {
  final List<${pascalName}Model> items;
  final bool hasMore;

  const ${pascalName}Loaded(this.items, {this.hasMore = true});
}

class ${pascalName}Error extends ${pascalName}State {
  final String message;
  
  const ${pascalName}Error(this.message);
}
''';
  }

  static String getRepositoryTemplate(String featureName) {
    final pascalName = FileUtils.toPascalCase(featureName);

    return '''
import '../model/${featureName}_model.dart';
import '../../../core/utils/api_response.dart';

abstract class ${pascalName}Repository {
  Future<ApiResponse<List<${pascalName}Model>>> get${pascalName}s({int page = 1, int limit = 10});
  Future<ApiResponse<${pascalName}Model>> get${pascalName}ById(String id);
  Future<ApiResponse<${pascalName}Model>> create$pascalName(${pascalName}Model $featureName);
  Future<ApiResponse<${pascalName}Model>> update$pascalName(${pascalName}Model $featureName);
  Future<ApiResponse<void>> delete$pascalName(String id);
}
''';
  }

  static String getRepositoryImplTemplate(String featureName) {
    final pascalName = FileUtils.toPascalCase(featureName);

    return '''
import '../../../core/service/api_service.dart';
import '../model/${featureName}_model.dart';
import '${featureName}_repository.dart';
import '../../../core/service/api_endpoints.dart';
import '../../../core/utils/api_response.dart';

class ${pascalName}RepositoryImpl implements ${pascalName}Repository {
  final ApiService _apiService = ApiService();

  @override
  Future<ApiResponse<List<${pascalName}Model>>> get${pascalName}s({int page = 1, int limit = 10}) async {
    final response = await _apiService.get<List<${pascalName}Model>>(
      '\${ApiEndpoints.${featureName}s}?page=\$page&limit=\$limit',
      (data) => (data as List).map((item) => ${pascalName}Model.fromJson(item)).toList(),
    );
    return response;
  }

  @override
  Future<ApiResponse<${pascalName}Model>> get${pascalName}ById(String id) async {
    final response = await _apiService.get<${pascalName}Model>(
      ApiEndpoints.${featureName}ById(id),
      (data) => ${pascalName}Model.fromJson(data),
    );
    return response;
  }

  @override
  Future<ApiResponse<${pascalName}Model>> create$pascalName(${pascalName}Model $featureName) async {
    final response = await _apiService.post<${pascalName}Model>(
      ApiEndpoints.${featureName}s,
      $featureName.toJson(),
      (data) => ${pascalName}Model.fromJson(data),
    );
    return response;
  }

  @override
  Future<ApiResponse<${pascalName}Model>> update$pascalName(${pascalName}Model $featureName) async {
    final response = await _apiService.post<${pascalName}Model>(
      ApiEndpoints.${featureName}ById($featureName.id),
      $featureName.toJson(),
      (data) => ${pascalName}Model.fromJson(data),
    );
    return response;
  }

  @override
  Future<ApiResponse<void>> delete$pascalName(String id) async {
    final response = await _apiService.get<void>(
      ApiEndpoints.${featureName}ById(id),
      null,
    );
    return response;
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

  static String getResponseModelTemplate(String featureName, CliConfig config) {
    final pascalName = FileUtils.toPascalCase(featureName);
    return '''
import '${featureName}_model.dart';

class ${pascalName}Response {
  final bool success;
  final String message;
  final List<${pascalName}Model> data;

  ${pascalName}Response({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ${pascalName}Response.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => ${pascalName}Model.fromJson(e as Map<String, dynamic>))
        .toList();
    return ${pascalName}Response(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: list,
    );
  }
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
    final eventImport = config.stateManagement == 'bloc'
        ? "import '../$stateFolder/${featureName}_event.dart';"
        : '';
    final itemVar = 'item';

    if (viewName == 'home_screen') {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../$stateFolder/${featureName}_${config.stateManagement}.dart';
import '../$stateFolder/${featureName}_state.dart';
$eventImport
import 'components/bottom_navbar.dart';
import 'components/app_drawer.dart';
import '../../../core/utils/strings.dart';
import '../../../core/theme/app_colors.dart';

class $pascalViewName extends StatefulWidget {
  const $pascalViewName({super.key});

  @override
  State<$pascalViewName> createState() => _${pascalViewName}State();
}

class _${pascalViewName}State extends State<$pascalViewName> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeScreen),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<$stateClass, ${pascalFeatureName}State>(
        builder: (context, state) {
          if (state is ${pascalFeatureName}Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ${pascalFeatureName}Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('\${AppStrings.errorPrefix} \${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      ${config.stateManagement == 'bloc' ? 'context.read<$stateClass>().add(${pascalFeatureName}Started());' : 'context.read<$stateClass>().loadData(refresh: true);'}
                    },
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          
          if (state is ${pascalFeatureName}Loaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text(AppStrings.noItemsFound));
            }
            return RefreshIndicator(
              onRefresh: () async {
                ${config.stateManagement == 'bloc' ? 'context.read<$stateClass>().add(${pascalFeatureName}Started());' : 'context.read<$stateClass>().loadData(refresh: true);'}
              },
              child: ListView.builder(
                itemCount: items.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final $itemVar = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text($itemVar.name),
                      subtitle: Text('\${AppStrings.idPrefix} \${$itemVar.id}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Handle item tap
                      },
                    ),
                  );
                },
              ),
            );
          }
          
          return const Center(child: Text(AppStrings.initialState));
        },
      ),
      bottomNavigationBar: BottomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
''';
    } else {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../$stateFolder/${featureName}_${config.stateManagement}.dart';
import '../$stateFolder/${featureName}_state.dart';
$eventImport

class $pascalViewName extends StatelessWidget {
  const $pascalViewName({super.key});

  @override
  Widget build(BuildContext context) {
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
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text('No items'));
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final $itemVar = items[index];
                return ListTile(
                  title: Text($itemVar.name),
                  subtitle: Text($itemVar.id),
                );
              },
            );
          }
          
          return const Center(child: Text(AppStrings.initialState));
        },
      ),
    );
  }
}
''';
    }
  }

  static String getBottomNavbarTemplate() {
    return '''
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/strings.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: AppStrings.search,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: AppStrings.profile,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: AppStrings.settings,
        ),
      ],
    );
  }
}
''';
  }

  static String getAppDrawerTemplate() {
    return '''
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/strings.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.onPrimary,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  AppStrings.welcomeUser,
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppStrings.userEmail,
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text(AppStrings.home),
            onTap: () {
              Navigator.pop(context);
              // Navigate to home
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(AppStrings.profile),
            onTap: () {
              Navigator.pop(context);
              // Navigate to profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(AppStrings.settings),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text(AppStrings.helpSupport),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(AppStrings.logout),
            onTap: () {
              Navigator.pop(context);
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}
''';
  }
}
