import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/core/widgets/inputs/app_text_field.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -1.4),
            radius: 1.8,
            colors: [
              colorScheme.primary.withValues(alpha: 0.2),
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.surface.withValues(alpha: 0.0),
            ],
            stops: [0.0, 0.2, 0.4, 0.6],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autovalidateMode:
                                AutovalidateMode.onUserInteractionIfError,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          AppTextField(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            hiddenText: true,
                            controller: _passwordController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteractionIfError,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 40),
                          if (_errorMessage != null)
                            Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          PrimaryButton(
                            text: "Login",
                            isLoading: _isLoading,
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }

                                    setState(() {
                                      _errorMessage = null;
                                      _isLoading = true;
                                    });

                                    final authProvider = context
                                        .read<AuthProvider>();

                                    final result = await authProvider.signIn(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );

                                    if (!mounted) return;

                                    setState(() {
                                      _isLoading = false;
                                      if (result.isError) {
                                        _errorMessage = result.error;
                                      }
                                    });
                                  },
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account? "),
                              TextButton(
                                child: Text("Sign up"),
                                onPressed: () => context.go('/signup'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
