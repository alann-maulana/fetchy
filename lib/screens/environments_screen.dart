import 'package:flutter/material.dart';

class EnvironmentsScreen extends StatelessWidget {
  const EnvironmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environments'),
      ),
      body: const Center(
        child: Text('Environments Screen'),
      ),
    );
  }
}
