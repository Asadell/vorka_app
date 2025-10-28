import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/config/routes/app_router.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';
import 'package:vorka_app2/providers/auth_provider.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = auth.currentUser!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              children: [
                // User Info
                CircleAvatar(
                  radius: AppSizes.avatarL / 2,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                const SizedBox(height: AppSizes.paddingM),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXs),
                Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSizes.paddingXl),

                // Organizations Section
                if (user.organizations.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Organisasi Saya',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  ...user.organizations.map((org) {
                    final isActive =
                        org.organizationId == user.activeOrganizationId;
                    return Card(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        leading: Icon(
                          Icons.business,
                          color: isActive ? AppColors.primary : null,
                        ),
                        title: Text(org.organizationId),
                        subtitle: Text(org.role.displayName),
                        trailing: isActive
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              )
                            : IconButton(
                                icon: const Icon(Icons.swap_horiz),
                                onPressed: () async {
                                  // Switch organization
                                  // This would need a service method to update activeOrganizationId
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Fitur pindah organisasi akan segera tersedia',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.paddingM),
                ],

                // Join Another Organization Button
                OutlinedButton.icon(
                  onPressed: () {
                    context.router.push(const OnboardingRoute());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Gabung Organisasi Lain'),
                ),
                const SizedBox(height: AppSizes.paddingXl),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await auth.signOut();
                      if (context.mounted) {
                        context.router.replaceAll([const LoginRoute()]);
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
