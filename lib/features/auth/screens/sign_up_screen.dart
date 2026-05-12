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
import 'package:project/features/profile/providers/profile_provider.dart';

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

  bool _isLoading = false;

  void _handleSignUp() async {
    if (!_isValidForm()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.signUp();

    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null && result.isSuccess) {
        await context.read<ProfileProvider>().loadCurrentUser();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account created!"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result != null && result.isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? "Sign up failed"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildButton() {
    final bool isLastPage = _page == (pages - 1);

    if (_page == 0) {
      return PrimaryButton(text: "Next", onPressed: _nextPage);
    }

    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: "Back",
            onPressed: _isLoading ? null : _previousPage,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: PrimaryButton(
            text: isLastPage ? "Submit" : "Next",
            isLoading: isLastPage ? _isLoading : false,
            onPressed: _isLoading
                ? null
                : (isLastPage ? _handleSignUp : _nextPage),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final indicatorTheme = theme.extension<SmoothPageIndicatorThemeExtension>();

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 32),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: pages,
                  effect: indicatorTheme?.expandingDotsEffect ?? WormEffect(),
                  onDotClicked: (index) {},
                ),
                SizedBox(height: 24),
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
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? "),
                    TextButton(
                      child: Text("Log in"),
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
      ),
    );
  }
}
