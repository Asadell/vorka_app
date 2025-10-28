import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class MeetingDetailScreen extends StatelessWidget {
  const MeetingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('M e e t i n g D e t a i l S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: M e e t i n g D e t a i l S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
