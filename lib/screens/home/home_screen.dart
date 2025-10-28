import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('H o m e S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: H o m e S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
