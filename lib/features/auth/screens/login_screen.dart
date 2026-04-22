import 'package:flutter/material.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/core/widgets/inputs/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  hiddenText: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: "Login",
                  onPressed: () {
                    // TODO: Implement login logic
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
