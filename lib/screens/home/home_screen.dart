import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/config/routes/app_router.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';
import 'package:vorka_app2/core/constants/enums.dart';
import 'package:vorka_app2/models/user_model.dart';
import 'package:vorka_app2/providers/auth_provider.dart';
import 'package:vorka_app2/providers/notification_provider.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownIndexWarning = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      // Only watch if user exists and is admin
      if (user != null && _isAdmin(user.organizations)) {
        final orgId = user.activeOrganizationId;
        if (orgId != null && orgId.isNotEmpty) {
          context.read<NotificationProvider>().watchJoinRequests(orgId);
        }
      }
    });
  }

  @override
  void dispose() {
    // Stop watching when screen is disposed
    context.read<NotificationProvider>().stopWatching();
    super.dispose();
  }

  bool _isAdmin(List<UserOrganization> orgs) {
    if (orgs.isEmpty) return false;
    final activeOrg = orgs.firstWhere(
      (o) => o.status == 'ACTIVE',
      orElse: () => orgs.first,
    );
    return [
      UserRole.superAdmin,
      UserRole.ketuaOrganisasi,
      UserRole.wakilOrganisasi,
      UserRole.ketuaDepartemen,
    ].contains(activeOrg.role);
  }

  void _showIndexWarningDialog() {
    if (_hasShownIndexWarning) return;
    _hasShownIndexWarning = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Setup Diperlukan'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firebase Index belum dibuat.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Fitur notifikasi tidak akan berfungsi sampai index dibuat.'),
            SizedBox(height: 12),
            Text('Langkah:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('1. Buka Firebase Console'),
            Text('2. Firestore → Indexes'),
            Text('3. Klik link di console log'),
            Text('4. Create Index (tunggu 2-5 menit)'),
            Text('5. Restart aplikasi'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          // Notifications for admin
          Consumer<NotificationProvider>(
            builder: (context, notif, _) {
              // Show warning dialog if index error (only once)
              if (notif.error == 'INDEX_NOT_READY' && !_hasShownIndexWarning) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showIndexWarningDialog();
                });
              }

              final count = notif.pendingCount;
              final hasIndexError = notif.error == 'INDEX_NOT_READY';

              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      hasIndexError
                          ? Icons.notifications_off_outlined
                          : Icons.notifications_outlined,
                    ),
                    onPressed: () {
                      if (hasIndexError) {
                        _showIndexWarningDialog();
                      } else {
                        context.router.push(const NotificationRoute());
                      }
                    },
                    tooltip: hasIndexError
                        ? 'Notifikasi tidak aktif (Index diperlukan)'
                        : 'Lihat notifikasi',
                  ),
                  if (count > 0 && !hasIndexError)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  if (hasIndexError)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: const Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = auth.currentUser!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: AppSizes.avatarM / 2,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang,',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                user.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),

                // Index Warning Banner (if error)
                Consumer<NotificationProvider>(
                  builder: (context, notif, _) {
                    if (notif.error != 'INDEX_NOT_READY') {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingL),
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: AppSizes.paddingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Setup Firebase Index',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Notifikasi belum aktif. Tap untuk info.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            color: Colors.orange.shade700,
                            onPressed: _showIndexWarningDialog,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Quick Stats
                Text(
                  'Ringkasan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.task,
                        label: 'Tasks',
                        count: '0',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.event,
                        label: 'Meetings',
                        count: '0',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingM),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.work,
                        label: 'Proker',
                        count: '0',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: Consumer<NotificationProvider>(
                        builder: (context, notif, _) {
                          final hasError = notif.error == 'INDEX_NOT_READY';
                          return _StatCard(
                            icon: hasError
                                ? Icons.pending_actions_outlined
                                : Icons.pending_actions,
                            label: hasError ? 'Pending*' : 'Pending',
                            count: hasError
                                ? '-'
                                : notif.pendingCount.toString(),
                            color: Colors.red,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingL),

                // Coming Soon Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction,
                        size: AppSizes.iconXl,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Text(
                        'Fitur Lengkap Segera Hadir',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      Text(
                        'Task management, meeting scheduler, dan program kerja akan segera tersedia',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            Icon(icon, size: AppSizes.iconL, color: color),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              count,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
