import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class Step2TimelineScreen extends StatelessWidget {
  const Step2TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('S t e p2 T i m e l i n e S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: S t e p2 T i m e l i n e S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
