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

// Auth-specific API Endpoints (add to existing getApiEndpointsTemplate)
  static String getApiEndpointsTemplate(CliConfig config) {
    return '''
class ApiEndpoints {
  static const String baseUrl = 'https://api.example.com';
  
  // Home endpoints
  static const String homes = '/homes';
  static String homeById(String id) => '/homes/\$id';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';
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
  static const String home = '/home';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';  
  static const String forgotPassword = '/forgot-password';
  static const String otpVerify = '/otp-verify';
  static const String resetPassword = '/reset-password';
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

  // ============ AUTH MODELS ============

  static String getUserModelTemplate(CliConfig config) {
    final useEquatable = config.useEquatable;
    return '''
${useEquatable ? "import 'package:equatable/equatable.dart';" : ''}

class UserModel${useEquatable ? ' extends Equatable' : ''} {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'createdAt': createdAt?.toIso8601String(),
  };

  UserModel copyWith({String? id, String? name, String? email, String? photoUrl, DateTime? createdAt}) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

${useEquatable ? '  @override\n  List<Object?> get props => [id, name, email, photoUrl, createdAt];' : ''}
}
''';
  }

  static String getAuthTokensModelTemplate(CliConfig config) {
    final useEquatable = config.useEquatable;
    return '''
${useEquatable ? "import 'package:equatable/equatable.dart';" : ''}

class AuthTokens${useEquatable ? ' extends Equatable' : ''} {
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'] ?? '',
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt?.toIso8601String(),
  };

${useEquatable ? '  @override\n  List<Object?> get props => [accessToken, refreshToken, expiresAt];' : ''}
}
''';
  }

// ============ AUTH REPOSITORY ============

  static String getAuthRepositoryTemplate() {
    return '''
import '../../../core/utils/api_response.dart';
import '../model/auth_tokens.dart';
import '../model/user_model.dart';

abstract class AuthRepository {
  Future<ApiResponse<AuthTokens>> signInWithEmail({required String email, required String password});
  Future<ApiResponse<AuthTokens>> signUpWithEmail({required String name, required String email, required String password});
  Future<ApiResponse<String>> requestPasswordReset(String email);
  Future<ApiResponse<String>> verifyOtp({required String email, required String otp});
  Future<ApiResponse<String>> resetPassword({required String email, required String otp, required String newPassword});
  Future<ApiResponse<UserModel>> getCurrentUser();
  Future<void> logout();
}
''';
  }

  static String getAuthRepositoryImplTemplate(CliConfig config) {
    return '''
