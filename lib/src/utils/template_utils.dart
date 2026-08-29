import 'dart:math';

import '../models/cli_config.dart';
import 'file_utils.dart';
// all templates files
class TemplateUtils {
  // Pubspec Template
  static String getPubspecTemplate(String projectName, CliConfig config) {
    final dependencies = <String>[
      'flutter:\n    sdk: flutter',
      'flutter_bloc: ^9.1.1',
      'flutter_secure_storage: ^9.2.2',
      'hive_ce: ^2.10.1',
      'hive_ce_flutter: ^2.3.0',
      'get_it: ^8.0.3',
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
  // Main Template
  static String getMainTemplate(CliConfig config) {
    final stateFolder = config.stateManagement == 'bloc' ? 'bloc' : 'cubit';
    final stateClassSuffix =
        config.stateManagement == 'bloc' ? 'Bloc' : 'Cubit';
    final authBlocEventImport = config.stateManagement == 'bloc'
        ? "import 'app/features/auth/$stateFolder/auth_event.dart';"
        : '';
    final homeBlocEventImport = config.stateManagement == 'bloc'
        ? "import 'app/features/home/$stateFolder/home_event.dart';"
        : '';

    final isDio = config.networkPackage == 'dio';
    final clientClass = isDio ? 'DioClient' : 'HttpClient';
    final clientImport = isDio
        ? "import 'app/core/network/client/dio_client.dart';"
        : "import 'app/core/network/client/http_client.dart';";

    if (config.navigation == 'go_router') {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/features/auth/$stateFolder/auth_${config.stateManagement}.dart';
import 'app/features/auth/datasource/auth_remote_datasource.dart';
import 'app/features/auth/datasource/auth_local_datasource.dart';
import 'app/features/auth/repository/auth_repository.dart';
import 'app/features/home/$stateFolder/home_${config.stateManagement}.dart';
import 'app/features/home/datasource/home_remote_datasource.dart';
import 'app/features/home/datasource/home_local_datasource.dart';
import 'app/features/home/repository/home_repository.dart';
$clientImport
import 'app/core/storage/local_db_service.dart';
import 'app/core/storage/secure_storage_service.dart';
import 'app/core/di/injection_container.dart' as di;
$authBlocEventImport
$homeBlocEventImport

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<$clientClass>(create: (_) => di.sl<$clientClass>()),
        RepositoryProvider<SecureStorageService>(create: (_) => di.sl<SecureStorageService>()),
        RepositoryProvider<LocalDbService>(create: (_) => di.sl<LocalDbService>()),
        RepositoryProvider<AuthRemoteDatasource>(create: (context) => AuthRemoteDatasourceImpl(context.read<$clientClass>())),
        RepositoryProvider<AuthLocalDatasource>(create: (context) => AuthLocalDatasourceImpl(context.read<SecureStorageService>(), context.read<LocalDbService>())),
        RepositoryProvider<AuthRepository>(create: (context) => AuthRepositoryImpl(context.read<AuthRemoteDatasource>(), context.read<AuthLocalDatasource>())),
        RepositoryProvider<HomeRemoteDatasource>(create: (context) => HomeRemoteDatasourceImpl(context.read<$clientClass>())),
        RepositoryProvider<HomeLocalDatasource>(create: (context) => HomeLocalDatasourceImpl(context.read<LocalDbService>())),
        RepositoryProvider<HomeRepository>(create: (context) => HomeRepositoryImpl(context.read<HomeRemoteDatasource>(), context.read<HomeLocalDatasource>())),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => Auth$stateClassSuffix(
            context.read<AuthRepository>(),
          )),
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
import 'app/features/auth/$stateFolder/auth_${config.stateManagement}.dart';
import 'app/features/auth/datasource/auth_remote_datasource.dart';
import 'app/features/auth/datasource/auth_local_datasource.dart';
import 'app/features/auth/repository/auth_repository.dart';
import 'app/features/home/$stateFolder/home_${config.stateManagement}.dart';
import 'app/features/home/datasource/home_remote_datasource.dart';
import 'app/features/home/datasource/home_local_datasource.dart';
import 'app/features/home/repository/home_repository.dart';
$clientImport
import 'app/core/storage/local_db_service.dart';
import 'app/core/storage/secure_storage_service.dart';
import 'app/core/di/injection_container.dart' as di;
$authBlocEventImport
$homeBlocEventImport

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<$clientClass>(create: (_) => di.sl<$clientClass>()),
        RepositoryProvider<SecureStorageService>(create: (_) => di.sl<SecureStorageService>()),
        RepositoryProvider<LocalDbService>(create: (_) => di.sl<LocalDbService>()),
        RepositoryProvider<AuthRemoteDatasource>(create: (context) => AuthRemoteDatasourceImpl(context.read<$clientClass>())),
        RepositoryProvider<AuthLocalDatasource>(create: (context) => AuthLocalDatasourceImpl(context.read<SecureStorageService>(), context.read<LocalDbService>())),
        RepositoryProvider<AuthRepository>(create: (context) => AuthRepositoryImpl(context.read<AuthRemoteDatasource>(), context.read<AuthLocalDatasource>())),
        RepositoryProvider<HomeRemoteDatasource>(create: (context) => HomeRemoteDatasourceImpl(context.read<$clientClass>())),
        RepositoryProvider<HomeLocalDatasource>(create: (context) => HomeLocalDatasourceImpl(context.read<LocalDbService>())),
        RepositoryProvider<HomeRepository>(create: (context) => HomeRepositoryImpl(context.read<HomeRemoteDatasource>(), context.read<HomeLocalDatasource>())),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => Auth$stateClassSuffix(
            context.read<AuthRepository>(),
          )),
          BlocProvider(create: (context) => Home$stateClassSuffix(
            context.read<HomeRepository>(),
          )${config.stateManagement == 'bloc' ? '..add(HomeStarted())' : '..loadData()'}),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: AppTheme.lightTheme,
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute: RouteNames.signIn,
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
  final T? data;
  final String? message;
  final int? statusCode;

  const ApiResponse._({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    String? message,
    int? statusCode,
    T? data,
  }) {
    return ApiResponse._(
      success: false,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }
}
''';
  }

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
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConstants.timeoutDuration,
        receiveTimeout: AppConstants.timeoutDuration,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \${AppConstants.apiKey}',
        },
      ),
    );
  }

  late final Dio _dio;

  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.get(
        endpoint,
        queryParameters: query,
        options: Options(headers: headers),
      );
      return _wrapDioResponse<T>(res, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: 'Network error: \${e.message}',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return _wrapDioResponse<T>(res, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: 'Network error: \${e.message}',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse<T>> put<T>({
    required String endpoint, 
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return _wrapDioResponse<T>(res, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: 'Network error: \${e.message}',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.delete(
        endpoint,
        options: Options(headers: headers),
      );
      return _wrapDioResponse<T>(res, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: 'Network error: \${e.message}',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  ApiResponse<T> _wrapDioResponse<T>(Response res, T Function(dynamic)? fromJson) {
    final ok = res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300;
    if (ok) {
      final raw = res.data;
      final parsed = fromJson != null ? fromJson(raw) : raw as T;
      return ApiResponse.success(
        data: parsed,
        message: res.statusMessage,
        statusCode: res.statusCode,
      );
    }
    return ApiResponse.error(
      message: res.statusMessage,
      statusCode: res.statusCode,
      data: res.data,
    );
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

  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('\${ApiEndpoints.baseUrl}\$endpoint').replace(queryParameters: query);
      final res = await http
          .get(uri, headers: _buildHeaders(headers))
          .timeout(AppConstants.timeoutDuration);
      return _handleHttpResponse<T>(res, fromJson);
    } catch (e) {
      return ApiResponse.error(message: 'Network error: \$e');
    }
  }

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('\${ApiEndpoints.baseUrl}\$endpoint');
      final res = await http
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: data == null ? null : jsonEncode(data),
          )
          .timeout(AppConstants.timeoutDuration);
      return _handleHttpResponse<T>(res, fromJson);
    } catch (e) {
      return ApiResponse.error(message: 'Network error: \$e');
    }
  }

  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('\${ApiEndpoints.baseUrl}\$endpoint');
      final res = await http
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: data == null ? null : jsonEncode(data),
          )
          .timeout(AppConstants.timeoutDuration);
      return _handleHttpResponse<T>(res, fromJson);
    } catch (e) {
      return ApiResponse.error(message: 'Network error: \$e');
    }
  }

  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('\${ApiEndpoints.baseUrl}\$endpoint');
      final res = await http
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(AppConstants.timeoutDuration);
      return _handleHttpResponse<T>(res, fromJson);
    } catch (e) {
      return ApiResponse.error(message: 'Network error: \$e');
    }
  }

  Map<String, String> _buildHeaders(Map<String, String>? override) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer \${AppConstants.apiKey}',
      if (override != null) ...override,
    };
  }

  ApiResponse<T> _handleHttpResponse<T>(http.Response res, T Function(dynamic)? fromJson) {
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (ok) {
      final body = res.body.isEmpty ? null : jsonDecode(res.body);
      final parsed = fromJson != null ? fromJson(body) : body as T;
      return ApiResponse.success(
        data: parsed,
        message: res.reasonPhrase,
        statusCode: res.statusCode,
      );
    }
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    return ApiResponse.error(
      message: res.reasonPhrase ?? 'HTTP \${res.statusCode}',
      statusCode: res.statusCode,
      data: body,
    );
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

// Screens
import '../features/home/view/home_screen.dart';
import '../features/auth/view/screens/sign_in_screen.dart';
import '../features/auth/view/screens/sign_up_screen.dart';
import '../features/auth/view/screens/forgot_password_screen.dart';
import '../features/auth/view/screens/otp_screen.dart';
import '../features/auth/view/screens/reset_password_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/sign-in',
  routes: <RouteBase>[
    // Auth flow
    GoRoute(
      path: '/sign-in',
      builder: (BuildContext context, GoRouterState state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (BuildContext context, GoRouterState state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (BuildContext context, GoRouterState state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp-verify',
      builder: (BuildContext context, GoRouterState state) {
        final email = state.extra is String ? state.extra as String : '';
        return OtpScreen(email: email);
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (BuildContext context, GoRouterState state) {
        final args = (state.extra as Map?) ?? const {};
        final email = (args['email'] as String?) ?? '';
        final otp = (args['otp'] as String?) ?? '';
        return ResetPasswordScreen(email: email, otp: otp);
      },
    ),

    // App (post-auth)
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
    ),
  ],
);
''';
    } else {
      return '''
import 'package:flutter/material.dart';

// Screens
import '../features/home/view/home_screen.dart';
import '../features/auth/view/screens/sign_in_screen.dart';
import '../features/auth/view/screens/sign_up_screen.dart';
import '../features/auth/view/screens/forgot_password_screen.dart';
import '../features/auth/view/screens/otp_screen.dart';
import '../features/auth/view/screens/reset_password_screen.dart';
import 'route_names.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth flow
      case RouteNames.signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case RouteNames.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case RouteNames.otpVerify: {
        final email = (settings.arguments as String?) ?? '';
        return MaterialPageRoute(builder: (_) => OtpScreen(email: email));
      }
      case RouteNames.resetPassword: {
        final args = (settings.arguments as Map?) ?? const {};
        final email = (args['email'] as String?) ?? '';
        final otp = (args['otp'] as String?) ?? '';
        return MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email, otp: otp));
      }

      // App (post-auth)
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
''';
    }
  }

//   static String getAppRoutesTemplate(CliConfig config) {
//     if (config.navigation == 'go_router') {
//       return '''
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../features/home/view/home_screen.dart';

// final GoRouter router = GoRouter(
//   initialLocation: '/',
//   routes: <RouteBase>[
//     GoRoute(
//       path: '/',
//       builder: (BuildContext context, GoRouterState state) {
//         return const HomeScreen();
//       },
//     ),
//   ],
// );
// ''';
//     } else {
//       return '''
// import 'package:flutter/material.dart';
// import '../features/home/view/home_screen.dart';
// import 'route_names.dart';

// class AppRoutes {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case RouteNames.home:
//         return MaterialPageRoute(builder: (_) => const HomeScreen());
//       default:
//         return MaterialPageRoute(
//           builder: (_) => const Scaffold(
//             body: Center(
//               child: Text('Page not found'),
//             ),
//           ),
//         );
//     }
//   }
// }
// ''';
//     }
//   }

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
        emit(${pascalName}Error(response.message?? 'Failed'));
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
        emit(${pascalName}Error(response.message?? 'Failed'));
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
        emit(${pascalName}Error(response.message?? 'Failed'));
      }
    } catch (e) {
      emit(${pascalName}Error('Failed to load data: ${e.toString()}'));
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

  static String getRemoteDatasourceTemplate(String featureName, CliConfig config) {
    final pascalName = FileUtils.toPascalCase(featureName);
    final isDio = config.networkPackage == 'dio';
    final isHome = featureName == 'home';
    final dioEndpointList = isHome ? 'ApiEndpoints.homes' : "'/$featureName'";
    final dioEndpointById = isHome ? 'ApiEndpoints.homeById(id)' : "'/$featureName/\$id'";
    final dioEndpointByModelId = isHome ? 'ApiEndpoints.homeById($featureName.id)' : "'/$featureName/\${$featureName.id}'";

    final httpEndpointList = isHome ? '\${ApiEndpoints.baseUrl}\${ApiEndpoints.homes}' : '\${ApiEndpoints.baseUrl}/$featureName';
    final httpEndpointById = isHome ? '\${ApiEndpoints.baseUrl}\${ApiEndpoints.homeById(id)}' : '\${ApiEndpoints.baseUrl}/$featureName/\$id';
    final httpEndpointByModelId = isHome ? '\${ApiEndpoints.baseUrl}\${ApiEndpoints.homeById($featureName.id)}' : '\${ApiEndpoints.baseUrl}/$featureName/\${$featureName.id}';

    if (isDio) {
      return '''
import '../../../core/network/client/dio_client.dart';
import '../model/${featureName}_model.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_endpoints.dart';

abstract class ${pascalName}RemoteDatasource {
  Future<ApiResponse<List<${pascalName}Model>>> get${pascalName}s({int page = 1, int limit = 10});
  Future<ApiResponse<${pascalName}Model>> get${pascalName}ById(String id);
  Future<ApiResponse<${pascalName}Model>> create$pascalName(${pascalName}Model $featureName);
  Future<ApiResponse<${pascalName}Model>> update$pascalName(${pascalName}Model $featureName);
  Future<ApiResponse<void>> delete$pascalName(String id);
}

class ${pascalName}RemoteDatasourceImpl implements ${pascalName}RemoteDatasource {
  final DioClient _dioClient;

  ${pascalName}RemoteDatasourceImpl(this._dioClient);

  @override
  Future<ApiResponse<List<${pascalName}Model>>> get${pascalName}s({int page = 1, int limit = 10}) async {
    try {
      final response = await _dioClient.dio.get(
        '\${$dioEndpointList}?page=\$page&limit=\$limit',
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final list = (response.data as List).map((item) => ${pascalName}Model.fromJson(item)).toList();
        return ApiResponse.success(data: list);
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to fetch data', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<${pascalName}Model>> get${pascalName}ById(String id) async {
    try {
      final response = await _dioClient.dio.get(
        $dioEndpointById,
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return ApiResponse.success(data: ${pascalName}Model.fromJson(response.data));
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to fetch item', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<${pascalName}Model>> create$pascalName(${pascalName}Model $featureName) async {
    try {
      final response = await _dioClient.dio.post(
        $dioEndpointList,
        data: $featureName.toJson(),
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return ApiResponse.success(data: ${pascalName}Model.fromJson(response.data));
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to create item', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<${pascalName}Model>> update$pascalName(${pascalName}Model $featureName) async {
    try {
      final response = await _dioClient.dio.put(
        $dioEndpointByModelId,
        data: $featureName.toJson(),
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return ApiResponse.success(data: ${pascalName}Model.fromJson(response.data));
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to update item', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> delete$pascalName(String id) async {
    try {
      final response = await _dioClient.dio.delete(
        $dioEndpointById,
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return ApiResponse.success();
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to delete item', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }
}
''';
    } else {
      return '''
import 'dart:convert';
import '../../../core/network/client/http_client.dart';
import '../model/${featureName}_model.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_endpoints.dart';

abstract class ${pascalName}RemoteDatasource {
  Future<ApiResponse<List<${pascalName}Model>>> get${pascalName}s({int page = 1, int limit = 10});
  Future<ApiResponse<${pascalName}Model>> get${pascalName}ById(String id);
  Future<ApiResponse<${pascalName}Model>> create$pascalName(${pascalName}Model $featureName);
  Future<ApiResponse<${pascalName}Model>> update$pascalName(${pascalName}Model $featureName);
  Future<ApiResponse<void>> delete$pascalName(String id);
}

class ${pascalName}RemoteDatasourceImpl implements ${pascalName}RemoteDatasource {
  final HttpClient _httpClient;

  ${pascalName}RemoteDatasourceImpl(this._httpClient);

  @override
  Future<ApiResponse<List<${pascalName}Model>>> get${pascalName}s({int page = 1, int limit = 10}) async {
    try {
      final uri = Uri.parse('$httpEndpointList?page=\$page&limit=\$limit');
      final response = await _httpClient.client.get(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as List;
        final list = data.map((item) => ${pascalName}Model.fromJson(item)).toList();
        return ApiResponse.success(data: list);
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to fetch data', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<${pascalName}Model>> get${pascalName}ById(String id) async {
    try {
      final uri = Uri.parse('$httpEndpointById');
      final response = await _httpClient.client.get(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data: ${pascalName}Model.fromJson(data));
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to fetch item', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<${pascalName}Model>> create$pascalName(${pascalName}Model $featureName) async {
    try {
      final uri = Uri.parse('$httpEndpointList');
      final response = await _httpClient.client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode($featureName.toJson()),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data: ${pascalName}Model.fromJson(data));
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to create item', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<${pascalName}Model>> update$pascalName(${pascalName}Model $featureName) async {
    try {
      final uri = Uri.parse('$httpEndpointByModelId');
      final response = await _httpClient.client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode($featureName.toJson()),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data: ${pascalName}Model.fromJson(data));
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to update item', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> delete$pascalName(String id) async {
    try {
      final uri = Uri.parse('$httpEndpointById');
      final response = await _httpClient.client.delete(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success();
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to delete item', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }
}
''';
    }
  }

  static String getLocalDatasourceTemplate(String featureName, CliConfig config) {
    final pascalName = FileUtils.toPascalCase(featureName);

    return '''
import '../../../core/errors/exceptions.dart';
import '../../../core/storage/local_db_service.dart';
import '../../../core/utils/logger.dart';
import '../model/${featureName}_model.dart';

abstract class ${pascalName}LocalDatasource {
  Future<List<${pascalName}Model>> getCached${pascalName}s();
  Future<void> cache${pascalName}s(List<${pascalName}Model> items);
  Future<void> clearCache();
}

class ${pascalName}LocalDatasourceImpl implements ${pascalName}LocalDatasource {
  final LocalDbService _localDbService;
  static const String _boxName = '${featureName}_cache';
  static const String _key = '${featureName}_list';

  const ${pascalName}LocalDatasourceImpl(this._localDbService);

  @override
  Future<List<${pascalName}Model>> getCached${pascalName}s() => _getFromCache();

  @override
  Future<void> cache${pascalName}s(List<${pascalName}Model> items) async {
    try {
      final data = items.map((e) => e.toJson()).toList();
      await _localDbService.put(_boxName, _key, data);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cache $featureName items', e, stackTrace);
      throw const CacheException(message: 'Failed to cache $featureName items');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _localDbService.delete(_boxName, _key);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear $featureName cache', e, stackTrace);
      throw const CacheException(message: 'Failed to clear cache');
    }
  }

  Future<List<${pascalName}Model>> _getFromCache() async {
    try {
      final response = await _localDbService.getValue<List<dynamic>>(_boxName, _key);
      if (response != null) {
        return response
            .map((item) => ${pascalName}Model.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get $featureName from cache', e, stackTrace);
      throw const CacheException(message: 'Failed to load from cache');
    }
  }
}
''';
  }

  static String getRepositoryTemplate(String featureName) {
    final pascalName = FileUtils.toPascalCase(featureName);

    return '''
import '../model/${featureName}_model.dart';
import '../../../core/network/api_response.dart';
import '../datasource/${featureName}_remote_datasource.dart';
import '../datasource/${featureName}_local_datasource.dart';

abstract class ${pascalName}Repository {
  Future<ApiResponse<List<${pascalName}Model>>> get${pascalName}s({int page = 1, int limit = 10});
  Future<ApiResponse<${pascalName}Model>> get${pascalName}ById(String id);
  Future<ApiResponse<${pascalName}Model>> create$pascalName(${pascalName}Model $featureName);
  Future<ApiResponse<${pascalName}Model>> update$pascalName(${pascalName}Model $featureName);
  Future<ApiResponse<void>> delete$pascalName(String id);
}

class ${pascalName}RepositoryImpl implements ${pascalName}Repository {
  final ${pascalName}RemoteDatasource _remoteDatasource;
  final ${pascalName}LocalDatasource _localDatasource;

  ${pascalName}RepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<ApiResponse<List<${pascalName}Model>>> get${pascalName}s({int page = 1, int limit = 10}) async {
    final response = await _remoteDatasource.get${pascalName}s(page: page, limit: limit);
    if (response.success && response.data != null) {
      await _localDatasource.cache${pascalName}s(response.data!);
    }
    return response;
  }

  @override
  Future<ApiResponse<${pascalName}Model>> get${pascalName}ById(String id) async {
    return await _remoteDatasource.get${pascalName}ById(id);
  }

  @override
  Future<ApiResponse<${pascalName}Model>> create$pascalName(${pascalName}Model $featureName) async {
    return await _remoteDatasource.create$pascalName($featureName);
  }

  @override
  Future<ApiResponse<${pascalName}Model>> update$pascalName(${pascalName}Model $featureName) async {
    return await _remoteDatasource.update$pascalName($featureName);
  }

  @override
  Future<ApiResponse<void>> delete$pascalName(String id) async {
    return await _remoteDatasource.delete$pascalName(id);
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
import 'widgets/bottom_navbar.dart';
import 'widgets/app_drawer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_texts.dart';

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
        title: const Text(AppTexts.homeScreen),
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
                  Text('\${AppTexts.errorPrefix} \${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      ${config.stateManagement == 'bloc' ? 'context.read<$stateClass>().add(${pascalFeatureName}Started());' : 'context.read<$stateClass>().loadData(refresh: true);'}
                    },
                    child: const Text(AppTexts.retry),
                  ),
                ],
              ),
            );
          }
          
          if (state is ${pascalFeatureName}Loaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text(AppTexts.noItemsFound));
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
                      subtitle: Text('\${AppTexts.idPrefix} \${$itemVar.id}'),
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
          
          return const Center(child: Text(AppTexts.initialState));
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
import '../../../core/constants/app_texts.dart';

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
          
          return const Center(child: Text(AppTexts.initialState));
        },
      ),
    );
  }
}
''';
    }
  }
