import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../utils/friendly_error.dart';
import '../../../widgets/password_field.dart';
import 'auth_controller.dart';

/// First-login password change for faculty, coordinators and the HOD (spec §5).
class ForcePasswordResetScreen extends ConsumerStatefulWidget {
  const ForcePasswordResetScreen({super.key});

  @override
  ConsumerState<ForcePasswordResetScreen> createState() => _ForcePasswordResetScreenState();
}

class _ForcePasswordResetScreenState extends ConsumerState<ForcePasswordResetScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).updatePassword(_newPasswordController.text);
    if (!mounted) return;

    // The controller captures failures into its state rather than throwing.
    final state = ref.read(authControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      state.hasError
          ? SnackBar(content: Text(friendlyError(state.error!)), backgroundColor: AppColors.error)
          : const SnackBar(content: Text('Password updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Requirement'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/branding/aikya_logo_cropped.png', height: 64),
                  const SizedBox(height: 24),
                  Text(
                    'Change Your Password',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'For your security, choose a new password before you continue using AIKYA.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  PasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password is required';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    autofillHints: const [AutofillHints.newPassword],
                    onSubmitted: (_) => _updatePassword(),
                    validator: (value) => value != _newPasswordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _updatePassword,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Update Password'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref.read(authControllerProvider.notifier).logout(),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Logout'),
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
