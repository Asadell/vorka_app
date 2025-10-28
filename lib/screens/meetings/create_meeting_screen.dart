import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class CreateMeetingScreen extends StatelessWidget {
  const CreateMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('C r e a t e M e e t i n g S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: C r e a t e M e e t i n g S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
