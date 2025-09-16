import 'package:fair_share/features/authentication/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RemoveAccountSuccessScreen extends StatelessWidget {
  static const routeName = '/account-deleted';
  const RemoveAccountSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Account deleted')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(Icons.check_circle_rounded, size: 96, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Your account has been deleted',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We’re sorry to see you go. If this was a mistake, you can create a new account anytime.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Go to sign-in / onboarding
                Get.to(() => LoginScreen());
                },
                child: const Text('Go to Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
