import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
import '../bloc/home_event.dart';
import 'components/bottom_navbar.dart';
import 'components/app_drawer.dart';
import '../../../core/utils/strings.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${AppStrings.errorPrefix} ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(HomeStarted());
                    },
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          
          if (state is HomeLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text(AppStrings.noItemsFound));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeStarted());
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
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('${AppStrings.idPrefix} ${item.id}'),
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
