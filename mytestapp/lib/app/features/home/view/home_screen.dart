import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
import '../bloc/home_event.dart';
import 'components/bottom_navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(HomeStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HomeScreen'),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is HomeError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            
            if (state is HomeLoaded) {
              return const Center(
                child: Text('HomeScreen Content'),
              );
            }
            
            return const Center(child: Text('Initial State'));
          },
        ),
        bottomNavigationBar: const BottomNavbar(),
      ),
    );
  }
}
