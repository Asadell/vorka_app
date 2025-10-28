import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class StructureScreen extends StatelessWidget {
  const StructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('S t r u c t u r e S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: S t r u c t u r e S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
