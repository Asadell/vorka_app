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
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    // PENTING: Check user dulu sebelum watch notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      // Only watch if user exists and is admin
      if (user != null && _isAdmin(user.organizations)) {
        final orgId = user.activeOrganizationId;
        if (orgId != null) {
          context.read<NotificationProvider>().watchJoinRequests(orgId);
        }
      }
    });
  }

  @override
  void dispose() {
    // PENTING: Stop listener saat dispose
    // NotificationProvider harus punya method untuk cancel listener
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          // Notifications for admin
          Consumer<NotificationProvider>(
            builder: (context, notif, _) {
              final count = notif.pendingCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      context.router.push(const NotificationRoute());
                    },
                  ),
                  if (count > 0)
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
                          return _StatCard(
                            icon: Icons.pending_actions,
                            label: 'Pending',
                            count: notif.pendingCount.toString(),
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
