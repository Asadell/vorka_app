import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class AddDepartmentsScreen extends StatelessWidget {
  const AddDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('A d d D e p a r t m e n t s S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: A d d D e p a r t m e n t s S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
