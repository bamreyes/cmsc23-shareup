import 'package:flutter/material.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("404 Not Found"),
              PrimaryButton(
                text: "Logout",
                onPressed: () {
                  final authProvider = context.read<AuthProvider>();
                  authProvider.logOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