// this called only when project create
  static String getBottomNavbarTemplate() {
    return '''
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_texts.dart';

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
          label: AppTexts.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: AppTexts.search,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: AppTexts.profile,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: AppTexts.settings,
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
import '../../../../core/constants/app_texts.dart';

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
                  AppTexts.welcomeUser,
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppTexts.userEmail,
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
            title: const Text(AppTexts.home),
            onTap: () {
              Navigator.pop(context);
              // Navigate to home
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(AppTexts.profile),
            onTap: () {
              Navigator.pop(context);
              // Navigate to profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(AppTexts.settings),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text(AppTexts.helpSupport),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(AppTexts.logout),
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

  static String getAuthRemoteDatasourceTemplate(CliConfig config) {
    final isDio = config.networkPackage == 'dio';

    if (isDio) {
      return '''
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/client/dio_client.dart';
import '../model/auth_tokens.dart';
import '../model/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<ApiResponse<AuthTokens>> signInWithEmail({required String email, required String password});
  Future<ApiResponse<AuthTokens>> signUpWithEmail({required String name, required String email, required String password});
  Future<ApiResponse<String>> requestPasswordReset(String email);
  Future<ApiResponse<String>> verifyOtp({required String email, required String otp});
  Future<ApiResponse<String>> resetPassword({required String email, required String otp, required String newPassword});
  Future<ApiResponse<UserModel>> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final DioClient _dioClient;

  AuthRemoteDatasourceImpl(this._dioClient);

  @override
  Future<ApiResponse<AuthTokens>> signInWithEmail({required String email, required String password}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return ApiResponse.success(data: AuthTokens.fromJson(response.data));
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to sign in', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<AuthTokens>> signUpWithEmail({required String name, required String email, required String password}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return ApiResponse.success(data: AuthTokens.fromJson(response.data));
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to register', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> requestPasswordReset(String email) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final msg = response.data is Map ? (response.data['message'] ?? 'Password reset requested') : 'Password reset requested';
        return ApiResponse.success(data: msg);
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to request password reset', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final msg = response.data is Map ? (response.data['message'] ?? 'OTP verified') : 'OTP verified';
        return ApiResponse.success(data: msg);
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to verify OTP', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> resetPassword({required String email, required String otp, required String newPassword}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.resetPassword,
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final msg = response.data is Map ? (response.data['message'] ?? 'Password reset successfully') : 'Password reset successfully';
        return ApiResponse.success(data: msg);
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to reset password', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.profile);
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return ApiResponse.success(data: UserModel.fromJson(response.data));
      }
      return ApiResponse.error(message: response.statusMessage ?? 'Failed to get current user', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    // Remote logout call if any
  }
}
''';
    } else {
      return '''
