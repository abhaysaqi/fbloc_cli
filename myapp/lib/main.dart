import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/route_names.dart';
import 'app/features/home/cubit/home_cubit.dart';
import 'app/features/home/repository/home_repository.dart';
import 'app/core/service/api_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(create: (_) => ApiService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => HomeCubit(
            context.read<HomeRepository>(),
          )..loadData()),
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
