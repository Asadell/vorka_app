import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:vorka_app2/config/routes/app_router.dart';

@RoutePage()
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Task list with filters
          const Text('Task list here'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(const CreateTaskRoute());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