import 'dart:convert';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/client/http_client.dart';
import '../model/auth_tokens.dart';
import '../model/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<ApiResponse<AuthTokens>> signInWithEmail({required String email, required String password});
  Future<ApiResponse<AuthTokens>> signUpWithEmail({required String name, required String email, required String password});
  Future<ApiResponse<String>> requestPasswordReset(String email);
  Future<ApiResponse<String>> verifyOtp({required String email, required String otp});
  Future<ApiResponse<String>> resetPassword({required String email, required String otp, required String newPassword});
  Future<ApiResponse<UserModel>> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final HttpClient _httpClient;

  AuthRemoteDatasourceImpl(this._httpClient);

  @override
  Future<ApiResponse<AuthTokens>> signInWithEmail({required String email, required String password}) async {
    try {
      final uri = Uri.parse('\${ApiEndpoints.baseUrl}\${ApiEndpoints.login}');
      final response = await _httpClient.client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data: AuthTokens.fromJson(data));
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to sign in', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<AuthTokens>> signUpWithEmail({required String name, required String email, required String password}) async {
    try {
      final uri = Uri.parse('\${ApiEndpoints.baseUrl}\${ApiEndpoints.register}');
      final response = await _httpClient.client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data: AuthTokens.fromJson(data));
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to register', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> requestPasswordReset(String email) async {
    try {
      final uri = Uri.parse('\${ApiEndpoints.baseUrl}\${ApiEndpoints.forgotPassword}');
      final response = await _httpClient.client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final msg = data is Map ? (data['message'] ?? 'Password reset requested') : 'Password reset requested';
        return ApiResponse.success(data: msg);
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to request reset', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> verifyOtp({required String email, required String otp}) async {
    try {
      final uri = Uri.parse('\${ApiEndpoints.baseUrl}\${ApiEndpoints.verifyOtp}');
      final response = await _httpClient.client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final msg = data is Map ? (data['message'] ?? 'OTP verified') : 'OTP verified';
        return ApiResponse.success(data: msg);
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to verify OTP', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> resetPassword({required String email, required String otp, required String newPassword}) async {
    try {
      final uri = Uri.parse('\${ApiEndpoints.baseUrl}\${ApiEndpoints.resetPassword}');
      final response = await _httpClient.client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp, 'newPassword': newPassword}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final msg = data is Map ? (data['message'] ?? 'Password reset successfully') : 'Password reset successfully';
        return ApiResponse.success(data: msg);
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to reset password', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final uri = Uri.parse('\${ApiEndpoints.baseUrl}\${ApiEndpoints.profile}');
      final response = await _httpClient.client.get(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data: UserModel.fromJson(data));
      }
      return ApiResponse.error(message: response.reasonPhrase ?? 'Failed to get current user', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    // Remote logout call if any
  }
}
''';
    }
  }

  static String getAuthLocalDatasourceTemplate(CliConfig config) {
    return '''
import '../../../core/errors/exceptions.dart';
import '../../../core/storage/local_db_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/utils/logger.dart';
import '../model/auth_tokens.dart';
import '../model/user_model.dart';

abstract class AuthLocalDatasource {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<void> clearTokens();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<UserModel?> checkSignInStatus();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SecureStorageService _secureStorage;
  final LocalDbService _localDbService;
  static const String _authBox = 'auth_cache';
  static const String _userKey = 'cached_user';

  const AuthLocalDatasourceImpl(
    this._secureStorage,
    this._localDbService,
  );

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    try {
      await _secureStorage.write(StorageKeys.token, tokens.accessToken);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save tokens', e, stackTrace);
      throw const CacheException(message: 'Failed to save tokens');
    }
  }

  @override
  Future<AuthTokens?> getTokens() async {
    try {
      final token = await _secureStorage.read(StorageKeys.token);
      if (token == null || token.isEmpty) return null;
      return AuthTokens(accessToken: token, refreshToken: '');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get tokens', e, stackTrace);
      throw const CacheException(message: 'Failed to read tokens');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(StorageKeys.token);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear tokens', e, stackTrace);
      throw const CacheException(message: 'Failed to clear tokens');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _secureStorage.write(StorageKeys.userId, user.id);
      await _localDbService.put(_authBox, _userKey, user.toJson());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save user', e, stackTrace);
      throw const CacheException(message: 'Failed to save user');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final data = await _localDbService.getValue<Map>(_authBox, _userKey);
      if (data != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get user', e, stackTrace);
      throw const CacheException(message: 'Failed to read user');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _secureStorage.delete(StorageKeys.userId);
      await _localDbService.delete(_authBox, _userKey);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear user', e, stackTrace);
      throw const CacheException(message: 'Failed to clear user');
    }
  }

  @override
  Future<UserModel?> checkSignInStatus() async {
    try {
      final token = await _secureStorage.read(StorageKeys.token);
      final user = await getUser();
      if (token != null && token.isNotEmpty && user != null) {
        return user;
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check sign in status', e, stackTrace);
      throw const CacheException(message: 'Failed to check sign in status');
    }
  }
}
''';
  }

  static String getAuthRepositoryTemplate(CliConfig config) {
    return '''
import '../../../core/network/api_response.dart';
import '../model/auth_tokens.dart';
import '../model/user_model.dart';
import '../datasource/auth_remote_datasource.dart';
import '../datasource/auth_local_datasource.dart';

abstract class AuthRepository {
  Future<ApiResponse<AuthTokens>> signInWithEmail({required String email, required String password});
  Future<ApiResponse<AuthTokens>> signUpWithEmail({required String name, required String email, required String password});
  Future<ApiResponse<String>> requestPasswordReset(String email);
  Future<ApiResponse<String>> verifyOtp({required String email, required String otp});
  Future<ApiResponse<String>> resetPassword({required String email, required String otp, required String newPassword});
  Future<ApiResponse<UserModel>> getCurrentUser();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;

  AuthRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<ApiResponse<AuthTokens>> signInWithEmail({required String email, required String password}) async {
    final response = await _remoteDatasource.signInWithEmail(email: email, password: password);
    if (response.success && response.data != null) {
      await _localDatasource.saveTokens(response.data!);
    }
    return response;
  }

  @override
  Future<ApiResponse<AuthTokens>> signUpWithEmail({required String name, required String email, required String password}) async {
    final response = await _remoteDatasource.signUpWithEmail(name: name, email: email, password: password);
    if (response.success && response.data != null) {
      await _localDatasource.saveTokens(response.data!);
    }
    return response;
  }

  @override
  Future<ApiResponse<String>> requestPasswordReset(String email) async {
    return await _remoteDatasource.requestPasswordReset(email);
  }

  @override
  Future<ApiResponse<String>> verifyOtp({required String email, required String otp}) async {
    return await _remoteDatasource.verifyOtp(email: email, otp: otp);
  }

  @override
  Future<ApiResponse<String>> resetPassword({required String email, required String otp, required String newPassword}) async {
    return await _remoteDatasource.resetPassword(email: email, otp: otp, newPassword: newPassword);
  }

  @override
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    final cached = await _localDatasource.getUser();
    if (cached != null) {
      return ApiResponse.success(data: cached);
    }
    final response = await _remoteDatasource.getCurrentUser();
    if (response.success && response.data != null) {
      await _localDatasource.saveUser(response.data!);
    }
    return response;
  }

  @override
  Future<void> logout() async {
    await _remoteDatasource.logout();
    await _localDatasource.clearTokens();
    await _localDatasource.clearUser();
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
import '../model/user_model.dart';

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
import '../repository/auth_repository.dart';
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
    final isGoRouter = config.navigation == 'go_router';
    final goRouterImport =
        isGoRouter ? "import 'package:go_router/go_router.dart';" : '';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
$goRouterImport
import '../../../../routes/route_names.dart';
import '../../${isBloc ? 'bloc' : 'cubit'}/auth_${isBloc ? 'bloc' : 'cubit'}.dart';
${isBloc ? "import '../../${isBloc ? 'bloc' : 'cubit'}/auth_event.dart';\nimport '../../${isBloc ? 'bloc' : 'cubit'}/auth_state.dart';" : "import '../../${isBloc ? 'bloc' : 'cubit'}/auth_cubit_state.dart';"}
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';

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
            ${isGoRouter ? 'context.go(RouteNames.home);' : 'Navigator.of(context).pushReplacementNamed(RouteNames.home);'}
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }''' : '''if (state.isAuthenticated) {
            ${isGoRouter ? 'context.go(RouteNames.home);' : 'Navigator.of(context).pushReplacementNamed(RouteNames.home);'}
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
                        onPressed: isLoading ? null : () => ${isGoRouter ? 'context.go(RouteNames.forgotPassword)' : 'Navigator.of(context).pushNamed(RouteNames.forgotPassword)'},
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
                          onPressed: isLoading ? null : () => ${isGoRouter ? 'context.go(RouteNames.signUp)' : 'Navigator.of(context).pushNamed(RouteNames.signUp)'},
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
    final isGoRouter = config.navigation == 'go_router';
    final goRouterImport =
        isGoRouter ? "import 'package:go_router/go_router.dart';" : '';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
$goRouterImport
import '../../../../routes/route_names.dart';
import '../../${isBloc ? 'bloc' : 'cubit'}/auth_${isBloc ? 'bloc' : 'cubit'}.dart';
${isBloc ? "import '../../${isBloc ? 'bloc' : 'cubit'}/auth_event.dart';\nimport '../../${isBloc ? 'bloc' : 'cubit'}/auth_state.dart';" : "import '../../${isBloc ? 'bloc' : 'cubit'}/auth_cubit_state.dart';"}
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';

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
            ${isGoRouter ? 'context.go(RouteNames.home);' : 'Navigator.of(context).pushReplacementNamed(RouteNames.home);'}
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }''' : '''
          if (state.isAuthenticated) {
            ${isGoRouter ? 'context.go(RouteNames.home);' : 'Navigator.of(context).pushReplacementNamed(RouteNames.home);'}
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
    final isGoRouter = config.navigation == 'go_router';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
${isGoRouter ? 'import \'package:go_router/go_router.dart\';' : ''}
import '../../../../routes/route_names.dart';
import '../../${isBloc ? 'bloc' : 'cubit'}/auth_${isBloc ? 'bloc' : 'cubit'}.dart';
${isBloc ? "import '../../bloc/auth_event.dart';\nimport '../../bloc/auth_state.dart';" : "import '../../cubit/auth_cubit_state.dart';"}
import '../widgets/auth_text_field.dart';

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
            ${isGoRouter ? 'context.go(RouteNames.otpVerify, extra: _emailController.text.trim());' : 'Navigator.of(context).pushNamed(RouteNames.otpVerify, arguments: _emailController.text.trim());'}
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }''' : '''
          if (state.message != null && !state.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
            ${isGoRouter ? 'context.go(RouteNames.otpVerify, extra: _emailController.text.trim());' : 'Navigator.of(context).pushNamed(RouteNames.otpVerify, arguments: _emailController.text.trim());'}
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
    final isGoRouter = config.navigation == 'go_router';
    final goRouterImport =
        isGoRouter ? "import 'package:go_router/go_router.dart';" : '';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
$goRouterImport
import '../../../../routes/route_names.dart';
import '../../${isBloc ? 'bloc' : 'cubit'}/auth_${isBloc ? 'bloc' : 'cubit'}.dart';
${isBloc ? "import '../../${isBloc ? 'bloc' : 'cubit'}/auth_event.dart';\nimport '../../${isBloc ? 'bloc' : 'cubit'}/auth_state.dart';" : "import '../../${isBloc ? 'bloc' : 'cubit'}/auth_cubit_state.dart';"}
import '../widgets/otp_input_field.dart';

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
            ${isGoRouter ? 'context.go(RouteNames.resetPassword, extra: {\'email\': widget.email, \'otp\': _otpController.text.trim()});' : 'Navigator.of(context).pushReplacementNamed(RouteNames.resetPassword, arguments: {\'email\': widget.email, \'otp\': _otpController.text.trim()});'}
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }''' : '''
          if (state.message != null && !state.isLoading) {
            ${isGoRouter ? 'context.go(RouteNames.resetPassword, extra: {\'email\': widget.email, \'otp\': _otpController.text.trim()});' : 'Navigator.of(context).pushReplacementNamed(RouteNames.resetPassword, arguments: {\'email\': widget.email, \'otp\': _otpController.text.trim()});'}
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
    final isGoRouter = config.navigation == 'go_router';
    final goRouterImport =
        isGoRouter ? "import 'package:go_router/go_router.dart';" : '';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
$goRouterImport
import '../../../../routes/route_names.dart';
import '../../${isBloc ? 'bloc' : 'cubit'}/auth_${isBloc ? 'bloc' : 'cubit'}.dart';
${isBloc ? "import '../../${isBloc ? 'bloc' : 'cubit'}/auth_event.dart';\nimport '../../${isBloc ? 'bloc' : 'cubit'}/auth_state.dart';" : "import '../../${isBloc ? 'bloc' : 'cubit'}/auth_cubit_state.dart';"}
import '../widgets/password_field.dart';

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
            ${isGoRouter ? 'context.go(RouteNames.signIn);' : 'Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.signIn, (route) => false);'}
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }''' : '''
          if (state.message != null && !state.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
            ${isGoRouter ? 'context.go(RouteNames.signIn);' : 'Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.signIn, (route) => false);'}
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

  // --- NEW STRUCTURE TEMPLATES ---

  static String getAppAssetsTemplate() {
    return '''
class AppAssets {
  static const String logo = 'assets/images/logo.png';
}
''';
  }

  static String getAppTextsTemplate() {
    return '''
class AppTexts {
  static const String appName = 'Flutter App';

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

  static String getFailuresTemplate() {
    return '''
/// Base failure for application-level errors.
///
/// Failures are returned from repositories and consumed by
/// the domain/presentation layers.
abstract class AppFailure {
  final String message;
  final String? code;

  const AppFailure({
    required this.message,
    this.code,
  });

  @override
  String toString() {
    if (code != null) {
      return '\$runtimeType(\$code): \$message';
    }

    return '\$runtimeType: \$message';
  }
}

/// Represents a network connectivity failure.
class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message = 'No internet connection.',
    super.code,
  });
}

/// Represents a request timeout failure.
class TimeoutFailure extends AppFailure {
  const TimeoutFailure({
    super.message = 'The request timed out.',
    super.code,
  });
}

/// Represents an authentication failure.
class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({
    super.message = 'Authentication is required.',
    super.code,
  });
}

