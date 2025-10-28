import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('T a s k D e t a i l S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: T a s k D e t a i l S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
