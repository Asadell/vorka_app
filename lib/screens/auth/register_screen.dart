import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('R e g i s t e r S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: R e g i s t e r S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