/// Represents a permission failure.
class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure({
    super.message = 'You do not have permission to perform this action.',
    super.code,
  });
}

/// Represents a resource-not-found failure.
class NotFoundFailure extends AppFailure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code,
  });
}

/// Represents an invalid-request failure.
class BadRequestFailure extends AppFailure {
  const BadRequestFailure({
    super.message = 'The request was invalid.',
    super.code,
  });
}

/// Represents a server-side failure.
class ServerFailure extends AppFailure {
  const ServerFailure({
    super.message = 'Something went wrong on the server.',
    super.code,
  });
}

/// Represents a response parsing failure.
class ParsingFailure extends AppFailure {
  const ParsingFailure({
    super.message = 'Failed to process the server response.',
    super.code,
  });
}

/// Represents a local cache/storage failure.
class CacheFailure extends AppFailure {
  const CacheFailure({
    super.message = 'Failed to access local data.',
    super.code,
  });
}

/// Represents a local database failure.
class DatabaseFailure extends AppFailure {
  const DatabaseFailure({
    super.message = 'A database error occurred.',
    super.code,
  });
}

/// Represents an input validation failure.
class ValidationFailure extends AppFailure {
  const ValidationFailure({
    super.message = 'The provided data is invalid.',
    super.code,
  });
}

