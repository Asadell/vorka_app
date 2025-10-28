import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class ProkerListScreen extends StatelessWidget {
  const ProkerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('P r o k e r L i s t S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: P r o k e r L i s t S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
