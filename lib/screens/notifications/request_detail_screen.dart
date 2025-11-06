import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';
import 'package:vorka_app2/models/join_request_model.dart';
import 'package:vorka_app2/providers/auth_provider.dart';
import 'package:vorka_app2/providers/notification_provider.dart';

@RoutePage()
class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({super.key, required this.request});

  final JoinRequestModel request;

  Future<void> _approve(BuildContext context) async {
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId == null) return;

    final notifProvider = context.read<NotificationProvider>();
    final success = await notifProvider.approveJoinRequest(request.id, userId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan ditolak'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notifProvider.error ?? 'Gagal menolak'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reject(BuildContext context) async {
    // Definisi method _reject
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Permintaan'),
        content: const Text('Apakah Anda yakin ingin menolak permintaan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final notifProvider = context.read<NotificationProvider>();
    final success = await notifProvider.rejectJoinRequest(
      request.id,
      userId,
      null,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan ditolak'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notifProvider.error ?? 'Gagal menolak'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Permintaan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: AppSizes.avatarL / 2,
                    backgroundImage: request.userPhotoUrl != null
                        ? NetworkImage(request.userPhotoUrl!)
                        : null,
                    child: request.userPhotoUrl == null
                        ? Text(
                            request.userName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    request.userName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXs),
                  Text(
                    request.userEmail,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingXl),

            // Request Details
            _DetailCard(
              icon: Icons.work_outline,
              title: 'Role yang Diminta',
              value: request.requestedRole.displayName,
            ),
            const SizedBox(height: AppSizes.paddingM),

            if (request.departmentId != null)
              _DetailCard(
                icon: Icons.group_outlined,
                title: 'Departemen',
                value: request.departmentId!,
              ),
            const SizedBox(height: AppSizes.paddingM),

            _DetailCard(
              icon: Icons.access_time,
              title: 'Waktu Permintaan',
              value: _formatDate(request.createdAt),
            ),
            const SizedBox(height: AppSizes.paddingXl),

            // Warning if role already taken
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: AppSizes.paddingS),
                  Expanded(
                    child: Text(
                      'Jika Anda menyetujui, dan role sudah diisi oleh orang lain, maka role orang tersebut akan diganti.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingXl),

            // Action Buttons
            Consumer<NotificationProvider>(
              builder: (context, notif, _) {
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: notif.isLoading
                            ? null
                            : () => _reject(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: notif.isLoading
                            ? null
                            : () => _approve(context),
                        child: notif.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Setujui'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: AppSizes.paddingXs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
