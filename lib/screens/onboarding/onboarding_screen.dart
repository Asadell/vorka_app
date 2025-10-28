import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('O n b o a r d i n g S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: O n b o a r d i n g S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
