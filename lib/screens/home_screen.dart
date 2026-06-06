import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
      ),
      body: const Center(
        child: Text('No saved requests yet'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/request'),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }
}
