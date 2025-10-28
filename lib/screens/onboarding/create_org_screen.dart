import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class CreateOrgScreen extends StatelessWidget {
  const CreateOrgScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('C r e a t e O r g S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: C r e a t e O r g S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