/// Represents a missing-resource failure.
class MissingResourceFailure extends AppFailure {
  const MissingResourceFailure({
    super.message = 'The required resource was not found.',
    super.code,
  });
}

/// Represents a file operation failure.
class FileFailure extends AppFailure {
  const FileFailure({
    super.message = 'A file operation failed.',
    super.code,
  });
}

/// Represents an operation cancellation.
class CancelledFailure extends AppFailure {
  const CancelledFailure({
    super.message = 'The operation was cancelled.',
    super.code,
  });
}

/// Represents an unexpected response failure.
class UnexpectedResponseFailure extends AppFailure {
  const UnexpectedResponseFailure({
    super.message = 'Received an unexpected response.',
    super.code,
  });
}

/// Represents an unknown failure.
class UnknownFailure extends AppFailure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
  });
}

''';
  }

  static String getExceptionsTemplate() {
    return '''

/// Base exception for application-level errors.
///
/// Exceptions are generally thrown in the data layer and converted
/// into Failures by repositories.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() {
    if (code != null) {
      return '\$runtimeType(\$code): \$message';
    }

    return '\$runtimeType: \$message';
  }
}

/// Thrown when there is no internet/network connection.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection.',
    super.code,
  });
}

/// Thrown when a request takes longer than the allowed time.
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'The request timed out.',
    super.code,
  });
}

