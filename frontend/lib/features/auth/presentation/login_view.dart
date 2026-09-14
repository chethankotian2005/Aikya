import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../utils/friendly_error.dart';
import '../../../widgets/password_field.dart';
import 'auth_controller.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _idController = TextEditingController(); // USN or Faculty ID
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isStudent = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authControllerProvider.notifier);
    if (_isStudent) {
      await auth.loginWithUsn(_idController.text.trim(), _passwordController.text);
    } else {
      await auth.loginWithFacultyId(_idController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(friendlyError(state.error!)),
            backgroundColor: AppColors.error,
          ));
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/branding/aikya_logo_cropped.png', height: 80),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to AIKYA',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isStudent
                          ? 'Login with your USN to continue'
                          : 'Login with your Faculty ID to continue',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Student')),
                        ButtonSegment(value: false, label: Text('Faculty')),
                      ],
                      selected: {_isStudent},
                      showSelectedIcon: false,
                      onSelectionChanged: (selection) {
                        setState(() {
                          _isStudent = selection.first;
                          _idController.clear();
                          _passwordController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _idController,
                      textCapitalization:
                          _isStudent ? TextCapitalization.characters : TextCapitalization.none,
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _isStudent ? 'USN' : 'Faculty ID',
                        hintText: _isStudent ? 'e.g. 4MW21AI042' : 'e.g. 0544',
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? (_isStudent ? 'USN is required' : 'Faculty ID is required')
                          : null,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _passwordController,
                      onSubmitted: (_) => _login(),
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
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 24),
                    if (_isStudent)
                      TextButton(
                        onPressed: authState.isLoading ? null : () => context.push('/signup'),
                        child: RichText(
                          text: TextSpan(
                            text: 'New User? ',
                            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.secondary,
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
      ),
    );
  }
}
