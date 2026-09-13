import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_controller.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _idController = TextEditingController(); // used for both USN and Faculty ID
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _loginType = 'Student'; // 'Student' or 'Faculty'

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    if (_loginType == 'Student') {
      await ref.read(authControllerProvider.notifier).loginWithUsn(
            _idController.text.trim(),
            _passwordController.text,
          );
    } else {
      await ref.read(authControllerProvider.notifier).loginWithFacultyId(
            _idController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    // Show error snackbar if login fails
    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (_, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/branding/aikya_logo_cropped.png',
                    height: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to AIKYA',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _loginType == 'Student' 
                      ? 'Login with your USN to continue'
                      : 'Login with your Faculty ID to continue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'Student',
                        label: Text('Student'),
                      ),
                      ButtonSegment<String>(
                        value: 'Faculty',
                        label: Text('Faculty'),
                      ),
                    ],
                    selected: {_loginType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _loginType = newSelection.first;
                        _idController.clear();
                        _passwordController.clear();
                      });
                    },
                  ),

                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: _loginType == 'Student' ? 'USN' : 'Faculty ID',
                      hintText: _loginType == 'Student' ? 'e.g. 4MW20CS001' : 'e.g. 0544',
                      prefixIcon: const Icon(Icons.badge),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _loginType == 'Student' ? 'USN is required' : 'Faculty ID is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 24),
                  
                  if (_loginType == 'Student')
                    TextButton(
                      onPressed: authState.isLoading ? null : () => context.push('/signup'),
                      child: RichText(
                        text: TextSpan(
                          text: 'New User? ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