/// Thrown when authentication is required or the access token is invalid.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Authentication is required.',
    super.code,
  });
}

/// Thrown when the authenticated user does not have permission.
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.code,
  });
}

/// Thrown when the requested resource does not exist.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.code,
  });
}

/// Thrown when the request is invalid.
class BadRequestException extends AppException {
  const BadRequestException({
    super.message = 'The request was invalid.',
    super.code,
  });
}

/// Thrown when the server returns an unexpected error.
class ServerException extends AppException {
  const ServerException({
    super.message = 'Something went wrong on the server.',
    super.code,
  });
}

/// Thrown when the API response cannot be parsed or decoded.
class ParsingException extends AppException {
  const ParsingException({
    super.message = 'Failed to process the server response.',
    super.code,
  });
}

/// Thrown when local storage or cache operations fail.
class CacheException extends AppException {
  const CacheException({
    super.message = 'Failed to access local data.',
    super.code,
  });
}

/// Thrown when a local database operation fails.
class DatabaseException extends AppException {
  const DatabaseException({
    super.message = 'A database error occurred.',
    super.code,
  });
}

/// Thrown when input or request data is invalid.
class ValidationException extends AppException {
  const ValidationException({
    super.message = 'The provided data is invalid.',
    super.code,
  });
}

/// Thrown when a required resource is missing.
class MissingResourceException extends AppException {
  const MissingResourceException({
    super.message = 'The required resource was not found.',
    super.code,
  });
}

