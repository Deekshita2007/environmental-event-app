import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../services/auth_service.dart';
import '../services/app_preferences.dart';
import '../utils/constants.dart';
import '../widgets/app_icon.dart';
import '../widgets/custom_button.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final AppPreferences preferences;
  final AuthService? authService;

  const LoginPage({super.key, required this.preferences, this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthService _authService;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isRegister = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final enteredEmail = _emailController.text.trim();
    final email = _gmailAddress(enteredEmail);
    final password = _passwordController.text;

    if (_isRegister && name.isEmpty) {
      _showMessage('Please enter your name');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Please enter your email');
      return;
    }

    if (!RegExp(
      r'^[A-Z0-9._%+-]+@gmail\.com$',
      caseSensitive: false,
    ).hasMatch(email)) {
      _showMessage('Please enter a valid Gmail address ending in @gmail.com');
      return;
    }

    if (password.trim().isEmpty) {
      _showMessage('Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isRegistering = _isRegister;
    final AuthResult result;
    try {
      if (isRegistering) {
        result = await _authService.register(name, email, password);
      } else {
        result = await _authService.login(email, password);
      }
    } on FirebaseException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showMessage(
        isRegistering
            ? 'Could not save your account data. Please try again.'
            : 'Could not sign in. Please try again.',
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result == AuthResult.success && isRegistering) {
      await _authService.logout();
      _passwordController.clear();
      setState(() {
        _isRegister = false;
      });
      _showMessage('Account created. Please log in.');
      return;
    }

    if (result == AuthResult.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            authService: _authService,
            preferences: widget.preferences,
          ),
        ),
      );
    } else if (result == AuthResult.accountNotFound) {
      _showMessage(
        'You don’t have an account in this app. Please create an account.',
      );
    } else if (result == AuthResult.incorrectCredentials) {
      _showMessage('Incorrect email or password. Please try again.');
    } else if (result == AuthResult.accountAlreadyExists) {
      _showMessage('An account with this email already exists. Please log in.');
    } else if (result == AuthResult.error) {
      _showMessage('Could not access your account. Please try again.');
    } else {
      _showMessage('Please enter your email and password.');
    }
  }

  Future<void> _forgotPassword() async {
    final email = _gmailAddress(_emailController.text.trim());
    if (!RegExp(
      r'^[A-Z0-9._%+-]+@gmail\.com$',
      caseSensitive: false,
    ).hasMatch(email)) {
      _showMessage('Enter a valid Gmail address to reset your password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    final result = await _authService.sendPasswordResetEmail(email);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (result == PasswordResetResult.success) {
      _showMessage(
        'If an account exists for this email, password reset instructions have been sent.',
      );
    } else if (result == PasswordResetResult.invalidInput) {
      _showMessage('Enter a valid Gmail address to reset your password.');
    } else {
      _showMessage('Could not send the reset email. Please try again.');
    }
  }

  String _gmailAddress(String input) {
    final localPart = input.replaceFirst(
      RegExp(r'@gmail\.com$', caseSensitive: false),
      '',
    );
    return '$localPart@gmail.com';
  }

  void _normalizeEmailInput(String value) {
    final localPart = value.replaceFirst(
      RegExp(r'@gmail\.com$', caseSensitive: false),
      '',
    );
    if (localPart == value) return;
    _emailController.value = TextEditingValue(
      text: localPart,
      selection: TextSelection.collapsed(offset: localPart.length),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                children: [
                  const SizedBox(height: 25),

                  // Logo
                  const AppIcon(size: 90),

                  const SizedBox(height: 20),

                  Text(
                    'EcoConnect',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Connect. Act. Protect.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    _isRegister ? 'Create your account' : 'Welcome back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (_isRegister) ...[
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    onChanged: _normalizeEmailInput,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      suffixText: '@gmail.com',
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  if (!_isRegister)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _forgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),

                  const SizedBox(height: 25),

                  if (_isLoading)
                    const CircularProgressIndicator(color: AppColors.primary)
                  else
                    CustomButton(
                      text: _isRegister ? 'CREATE ACCOUNT' : 'LOGIN',
                      icon: _isRegister ? Icons.person_add_alt_1 : Icons.login,
                      onPressed: _submit,
                    ),

                  const SizedBox(height: 18),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegister = !_isRegister;
                      });
                    },
                    child: Text(
                      _isRegister
                          ? 'Already have an account? Login'
                          : 'New here? Create an account',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Together we can make our planet greener 🌍',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
