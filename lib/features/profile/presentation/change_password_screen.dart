import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/features/auth/presentation/auth_messages.dart';
import 'package:aub/features/profile/data/profile_api.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required this.api});

  final ProfileApi api;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.clear();
    _next.clear();
    _confirm.clear();
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.changePassword(
        currentPassword: _current.text,
        password: _next.text,
        passwordConfirmation: _confirm.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      setState(() {
        _error = _messageFor(error);
        _saving = false;
      });
    }
  }

  String _messageFor(ApiException error) {
    if (error.fields?['current_password'] != null) {
      return AppStrings.currentPasswordWrong;
    }
    if (error.fields?['password'] != null) {
      return AppStrings.passwordTooShort;
    }
    return AuthMessages.forException(error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AubColors.surfaceIvory,
      appBar: AppBar(title: const Text(AppStrings.changePassword)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AubSpacing.margin),
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _passwordField(
                    controller: _current,
                    label: AppStrings.currentPasswordLabel,
                    autofill: AutofillHints.password,
                  ),
                  const SizedBox(height: AubSpacing.md),
                  _passwordField(
                    controller: _next,
                    label: AppStrings.newPasswordLabel,
                    autofill: AutofillHints.newPassword,
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return AppStrings.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AubSpacing.md),
                  _passwordField(
                    controller: _confirm,
                    label: AppStrings.confirmPasswordLabel,
                    autofill: AutofillHints.newPassword,
                    validator: (value) {
                      if (value != _next.text) {
                        return AppStrings.passwordMismatch;
                      }
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AubSpacing.md),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AubSpacing.lg),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(AppStrings.savePassword),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String autofill,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_saving,
      obscureText: _obscure,
      autofillHints: [autofill],
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.passwordRequired;
            }
            return null;
          },
    );
  }
}
