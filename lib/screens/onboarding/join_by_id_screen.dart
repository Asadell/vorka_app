import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class JoinByIdScreen extends StatelessWidget {
  const JoinByIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('J o i n B y I d S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: J o i n B y I d S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