import '../../../core/service/api_endpoints.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/service/api_service.dart';
import '../model/auth_tokens.dart';
import '../model/user_model.dart';
import './auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<ApiResponse<AuthTokens>> signInWithEmail({required String email, required String password}) async {
    try {
      final response = await _apiService.post(ApiEndpoints.login, data: {'email': email, 'password': password});
      if (response.success && response.data != null) {
        return ApiResponse.success(data: AuthTokens.fromJson(response.data));
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<AuthTokens>> signUpWithEmail({required String name, required String email, required String password}) async {
    try {
      final response = await _apiService.post(ApiEndpoints.register, data: {'name': name, 'email': email, 'password': password});
      if (response.success && response.data != null) {
        return ApiResponse.success(data: AuthTokens.fromJson(response.data));
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> requestPasswordReset(String email) async {
    try {
      final response = await _apiService.post(ApiEndpoints.forgotPassword, data: {'email': email});
      return response.success ? ApiResponse.success(data: response.message) : ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _apiService.post(ApiEndpoints.verifyOtp, data: {'email': email, 'otp': otp});
      return response.success ? ApiResponse.success(data: response.message) : ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> resetPassword({required String email, required String otp, required String newPassword}) async {
    try {
      final response = await _apiService.post(ApiEndpoints.resetPassword, data: {'email': email, 'otp': otp, 'newPassword': newPassword});
      return response.success ? ApiResponse.success(data: response.message) : ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiEndpoints.profile);
      if (response.success && response.data != null) {
        return ApiResponse.success(data: UserModel.fromJson(response.data));
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    // Clear stored tokens
  }
}
''';
  }

// ============ AUTH BLOC/CUBIT ============

  static String getAuthBlocEventTemplate(CliConfig config) {
    final useEquatable = config.useEquatable;
    return '''
${useEquatable ? "import 'package:equatable/equatable.dart';" : ''}

abstract class AuthEvent${useEquatable ? ' extends Equatable' : ''} {
  const AuthEvent();
${useEquatable ? '  @override\n  List<Object?> get props => [];' : ''}
}

class SignInEmailRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInEmailRequested({required this.email, required this.password});
${useEquatable ? '  @override\n  List<Object?> get props => [email, password];' : ''}
}

class SignUpEmailRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const SignUpEmailRequested({required this.name, required this.email, required this.password});
${useEquatable ? '  @override\n  List<Object?> get props => [name, email, password];' : ''}
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);
${useEquatable ? '  @override\n  List<Object?> get props => [email];' : ''}
}

class OtpVerifyRequested extends AuthEvent {
  final String email;
  final String otp;
  const OtpVerifyRequested({required this.email, required this.otp});
${useEquatable ? '  @override\n  List<Object?> get props => [email, otp];' : ''}
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;
  const ResetPasswordRequested({required this.email, required this.otp, required this.newPassword});
${useEquatable ? '  @override\n  List<Object?> get props => [email, otp, newPassword];' : ''}
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class GetCurrentUserRequested extends AuthEvent {
  const GetCurrentUserRequested();
}
''';
  }

  static String getAuthBlocStateTemplate(CliConfig config) {
    final useEquatable = config.useEquatable;
    return '''
${useEquatable ? "import 'package:equatable/equatable.dart';" : ''}
import '../model/user_model.dart';

abstract class AuthState${useEquatable ? ' extends Equatable' : ''} {
  const AuthState();
${useEquatable ? '  @override\n  List<Object?> get props => [];' : ''}
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel? user;
  const AuthAuthenticated({this.user});
${useEquatable ? '  @override\n  List<Object?> get props => [user];' : ''}
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
${useEquatable ? '  @override\n  List<Object?> get props => [message];' : ''}
}

class PasswordResetEmailSent extends AuthState {
  final String message;
  const PasswordResetEmailSent(this.message);
${useEquatable ? '  @override\n  List<Object?> get props => [message];' : ''}
}

class OtpVerified extends AuthState {
  final String message;
  const OtpVerified(this.message);
${useEquatable ? '  @override\n  List<Object?> get props => [message];' : ''}
}

class PasswordResetSuccess extends AuthState {
  final String message;
  const PasswordResetSuccess(this.message);
${useEquatable ? '  @override\n  List<Object?> get props => [message];' : ''}
}
''';
  }

  static String getAuthBlocTemplate(CliConfig config) {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<SignInEmailRequested>(_onSignInEmailRequested);
    on<SignUpEmailRequested>(_onSignUpEmailRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<OtpVerifyRequested>(_onOtpVerifyRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }

  Future<void> _onSignInEmailRequested(SignInEmailRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.signInWithEmail(email: event.email, password: event.password);
    if (response.success) {
      final userResponse = await _repository.getCurrentUser();
      emit(AuthAuthenticated(user: userResponse.data));
    } else {
      emit(AuthError(response.message ?? 'Sign in failed'));
    }
  }

  Future<void> _onSignUpEmailRequested(SignUpEmailRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.signUpWithEmail(name: event.name, email: event.email, password: event.password);
    if (response.success) {
      final userResponse = await _repository.getCurrentUser();
      emit(AuthAuthenticated(user: userResponse.data));
    } else {
      emit(AuthError(response.message ?? 'Sign up failed'));
    }
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.requestPasswordReset(event.email);
    emit(response.success ? PasswordResetEmailSent(response.data ?? 'OTP sent') : AuthError(response.message ?? 'Failed'));
  }

  Future<void> _onOtpVerifyRequested(OtpVerifyRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.verifyOtp(email: event.email, otp: event.otp);
    emit(response.success ? OtpVerified(response.data ?? 'Verified') : AuthError(response.message ?? 'Failed'));
  }

  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.resetPassword(email: event.email, otp: event.otp, newPassword: event.newPassword);
    emit(response.success ? PasswordResetSuccess(response.data ?? 'Success') : AuthError(response.message ?? 'Failed'));
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onGetCurrentUserRequested(GetCurrentUserRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.getCurrentUser();
    emit(response.success && response.data != null ? AuthAuthenticated(user: response.data) : const AuthUnauthenticated());
  }
}
''';
  }

  static String getAuthCubitStateTemplate(CliConfig config) {
    final useEquatable = config.useEquatable;
    return '''
${useEquatable ? "import 'package:equatable/equatable.dart';" : ''}
import '../../domain/models/user_model.dart';

class AuthCubitState${useEquatable ? ' extends Equatable' : ''} {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  final String? message;

  const AuthCubitState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.message,
  });

  AuthCubitState copyWith({bool? isLoading, bool? isAuthenticated, UserModel? user, String? error, String? message}) {
    return AuthCubitState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      message: message,
    );
  }

${useEquatable ? '  @override\n  List<Object?> get props => [isLoading, isAuthenticated, user, error, message];' : ''}
}
''';
  }

  static String getAuthCubitTemplate(CliConfig config) {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/auth_repository.dart';
import 'auth_cubit_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthCubitState());

  Future<void> signInWithEmail({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, error: null));
    final response = await _repository.signInWithEmail(email: email, password: password);
    if (response.success) {
      final userResponse = await _repository.getCurrentUser();
      emit(state.copyWith(isLoading: false, isAuthenticated: true, user: userResponse.data));
    } else {
      emit(state.copyWith(isLoading: false, error: response.message ?? 'Failed'));
    }
  }

  Future<void> signUpWithEmail({required String name, required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, error: null));
    final response = await _repository.signUpWithEmail(name: name, email: email, password: password);
    if (response.success) {
      final userResponse = await _repository.getCurrentUser();
      emit(state.copyWith(isLoading: false, isAuthenticated: true, user: userResponse.data));
    } else {
      emit(state.copyWith(isLoading: false, error: response.message ?? 'Failed'));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(state.copyWith(isLoading: true, error: null, message: null));
    final response = await _repository.requestPasswordReset(email);
    emit(state.copyWith(isLoading: false, message: response.success ? response.data : null, error: response.success ? null : response.message));
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    emit(state.copyWith(isLoading: true, error: null, message: null));
    final response = await _repository.verifyOtp(email: email, otp: otp);
    emit(state.copyWith(isLoading: false, message: response.success ? response.data : null, error: response.success ? null : response.message));
  }

  Future<void> resetPassword({required String email, required String otp, required String newPassword}) async {
    emit(state.copyWith(isLoading: true, error: null, message: null));
    final response = await _repository.resetPassword(email: email, otp: otp, newPassword: newPassword);
    emit(state.copyWith(isLoading: false, message: response.success ? response.data : null, error: response.success ? null : response.message));
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthCubitState());
  }

  Future<void> getCurrentUser() async {
    emit(state.copyWith(isLoading: true, error: null));
    final response = await _repository.getCurrentUser();
    emit(state.copyWith(isLoading: false, isAuthenticated: response.success, user: response.data));
  }
}
''';
  }

// ============ AUTH SCREENS ============

  static String getSignInScreenTemplate(CliConfig config) {
    final isBloc = config.stateManagement == 'bloc';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes/route_names.dart';
import '../../bloc/auth_${isBloc ? 'bloc' : 'cubit'}.dart';
${isBloc ? "import '../../bloc/auth_event.dart';\nimport '../../bloc/auth_state.dart';" : "import '../../bloc/auth_cubit_state.dart';"}
import '../components/auth_text_field.dart';
import '../components/password_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      ${isBloc ? 'context.read<AuthBloc>().add(SignInEmailRequested(email: _emailController.text.trim(), password: _passwordController.text));' : 'context.read<AuthCubit>().signInWithEmail(email: _emailController.text.trim(), password: _passwordController.text);'}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ${isBloc ? 'BlocConsumer<AuthBloc, AuthState>' : 'BlocConsumer<AuthCubit, AuthCubitState>'}(
        listener: (context, state) {
          ${isBloc ? '''if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed(RouteNames.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }''' : '''if (state.isAuthenticated) {
            Navigator.of(context).pushReplacementNamed(RouteNames.home);
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }'''}
        },
        builder: (context, state) {
          ${isBloc ? 'final isLoading = state is AuthLoading;' : 'final isLoading = state.isLoading;'}
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 40),
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'Enter email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : !v.contains('@') ? 'Invalid email' : null,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter password',
                      validator: (v) => v == null || v.isEmpty ? 'Required' : v.length < 6 ? 'Min 6 chars' : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : () => Navigator.of(context).pushNamed(RouteNames.forgotPassword),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleSignIn,
                      child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sign In'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have account? "),
                        TextButton(
                          onPressed: isLoading ? null : () => Navigator.of(context).pushNamed(RouteNames.signUp),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
''';
  }

  static String getSignUpScreenTemplate(CliConfig config) {
    final isBloc = config.stateManagement == 'bloc';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes/route_names.dart';
import '../../bloc/auth_${isBloc ? 'bloc' : 'cubit'}.dart';
${isBloc ? "import '../../bloc/auth_event.dart';\nimport '../../bloc/auth_state.dart';" : "import '../../bloc/auth_cubit_state.dart';"}
import '../components/auth_text_field.dart';
import '../components/password_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      ${isBloc ? "context.read<AuthBloc>().add(SignUpEmailRequested(name: _nameController.text.trim(), email: _emailController.text.trim(), password: _passwordController.text));" : "context.read<AuthCubit>().signUpWithEmail(name: _nameController.text.trim(), email: _emailController.text.trim(), password: _passwordController.text);"}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ${isBloc ? 'BlocConsumer<AuthBloc, AuthState>' : 'BlocConsumer<AuthCubit, AuthCubitState>'}(
        listener: (context, state) {
          ${isBloc ? '''
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed(RouteNames.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }''' : '''
          if (state.isAuthenticated) {
            Navigator.of(context).pushReplacementNamed(RouteNames.home);
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }'''}
        },
        builder: (context, state) {
          ${isBloc ? 'final isLoading = state is AuthLoading;' : 'final isLoading = state.isLoading;'}
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Create Account', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 40),
                    AuthTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'Enter your full name',
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'Enter email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : !v.contains('@') ? 'Invalid email' : null,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter password',
                      validator: (v) => v == null || v.isEmpty ? 'Required' : v.length < 6 ? 'Min 6 chars' : null,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hintText: 'Re-enter password',
                      validator: (v) => v == null || v.isEmpty ? 'Required' : v != _passwordController.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleSignUp,
                      child: isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Sign Up'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        TextButton(
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
''';
  }

  static String getForgotPasswordScreenTemplate(CliConfig config) {
    final isBloc = config.stateManagement == 'bloc';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes/route_names.dart';
import '../../bloc/auth_${isBloc ? 'bloc' : 'cubit'}.dart';
${isBloc ? "import '../../bloc/auth_event.dart';\nimport '../../bloc/auth_state.dart';" : "import '../../bloc/auth_cubit_state.dart';"}
import '../components/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      ${isBloc ? "context.read<AuthBloc>().add(ForgotPasswordRequested(_emailController.text.trim()));" : "context.read<AuthCubit>().forgotPassword(_emailController.text.trim());"}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: ${isBloc ? 'BlocConsumer<AuthBloc, AuthState>' : 'BlocConsumer<AuthCubit, AuthCubitState>'}(
        listener: (context, state) {
          ${isBloc ? '''
          if (state is PasswordResetEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.of(context).pushNamed(RouteNames.otpVerify, arguments: _emailController.text.trim());
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }''' : '''
          if (state.message != null && !state.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
            Navigator.of(context).pushNamed(RouteNames.otpVerify, arguments: _emailController.text.trim());
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }'''}
        },
        builder: (context, state) {
          ${isBloc ? 'final isLoading = state is AuthLoading;' : 'final isLoading = state.isLoading;'}
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.lock_reset, size: 80, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 24),
                  Text('Reset Password', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Enter your email to receive an OTP', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.isEmpty ? 'Please enter your email' : !v.contains('@') ? 'Please enter a valid email' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Send OTP'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Back to Sign In'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
''';
  }

  static String getOtpScreenTemplate(CliConfig config) {
    final isBloc = config.stateManagement == 'bloc';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes/route_names.dart';
import '../../bloc/auth_${isBloc ? 'bloc' : 'cubit'}.dart';
${isBloc ? "import '../../bloc/auth_event.dart';\nimport '../../bloc/auth_state.dart';" : "import '../../bloc/auth_cubit_state.dart';"}
import '../components/otp_input_field.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    if (_formKey.currentState?.validate() ?? false) {
      ${isBloc ? "context.read<AuthBloc>().add(OtpVerifyRequested(email: widget.email, otp: _otpController.text.trim()));" : "context.read<AuthCubit>().verifyOtp(email: widget.email, otp: _otpController.text.trim());"}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: ${isBloc ? 'BlocConsumer<AuthBloc, AuthState>' : 'BlocConsumer<AuthCubit, AuthCubitState>'}(
        listener: (context, state) {
          ${isBloc ? '''
          if (state is OtpVerified) {
            Navigator.of(context).pushReplacementNamed(
              RouteNames.resetPassword,
              arguments: {'email': widget.email, 'otp': _otpController.text.trim()},
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }''' : '''
          if (state.message != null && !state.isLoading) {
            Navigator.of(context).pushReplacementNamed(
              RouteNames.resetPassword,
              arguments: {'email': widget.email, 'otp': _otpController.text.trim()},
            );
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }'''}
        },
        builder: (context, state) {
          ${isBloc ? 'final isLoading = state is AuthLoading;' : 'final isLoading = state.isLoading;'}
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.mark_email_read, size: 80, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 24),
                  Text('Verify OTP', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Enter the OTP sent to', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  Text(widget.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  OtpInputField(
                    controller: _otpController,
                    length: 6,
                    validator: (v) => v == null || v.isEmpty ? 'Please enter OTP' : v.length < 6 ? 'Please enter complete OTP' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleVerify,
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Verify OTP'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            ${isBloc ? "context.read<AuthBloc>().add(ForgotPasswordRequested(widget.email));" : "context.read<AuthCubit>().forgotPassword(widget.email);"}
                          },
                    child: const Text('Resend OTP'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
''';
  }

  static String getResetPasswordScreenTemplate(CliConfig config) {
    final isBloc = config.stateManagement == 'bloc';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes/route_names.dart';
import '../../bloc/auth_${isBloc ? 'bloc' : 'cubit'}.dart';
${isBloc ? "import '../../bloc/auth_event.dart';\nimport '../../bloc/auth_state.dart';" : "import '../../bloc/auth_cubit_state.dart';"}
import '../components/password_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleReset() {
    if (_formKey.currentState?.validate() ?? false) {
      ${isBloc ? "context.read<AuthBloc>().add(ResetPasswordRequested(email: widget.email, otp: widget.otp, newPassword: _passwordController.text));" : "context.read<AuthCubit>().resetPassword(email: widget.email, otp: widget.otp, newPassword: _passwordController.text);"}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: ${isBloc ? 'BlocConsumer<AuthBloc, AuthState>' : 'BlocConsumer<AuthCubit, AuthCubitState>'}(
        listener: (context, state) {
          ${isBloc ? '''
          if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.signIn, (route) => false);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }''' : '''
          if (state.message != null && !state.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
            Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.signIn, (route) => false);
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }'''}
        },
        builder: (context, state) {
          ${isBloc ? 'final isLoading = state is AuthLoading;' : 'final isLoading = state.isLoading;'}
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.lock_open, size: 80, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 24),
                  Text('Create New Password', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Enter your new password', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  PasswordField(
                    controller: _passwordController,
                    label: 'New Password',
                    hintText: 'Enter new password',
                    validator: (v) => v == null || v.isEmpty ? 'Please enter new password' : v.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hintText: 'Re-enter new password',
                    validator: (v) => v == null || v.isEmpty ? 'Please confirm your password' : v != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleReset,
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Reset Password'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
''';
  }

// ============ AUTH COMPONENTS ============

  static String getAuthTextFieldTemplate() {
    return '''
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
''';
  }

  static String getPasswordFieldTemplate() {
    return '''
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}
''';
  }

  static String getOtpInputFieldTemplate() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final int length;
  final String? Function(String?)? validator;

  const OtpInputField({super.key, required this.controller, this.length = 6, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: length,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 8, fontWeight: FontWeight.bold),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        counterText: '',
        hintText: '• ' * length,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      ),
      validator: validator,
    );
  }
}
''';
  }
}
