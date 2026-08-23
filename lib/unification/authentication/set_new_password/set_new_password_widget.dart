import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/components/pulse_logo_widget.dart';

/// Screen shown after a user clicks a password-reset email link.
/// Receives the one-time `oobCode` and lets the user set a new password,
/// which is applied directly via [FirebaseAuth.confirmPasswordReset].
class SetNewPasswordWidget extends StatefulWidget {
  const SetNewPasswordWidget({
    super.key,
    required this.oobCode,
    this.email,
  });

  static String routeName = 'SetNewPassword';
  static String routePath = '/setNewPassword';

  final String oobCode;
  final String? email;

  @override
  State<SetNewPasswordWidget> createState() => _SetNewPasswordWidgetState();
}

class _SetNewPasswordWidgetState extends State<SetNewPasswordWidget> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode,
        newPassword: password,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Password updated. Please sign in with your new password.')),
      );
      context.goNamed(LoginUniWidget.routeName);
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'invalid-action-code' ||
              e.code == 'expired-action-code'
          ? 'This reset link has already been used or has expired. '
              'Please request a new one from the login page.'
          : (e.message ?? e.code);
      setState(() => _error = msg);
    } catch (_) {
      setState(() => _error =
          'Could not update your password. Please request a new reset link.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Title(
      title: 'Set a New Password',
      color: theme.primary,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFF07070B),
          body: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 26.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 34.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9900FF).withValues(alpha: 0.20),
                        blurRadius: 70.0,
                        offset: const Offset(0, 26.0),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 40.0,
                        offset: const Offset(0, 12.0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PulseLogoWidget(
                        size: 64.0,
                        showWordmark: true,
                        color: theme.primary,
                      ),
                      const SizedBox(height: 28.0),
                      const Text(
                        'Set a New Password',
                        style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: Color(0xFF162033),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        widget.email != null && widget.email!.isNotEmpty
                            ? 'Choose a new password for ${widget.email}.'
                            : 'Choose a new password for your account.',
                        style: const TextStyle(
                          fontSize: 14.0,
                          height: 1.5,
                          color: Color(0xFF5B6478),
                        ),
                      ),
                      const SizedBox(height: 26.0),
                      _field(
                        controller: _passwordController,
                        label: 'New password',
                        hint: 'At least 6 characters',
                        obscure: _obscure,
                        toggle: () => setState(() => _obscure = !_obscure),
                      ),
                      const SizedBox(height: 16.0),
                      _field(
                        controller: _confirmController,
                        label: 'Confirm password',
                        hint: 'Re-enter your new password',
                        obscure: _obscure,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14.0),
                        Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 13.0,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24.0),
                      SizedBox(
                        width: double.infinity,
                        height: 52.0,
                        child: FFButtonWidget(
                          onPressed: _busy ? null : () => _submit(),
                          text: _busy ? 'Updating…' : 'Update Password',
                          options: FFButtonOptions(
                            color: theme.primary,
                            height: 52.0,
                            textStyle: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      Center(
                        child: InkWell(
                          onTap: () =>
                              context.goNamed(LoginUniWidget.routeName),
                          child: const Text(
                            'Back to sign in',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFA100FF),
                            ),
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
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    VoidCallback? toggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF162033),
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 50.0,
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 14.0, color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFFF8F9FF),
              suffixIcon: toggle != null
                  ? IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: toggle,
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFD8DCE2), width: 1.5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFA100FF), width: 1.8),
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
            ),
            style: const TextStyle(fontSize: 14.0, color: Color(0xFF162033)),
          ),
        ),
      ],
    );
  }
}
