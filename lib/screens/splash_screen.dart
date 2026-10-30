import 'package:flutter/material.dart';

import '../services/app_preferences.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/app_icon.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  final AppPreferences preferences;
  final AuthService authService;

  const SplashScreen({
    super.key,
    required this.preferences,
    required this.authService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openLoginPage();
  }

  Future<void> _openLoginPage() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          preferences: widget.preferences,
          authService: widget.authService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(size: 104),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.tagline,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
