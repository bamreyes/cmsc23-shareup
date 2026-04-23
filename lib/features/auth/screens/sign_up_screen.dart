import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/features/auth/widgets/step_account_details.dart';
import 'package:project/features/auth/widgets/step_user_preferences.dart';
import 'package:project/features/auth/widgets/step_verification_photo.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/core/widgets/buttons/secondary_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:project/core/theme/extensions/smooth_page_indicator_theme.dart';
import 'package:provider/provider.dart';
import 'package:project/features/auth/providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late PageController _pageController;
  final _formKey = GlobalKey<FormState>();
  final int pages = 3;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!_isValidForm()) return;
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isValidForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }

  void _handleSignUp() {
    if (!_isValidForm()) return;

    final authProvider = context.read<AuthProvider>();
    authProvider.signUp();
  }

  Widget _buildButton() {
    final bool isLastPage = _page == (pages - 1);

    if (_page == 0) {
      return PrimaryButton(text: "Next", onPressed: _nextPage);
    }

    return Row(
      children: [
        Expanded(
          child: SecondaryButton(text: "Back", onPressed: _previousPage),
        ),
        SizedBox(width: 16),
        Expanded(
          child: PrimaryButton(
            text: isLastPage ? "Submit" : "Next",
            onPressed: isLastPage ? _handleSignUp : _nextPage,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorTheme = theme.extension<SmoothPageIndicatorThemeExtension>();

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SmoothPageIndicator(
                controller: _pageController,
                count: pages,
                effect: indicatorTheme?.expandingDotsEffect ?? WormEffect(),
                onDotClicked: (index) {},
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      AccountDetails(formKey: _formKey),
                      UserPreferences(),
                      VerificationPhoto(),
                    ],
                    onPageChanged: (index) => setState(() {
                      _page = index;
                    }),
                  ),
                ),
              ),
              SizedBox(height: 24),
              _buildButton(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  TextButton(
                    child: const Text("Log in"),
                    onPressed: () {
                      final authProvider = context.read<AuthProvider>();
                      authProvider.clearProvider();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
