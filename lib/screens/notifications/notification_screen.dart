import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/config/routes/app_router.dart';
import 'package:vorka_app2/config/theme/app_colors.dart';
import 'package:vorka_app2/core/constants/app_sizes.dart';
import 'package:vorka_app2/core/constants/enums.dart';
import 'package:vorka_app2/providers/auth_provider.dart';
import 'package:vorka_app2/providers/notification_provider.dart';

@RoutePage()
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    final orgId = context
        .read<AuthProvider>()
        .currentUser
        ?.activeOrganizationId;
    if (orgId != null) {
      context.read<NotificationProvider>().watchJoinRequests(orgId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permintaan Bergabung')),
      body: Consumer<NotificationProvider>(
        builder: (context, notif, _) {
          if (notif.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notif.joinRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: AppSizes.iconXl * 2,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    'Tidak ada permintaan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            itemCount: notif.joinRequests.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSizes.paddingS),
            itemBuilder: (context, index) {
              final request = notif.joinRequests[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: request.userPhotoUrl != null
                        ? NetworkImage(request.userPhotoUrl!)
                        : null,
                    child: request.userPhotoUrl == null
                        ? Text(request.userName[0].toUpperCase())
                        : null,
                  ),
                  title: Text(request.userName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.userEmail),
                      const SizedBox(height: AppSizes.paddingXs),
                      Text(
                        'Role: ${request.requestedRole.displayName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.router.push(RequestDetailRoute(request: request));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
