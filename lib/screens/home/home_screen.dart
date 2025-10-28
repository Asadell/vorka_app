import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:vorka_app2/config/routes/app_router.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        leading: IconButton(
          icon: const Icon(Icons.people),
          onPressed: () {
            // Navigate to Structure Screen
            context.router.push(const StructureRoute());
          },
          tooltip: 'Struktur Organisasi',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to Notification Screen
              context.router.push(const NotificationRoute());
            },
            tooltip: 'Notifikasi',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Org selector & stats
          const Text('Home content here'),
        ],
      ),
    );
  }
}
