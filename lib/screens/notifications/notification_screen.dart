import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('N o t i f i c a t i o n S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: N o t i f i c a t i o n S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
