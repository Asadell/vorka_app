import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class MeetingListScreen extends StatelessWidget {
  const MeetingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('M e e t i n g L i s t S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: M e e t i n g L i s t S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
