import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:vorka_app2/config/routes/app_router.dart';

@RoutePage()
class MeetingListScreen extends StatelessWidget {
  const MeetingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rapat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Meeting list
          const Text('Meeting list here'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(const CreateMeetingRoute());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
