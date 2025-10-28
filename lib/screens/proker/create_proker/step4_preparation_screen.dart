import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class Step4PreparationScreen extends StatelessWidget {
  const Step4PreparationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('S t e p4 P r e p a r a t i o n S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: S t e p4 P r e p a r a t i o n S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
