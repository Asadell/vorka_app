import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('L o g i n S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: L o g i n S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
