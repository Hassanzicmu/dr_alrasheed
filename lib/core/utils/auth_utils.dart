import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dr_abdulaziz_al_rasheed/features/auth/providers/auth_provider.dart';

void performActionWithAuthCheck(BuildContext context, WidgetRef ref, VoidCallback action) {
  final authState = ref.read(authStateProvider);
  
  if (authState.isGuest || authState.user == null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login or create an account to book an appointment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  } else {
    action();
  }
}
