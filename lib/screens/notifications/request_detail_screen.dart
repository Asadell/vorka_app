import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('R e q u e s t D e t a i l S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: R e q u e s t D e t a i l S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
