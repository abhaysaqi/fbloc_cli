import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/features/home/bloc/home_bloc.dart';
import 'app/features/home/repository/home_repository.dart';
import 'app/features/home/repository/home_repository_impl.dart';
import 'app/core/service/api_service.dart';
import 'app/features/home/bloc/home_event.dart';

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
          BlocProvider(create: (context) => HomeBloc(
            context.read<HomeRepository>(),
          )..add(HomeStarted())),
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
