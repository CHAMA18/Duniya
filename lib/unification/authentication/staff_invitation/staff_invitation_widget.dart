import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_functions/cloud_functions.dart';
import '/backend/backend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import '/index.dart';

/// Staff invitation acceptance page.
///
/// Reached via deep link: /#/accept-invitation?token=xxx&email=xxx
/// Verifies the invitation token, displays the assigned role and pharmacy,
/// and lets the invitee create their account.
class StaffInvitationWidget extends StatefulWidget {
  const StaffInvitationWidget({super.key});

  static String routeName = 'StaffInvitation';
  static String routePath = '/accept-invitation';

  @override
  State<StaffInvitationWidget> createState() => _StaffInvitationWidgetState();
}

class _StaffInvitationWidgetState extends State<StaffInvitationWidget> {
  // Brand tokens
  static const Color _pulsePurple = Color(0xFF9900FF);
  static const Color _bgColor = Color(0xFFF8F9FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _textPrimary = Color(0xFF0B1C30);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _successColor = Color(0xFF10B981);

  // Invitation data
  String? _token;
  String? _email;
  bool _isLoading = true;
  bool _isValid = false;
  String? _errorMessage;
  String? _invitedName;
  String? _invitedRole;
  String? _pharmacyName;
  String? _invitationId;

  // Account creation
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isCreating = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyInvitation());
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyInvitation() async {
    // Extract token and email from URL query params
    final uri = GoRouterState.of(context).uri;
    _token = uri.queryParameters['token'];
    _email = uri.queryParameters['email'];

    if (_token == null || _email == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid invitation link. Please check the URL.';
      });
      return;
    }

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'verifyStaffInvitation',
      );
      final result = await callable.call({'token': _token, 'email': _email});

      final data = result.data;
      if (data['valid'] == true) {
        setState(() {
          _isLoading = false;
          _isValid = true;
          _invitedName = data['name'];
          _invitedRole = data['role'];
          _pharmacyName = data['pharmacyName'];
          _invitationId = data['invitationId'];
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = data['reason'] ?? 'Invalid or expired invitation.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to verify invitation. Please try again.';
      });
    }
  }

  bool get _isFormValid {
    final pw = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (pw.length < 8) return false;
    if (pw != confirm) return false;
    return true;
  }

  void _validatePassword(String value) {
    final hasMinLength = value.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value);

    if (!hasMinLength) {
      _passwordError = 'Password must be at least 8 characters';
    } else if (!hasUppercase) {
      _passwordError = 'Include at least one uppercase letter';
    } else if (!hasDigit) {
      _passwordError = 'Include at least one number';
    } else if (!hasSpecial) {
      _passwordError = 'Include at least one special character (!@#\$%)';
    } else {
      _passwordError = null;
    }
    setState(() {});
  }

  Future<void> _createAccount() async {
    if (!_isFormValid || _isCreating) return;

    final pw = _passwordController.text;
    if (pw != _confirmPasswordController.text) {
      setState(() => _passwordError = 'Passwords do not match');
      return;
    }

    setState(() => _isCreating = true);
    try {
      // Create Firebase Auth user
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email!, password: pw);

      final user = userCredential.user;
      if (user == null) throw Exception('Account creation failed');

      // Create user document in Firestore
      await UserRecord.collection
          .doc(user.uid)
          .set(
            createUserRecordData(
              email: _email,
              displayName: _invitedName ?? '',
              role: _invitedRole ?? '',
              accountType: 'Pharmacy',
              uid: user.uid,
              createdTime: getCurrentTimestamp,
              // If we have a pharmacy reference, set it
            ),
          );

      // Complete acceptance server-side. Client writes to Staff are denied, so
      // this keeps the HR invitation state authoritative.
      if (_invitationId != null) {
        final callable = FirebaseFunctions.instance.httpsCallable(
          'completeStaffInvitation',
        );
        await callable.call({'invitationId': _invitationId});
      }

      // Navigate to home
      if (mounted) {
        context.goNamedAuth(HomeWidget.routeName, context.mounted);
      }
    } on firebase_core.FirebaseException catch (e) {
      String msg = 'Account creation failed. Please try again.';
      if (e.code == 'email-already-in-use') {
        msg = 'An account with this email already exists. Please sign in.';
      } else if (e.code == 'weak-password') {
        msg = 'The password is too weak. Please use a stronger password.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _isLoading ? _buildLoading() : _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_pulsePurple, Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.mail_outline_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(color: _pulsePurple),
        const SizedBox(height: 16),
        Text(
          'Verifying your invitation...',
          style: TextStyle(
            fontSize: 15,
            color: _textSecondary,
            fontFamily: kAppFontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) return _buildError();
    if (!_isValid) return const SizedBox.shrink();
    return _buildInvitationCard();
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Invalid Invitation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              fontFamily: kAppFontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              fontFamily: kAppFontFamily,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          FFButtonWidget(
            onPressed: () => context.goNamed(HomeWidget.routeName),
            text: 'Go to Home',
            options: FFButtonOptions(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: _pulsePurple,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: kAppFontFamily,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCard() {
    final roleIcon = _getRoleIcon(_invitedRole);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header icon
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_pulsePurple, Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.person_add_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Center(
            child: Text(
              'You\'re Invited!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                fontFamily: kAppFontFamily,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Create your account to join $_pharmacyName',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _textSecondary,
                fontFamily: kAppFontFamily,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Role card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _pulsePurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(roleIcon, color: _pulsePurple, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Role',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                          fontFamily: kAppFontFamily,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _invitedRole ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          fontFamily: kAppFontFamily,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _pharmacyName ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                          fontFamily: kAppFontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Email (read-only)
          Text(
            'Email',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
              fontFamily: kAppFontFamily,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor),
            ),
            child: Text(
              _email ?? '',
              style: TextStyle(
                fontSize: 14,
                color: _textPrimary,
                fontFamily: kAppFontFamily,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Password
          Text(
            'Create Password',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
              fontFamily: kAppFontFamily,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onChanged: _validatePassword,
            style: TextStyle(fontSize: 14, fontFamily: kAppFontFamily),
            decoration: InputDecoration(
              hintText: 'At least 8 characters',
              hintStyle: TextStyle(
                color: _textSecondary.withValues(alpha: 0.5),
                fontFamily: kAppFontFamily,
              ),
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
              prefixIconColor: _textSecondary,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: _surfaceColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _pulsePurple, width: 1.5),
              ),
              errorText: _passwordError,
              errorStyle: TextStyle(fontSize: 12, fontFamily: kAppFontFamily),
            ),
          ),

          // Password strength indicators
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildPasswordStrength(),
          ],

          const SizedBox(height: 16),

          // Confirm Password
          Text(
            'Confirm Password',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
              fontFamily: kAppFontFamily,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: TextStyle(fontSize: 14, fontFamily: kAppFontFamily),
            decoration: InputDecoration(
              hintText: 'Re-enter the password',
              hintStyle: TextStyle(
                color: _textSecondary.withValues(alpha: 0.5),
                fontFamily: kAppFontFamily,
              ),
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
              prefixIconColor: _textSecondary,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              filled: true,
              fillColor: _surfaceColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _pulsePurple, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Create Account button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FFButtonWidget(
              onPressed: _isFormValid && !_isCreating ? _createAccount : null,
              text: _isCreating ? 'Creating Account...' : 'Create Account',
              options: FFButtonOptions(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                color: _isFormValid ? _pulsePurple : _borderColor,
                textStyle: TextStyle(
                  color: _isFormValid ? Colors.white : _textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  fontFamily: kAppFontFamily,
                ),
                borderRadius: BorderRadius.circular(10),
                disabledColor: _borderColor,
                disabledTextColor: _textSecondary,
              ),
            ),
          ),

          // Sign in link
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.goNamed(LoginUniWidget.routeName),
              child: Text(
                'Already have an account? Sign in',
                style: TextStyle(
                  fontSize: 13,
                  color: _pulsePurple,
                  fontWeight: FontWeight.w600,
                  fontFamily: kAppFontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStrength() {
    final pw = _passwordController.text;
    final hasMinLength = pw.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(pw);
    final hasDigit = RegExp(r'[0-9]').hasMatch(pw);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pw);

    int score = [
      hasMinLength,
      hasUppercase,
      hasDigit,
      hasSpecial,
    ].where((x) => x).length;

    Color strengthColor;
    String strengthText;
    if (score <= 1) {
      strengthColor = const Color(0xFFEF4444);
      strengthText = 'Weak';
    } else if (score == 2) {
      strengthColor = const Color(0xFFF59E0B);
      strengthText = 'Fair';
    } else if (score == 3) {
      strengthColor = const Color(0xFF3B82F6);
      strengthText = 'Good';
    } else {
      strengthColor = _successColor;
      strengthText = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: hasMinLength ? _successColor : _borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: hasUppercase ? _successColor : _borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: hasDigit ? _successColor : _borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: hasSpecial ? _successColor : _borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildStrengthChip('8+', hasMinLength),
            const SizedBox(width: 6),
            _buildStrengthChip('Aa', hasUppercase),
            const SizedBox(width: 6),
            _buildStrengthChip('0-9', hasDigit),
            const SizedBox(width: 6),
            _buildStrengthChip('!@#', hasSpecial),
            const Spacer(),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: strengthColor,
                fontFamily: kAppFontFamily,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStrengthChip(String label, bool met) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: met ? _successColor.withValues(alpha: 0.1) : _bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: met ? _successColor.withValues(alpha: 0.3) : _borderColor,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: met ? _successColor : _textSecondary,
          fontFamily: kAppFontFamily,
        ),
      ),
    );
  }

  IconData _getRoleIcon(String? role) {
    switch (role) {
      case 'Cashier':
        return Icons.point_of_sale_outlined;
      case 'Sales Assistant':
        return Icons.storefront_outlined;
      case 'Pharmacy Technician':
        return Icons.science_outlined;
      case 'Pharmacist':
        return Icons.local_pharmacy_outlined;
      case 'Pharmacy Manager':
        return Icons.admin_panel_settings_outlined;
      case 'Owner':
        return Icons.shield_outlined;
      default:
        return Icons.person_outline;
    }
  }
}
