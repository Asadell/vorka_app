import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class Step1InfoScreen extends StatelessWidget {
  const Step1InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('S t e p1 I n f o S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: S t e p1 I n f o S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
