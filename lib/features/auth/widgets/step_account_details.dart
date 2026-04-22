import 'package:flutter/material.dart';
import 'package:project/core/widgets/inputs/app_text_field.dart';
import 'package:project/core/services/auth_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AccountDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const AccountDetails({super.key, required this.formKey});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final AuthService auth = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _emailExists = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _usernameController.text = authProvider.username ?? "";
    _emailController.text = authProvider.email ?? "";
    _passwordController.text = authProvider.password ?? "";
    _confirmPasswordController.text = authProvider.password ?? "";
  }

  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Add at least one uppercase letter.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Add at least one lowercase letter.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Add at least one number.';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Add at least one special character.';
    }
    return null;
  }

  void handleOnSave(String? value) {
    final authProvider = context.read<AuthProvider>();
    authProvider.updateAccountDetails(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppTextField(
          controller: _usernameController,
          labelText: "Username",
          hintText: "Enter Username",
          autovalidateMode: AutovalidateMode.onUserInteractionIfError,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username is required';
            }
            if (value.length < 5) {
              return 'Username is too short';
            }
            if (value.length > 20) {
              return 'Username is too long';
            }
            if (!RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(value)) {
              return 'Special characters other than (_) or (.) are not allowed';
            }
            return null;
          },
          onSaved: (value) => handleOnSave(value),
        ),
        SizedBox(height: 16),
        AppTextField(
          controller: _emailController,
          labelText: "Email",
          hintText: "Enter Email",
          autovalidateMode: AutovalidateMode.onUserInteractionIfError,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) async {
            final result = await auth.doesEmailExist(value);
            if (result.isSuccess) {
              final exists = result.data == true;
              if (_emailExists != exists) {
                setState(() => _emailExists = exists);
                widget.formKey.currentState?.validate();
              }
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!EmailValidator.validate(value)) {
              return 'Email is invalid';
            }
            if (_emailExists) {
              return 'Email already exists';
            }
            return null;
          },
          onSaved: (value) => handleOnSave(value),
        ),
        SizedBox(height: 16),
        AppTextField(
          controller: _passwordController,
          labelText: "Password",
          hintText: "Enter Password",
          autovalidateMode: AutovalidateMode.onUserInteractionIfError,
          hiddenText: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }
            return validatePassword(value);
          },
          onSaved: (value) => handleOnSave(value),
        ),
        SizedBox(height: 16),
        AppTextField(
          controller: _confirmPasswordController,
          labelText: "Confirm Password",
          hintText: "Confirm Password",
          autovalidateMode: AutovalidateMode.onUserInteractionIfError,
          hiddenText: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          onSaved: (value) => handleOnSave(value),
        ),
      ],
    );
  }
}
