import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/config/routes/app_router.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';
import 'package:vorka_app2/core/constants/firebase_constants.dart';
import 'package:vorka_app2/providers/auth_provider.dart';
import 'package:vorka_app2/providers/notification_provider.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<String> _getOrganizationName(String orgId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseConstants.organizationsCollection)
          .doc(orgId)
          .get();

      if (doc.exists) {
        return doc.data()?['name'] ?? orgId;
      }
      return orgId;
    } catch (e) {
      return orgId;
    }
  }

  Future<void> _switchOrganization(
    BuildContext context,
    String newOrgId,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Update activeOrganizationId di Firestore
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({'activeOrganizationId': newOrgId});

      // Reload user data dari Firestore
      await authProvider.loadCurrentUser();

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil pindah organisasi'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to home (replace all routes)
      context.router.replaceAll([const MainRoute()]);
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal pindah organisasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // IMPORTANT: Stop notification listener first
      final notifProvider = context.read<NotificationProvider>();
      notifProvider.stopWatching();

      // Then sign out
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Small delay
      await Future.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) return;

      // Navigate to login
      context.router.replaceAll([const LoginRoute()]);
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

                    return FutureBuilder<String>(
                      future: _getOrganizationName(org.organizationId),
                      builder: (context, snapshot) {
                        final orgName = snapshot.data ?? org.organizationId;
                        final isLoading = !snapshot.hasData;

                        return Card(
                          color: isActive
                              ? AppColors.primary.withOpacity(0.1)
                              : null,
                          margin: const EdgeInsets.only(
                            bottom: AppSizes.paddingS,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingM,
                              vertical: AppSizes.paddingS,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(AppSizes.paddingS),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusS,
                                ),
                              ),
                              child: Icon(
                                Icons.business,
                                color: isActive
                                    ? AppColors.primary
                                    : Colors.grey,
                                size: AppSizes.iconL,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    orgName,
                                    style: TextStyle(
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isLoading)
                                  const SizedBox(
                                    height: 12,
                                    width: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                // Organization ID
                                Row(
                                  children: [
                                    Icon(
                                      Icons.tag,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      org.organizationId,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // User Role
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.primary.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    org.role.displayName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? AppColors.primary
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: isActive
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Aktif',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.swap_horiz),
                                    tooltip: 'Pindah ke organisasi ini',
                                    color: Colors.grey.shade600,
                                    onPressed: () => _switchOrganization(
                                      context,
                                      org.organizationId,
                                    ),
                                  ),
                          ),
                        );
                      },
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
                    onPressed: () => _logout(context),
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