/// Thrown when a file operation fails.
class FileException extends AppException {
  const FileException({
    super.message = 'A file operation failed.',
    super.code,
  });
}

/// Thrown when an operation is cancelled.
class CancelledException extends AppException {
  const CancelledException({
    super.message = 'The operation was cancelled.',
    super.code,
  });
}

/// Thrown when the application receives an unexpected response.
class UnexpectedResponseException extends AppException {
  const UnexpectedResponseException({
    super.message = 'Received an unexpected response.',
    super.code,
  });
}

/// Thrown when an unknown error occurs.
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred.',
    super.code,
  });
}
''';
  }

  static String getConnectionCheckerTemplate() {
    return '''
import 'dart:io';

abstract class ConnectionChecker {
  Future<bool> get isConnected;
}

class ConnectionCheckerImpl implements ConnectionChecker {
  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
''';
  }

  static String getDioClientTemplate() {
    return '''
import 'package:dio/dio.dart';
import '../../constants/api_endpoints.dart';
import 'dio_interceptor/logging_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient({Dio? dio}) {
    if (dio != null) {
      return DioClient._custom(dio);
    }
    return _instance;
  }

  DioClient._internal() : _dio = Dio() {
    _init();
  }

  DioClient._custom(Dio dio) : _dio = dio {
    _init();
  }

  late final Dio _dio;

  void _init() {
    _dio
      ..options.baseUrl = ApiEndpoints.baseUrl
      ..options.connectTimeout = const Duration(seconds: 15)
      ..options.receiveTimeout = const Duration(seconds: 15)
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
      ..interceptors.add(LoggingInterceptor());
  }

  Dio get dio => _dio;
}
''';
  }

  static String getHttpClientTemplate() {
    return '''
import 'package:http/http.dart' as http;

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient({http.Client? client}) {
    if (client != null) {
      return HttpClient._custom(client);
    }
    return _instance;
  }

  HttpClient._internal() : _client = http.Client();
  HttpClient._custom(http.Client client) : _client = client;

  final http.Client _client;

  http.Client get client => _client;
}
''';
  }

  static String getLoggingInterceptorTemplate() {
    return '''
import 'package:dio/dio.dart';
import '../../../utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('REQUEST[\${options.method}] => PATH: \${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info('RESPONSE[\${response.statusCode}] => PATH: \${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('ERROR[\${err.response?.statusCode}] => PATH: \${err.requestOptions.path}');
    super.onError(err, handler);
  }
}
''';
  }

  static String getAppExceptionHandlerTemplate() {
    return '''
import 'dart:io';
import 'package:dio/dio.dart';
import '../exceptions.dart';

class AppExceptionHandler {
  /// Converts any error (DioException, SocketException, etc.) into an [AppException].
  static AppException handle(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is SocketException) {
      return const NetworkException(
        message: 'No internet connection. Please try again.',
      );
    }

    return UnknownException(message: error.toString());
  }

  static AppException _handleDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Connection timed out. Check your internet connection.',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'Invalid security certificate.');

      case DioExceptionType.cancel:
        return const UnknownException(message: 'Request was cancelled.');

      case DioExceptionType.badResponse:
        return _handleBadResponse(dioException.response);

      case DioExceptionType.unknown:
      default:
        if (dioException.error is SocketException) {
          return const NetworkException(
            message: 'No internet connection. Please try again.',
          );
        }
        return UnknownException(
          message: dioException.message ?? 'An unexpected error occurred.',
        );
    }
  }

  static AppException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final errorMessage = _extractErrorMessage(response?.data);

    switch (statusCode) {
      case 400:
        return ServerException(
          message: errorMessage ?? 'Bad request.',
          code: statusCode?.toString(),
        );

      case 401:
      case 403:
        return UnauthorizedException(
          message: errorMessage ?? 'Unauthorized request or session expired.',
          code: (statusCode ?? 401).toString(),
        );

      case 404:
        return NotFoundException(
          message: errorMessage ?? 'Requested resource was not found.',
          code: (statusCode ?? 404).toString(),
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: errorMessage ?? 'Server error occurred. Please try again later.',
          code: statusCode?.toString(),
        );

      default:
        return ServerException(
          message: errorMessage ?? 'Received invalid status code: \$statusCode',
          code: statusCode?.toString(),
        );
    }
  }

  /// Extracts error message from response JSON body if available.
  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // If there's a nested validation error object, format it
      if (data.containsKey('errors') && data['errors'] is Map) {
        final Map errors = data['errors'];
        return errors.values.expand((e) => e as List).join('\\n'); 
      }

      return data['message'] ??
          data['error'] ??
          data['detail'] ??
          data['description']?.toString();
    }
    
    if (data is String && data.isNotEmpty) return data;
    
    return null;
  }
}
''';
  }

  static String getAppStylesTemplate() {
    return '''
import 'package:flutter/material.dart';

class AppStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );
}
''';
  }

  static String getL10nExtensionTemplate() {
    return '''
import 'package:flutter/material.dart';

extension L10nExtension on BuildContext {
  String translate(String key) => key;
}
''';
  }

  static String getDateFormatterTemplate() {
    return '''
