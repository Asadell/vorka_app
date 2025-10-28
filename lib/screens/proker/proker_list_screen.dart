import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ProkerListScreen extends StatelessWidget {
  const ProkerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Program Kerja')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Proker list
          const Text('Proker list here'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // context.router.push();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
