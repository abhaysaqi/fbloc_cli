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