extension DateFormatter on DateTime {
  String toReadableString() {
    return '\$day/\$month/\$year';
  }
}
''';
  }

  static String getThemeExtensionTemplate() {
    return '''
import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}
''';
  }

  static String getAppThemeExtensionTemplate() {
    return '''
import 'package:flutter/material.dart';

extension AppThemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
''';
  }

  static String getSecureStorageServiceTemplate() {
    return '''
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> write(StorageKeys key, String value) async {
    await _storage.write(key: key.name, value: value);
  }

  Future<String?> read(StorageKeys key) async {
    return await _storage.read(key: key.name);
  }

  Future<void> delete(StorageKeys key) async {
    await _storage.delete(key: key.name);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
''';
  }

  static String getStorageKeysTemplate() {
    return '''
enum StorageKeys {
  token,
  userId,
  isLoggedIn,
}
''';
  }

  static String getAppHelperTemplate() {
    return '''
import 'package:flutter/material.dart';

class AppHelper {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
''';
  }

  static String getAppLoggerTemplate() {
    return '''
import 'dart:developer' as developer;

class AppLogger {
  static void info(String message) {
    developer.log('💡 INFO: \$message', name: 'APP');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      '🚨 ERROR: \$message',
      name: 'APP',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message) {
    developer.log('🔧 DEBUG: \$message', name: 'APP');
  }
}
''';
  }

  static String getCustomButtonTemplate() {
    return '''
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
      ),
      child: Text(text),
    );
  }
}
''';
  }

  static String getCustomAppBarTemplate() {
    return '''
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
''';
  }

  static String getCustomBackButtonTemplate() {
    return '''
import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () => Navigator.maybePop(context),
    );
  }
}
''';
  }

  static String getCustomDialogTemplate() {
    return '''
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final VoidCallback onConfirm;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'OK',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
''';
  }

  static String getCustomDrawerTemplate() {
    return '''
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
''';
  }

  static String getSocialButtonTemplate() {
    return '''
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
''';
  }

  static String getLocalDbServiceTemplate() {
    return '''
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Generic local storage service built on top of Hive CE.
///
/// Responsibilities:
/// - Initialize Hive
/// - Open and manage boxes
/// - Store, read, update and delete data
/// - Provide generic access to Hive boxes
///
/// Feature repositories and datasources should use this service instead of
/// accessing Hive directly.
class LocalDbService {
  LocalDbService();

  /// Initialize Hive.
  ///
  /// Call this once before using any Hive functionality.
  Future<void> init() async {
    await Hive.initFlutter();
  }

  /// Register a Hive adapter.
  ///
  /// Example:
  /// ```dart
  /// registerAdapter(UserModelAdapter());
  /// ```
  void registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  /// Open a Hive box.
  ///
  /// If the box is already open, the existing instance is returned.
  Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }

    return Hive.openBox<T>(boxName);
  }

  /// Get an already opened box.
  ///
  /// Throws [StateError] if the box has not been opened.
  Box<T> getBox<T>(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError(
        'Hive box "\$boxName" is not open. '
        'Call openBox() before accessing it.',
      );
    }

    return Hive.box<T>(boxName);
  }

  /// Store or update a value.
  Future<void> put<T>(
    String boxName,
    String key,
    T value,
  ) async {
    final box = await openBox<T>(boxName);
    await box.put(key, value);
  }

  /// Store multiple values at once.
  Future<void> putAll<T>(
    String boxName,
    Map<String, T> values,
  ) async {
    final box = await openBox<T>(boxName);
    await box.putAll(values);
  }

  /// Get a value by key.
  T? get<T>(
    String boxName,
    String key, {
    T? defaultValue,
  }) {
    final box = getBox<T>(boxName);

    return box.get(
      key,
      defaultValue: defaultValue,
    );
  }

  /// Get a value asynchronously.
  ///
  /// Useful when the box may not already be open.
  Future<T?> getValue<T>(
    String boxName,
    String key, {
    T? defaultValue,
  }) async {
    final box = await openBox<T>(boxName);

    return box.get(
      key,
      defaultValue: defaultValue,
    );
  }

  /// Check whether a key exists.
  bool containsKey<T>(
    String boxName,
    String key,
  ) {
    final box = getBox<T>(boxName);
    return box.containsKey(key);
  }

  /// Delete a value by key.
  Future<void> delete<T>(
    String boxName,
    String key,
  ) async {
    final box = await openBox<T>(boxName);
    await box.delete(key);
  }

  /// Delete multiple values by keys.
  Future<void> deleteAll<T>(
    String boxName,
    Iterable<String> keys,
  ) async {
    final box = await openBox<T>(boxName);
    await box.deleteAll(keys);
  }

  /// Get all values from a box.
  List<T> getAll<T>(String boxName) {
    final box = getBox<T>(boxName);
    return box.values.toList();
  }

  /// Get all keys from a box.
  List<dynamic> getAllKeys<T>(String boxName) {
    final box = getBox<T>(boxName);
    return box.keys.toList();
  }

  /// Get the number of stored values.
  int length<T>(String boxName) {
    final box = getBox<T>(boxName);
    return box.length;
  }

  /// Clear all values from a box.
  Future<void> clear<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    await box.clear();
  }

  /// Check whether a box is open.
  bool isBoxOpen(String boxName) {
    return Hive.isBoxOpen(boxName);
  }

  /// Close a specific box.
  Future<void> closeBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<T>(boxName).close();
    }
  }

  /// Close all open Hive boxes.
  Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  /// Delete a box and its data from disk.
  Future<void> deleteBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }

    await Hive.deleteBoxFromDisk(boxName);
  }
}
''';
  }

  static String getInjectionContainerTemplate(CliConfig config) {
    final isDio = config.networkPackage == 'dio';
    if (isDio) {
      return '''
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/client/dio_client.dart';
import '../network/connection_checker.dart';
import '../storage/secure_storage_service.dart';
import '../storage/local_db_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Local DB / Hive
  final localDbService = LocalDbService();
  await localDbService.init();
  sl.registerLazySingleton<LocalDbService>(() => localDbService);

  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core
  sl.registerLazySingleton<ConnectionChecker>(() => ConnectionCheckerImpl());
  sl.registerLazySingleton(() => DioClient(dio: sl()));
  sl.registerLazySingleton(() => SecureStorageService(storage: sl()));
}
''';
    } else {
      return '''
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/client/http_client.dart';
import '../network/connection_checker.dart';
import '../storage/secure_storage_service.dart';
import '../storage/local_db_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Local DB / Hive
  final localDbService = LocalDbService();
  await localDbService.init();
  sl.registerLazySingleton<LocalDbService>(() => localDbService);

  // External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core
  sl.registerLazySingleton<ConnectionChecker>(() => ConnectionCheckerImpl());
  sl.registerLazySingleton(() => HttpClient(client: sl()));
  sl.registerLazySingleton(() => SecureStorageService(storage: sl()));
}
''';
    }
  }

  static String getAppConfigTemplate() {
    return '''
class AppConfig {
  static const String appName = 'Flutter App';
  static const String baseUrl = 'https://api.example.com';
}
''';
  }
}
