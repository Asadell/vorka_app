import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class QrAttendanceScreen extends StatelessWidget {
  const QrAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Q r A t t e n d a n c e S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: Q r A t t e n d a n c e S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
