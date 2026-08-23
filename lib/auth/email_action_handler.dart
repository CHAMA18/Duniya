import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Handles Firebase email-action links (verification / password reset /
/// email recovery) that point directly at the web app.
///
/// Background: emails used to route through the legacy
/// `pharmaaid.page.link` Firebase Dynamic Links domain, which was never
/// whitelisted as an OAuth/redirect domain (and Dynamic Links itself was
/// shut down by Google in August 2025). Clicking those links showed the
/// Firebase "domain not authorized" error card.
///
/// All email actions are now sent with `ActionCodeSettings(
/// handleCodeInApp: true, url: <app origin>/…)` so the email link opens
/// the app itself and this handler completes the action in-app.
class EmailActionHandler extends StatefulWidget {
  const EmailActionHandler({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<EmailActionHandler> createState() => _EmailActionHandlerState();
}

class _EmailActionHandlerState extends State<EmailActionHandler> {
  bool _handled = false;
  String? _banner;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _process());
    }
  }

  Future<void> _process() async {
    if (_handled) return;
    final uri = Uri.base;
    final mode = uri.queryParameters['mode'];
    final oobCode = uri.queryParameters['oobCode'];
    if (mode == null || oobCode == null || mode.isEmpty || oobCode.isEmpty) {
      return; // normal navigation — nothing to do
    }
    _handled = true;

    switch (mode) {
      case 'verifyEmail':
        await _verifyEmail(oobCode);
      case 'resetPassword':
        await _resetPassword(oobCode);
      case 'recoverEmail':
        setState(() => _banner =
            'Email address recovered. You can now sign in with your restored address.');
        _goLogin();
      default:
        setState(() => _banner = 'This email link is no longer valid.');
        _goLogin();
    }
  }

  Future<void> _verifyEmail(String oobCode) async {
    try {
      await FirebaseAuth.instance.checkActionCode(oobCode);
      await FirebaseAuth.instance.applyActionCode(oobCode);
      await FirebaseAuth.instance.currentUser?.reload();
      setState(() => _banner = 'Email verified successfully. Please sign in.');
    } on FirebaseAuthException catch (e) {
      setState(() => _banner =
          'We could not verify this email (${e.code}). The link may have expired — please request a new one.');
    } catch (_) {
      setState(() =>
          _banner = 'We could not verify this email. The link may have expired.');
    }
    _goLogin();
  }

  Future<void> _resetPassword(String oobCode) async {
    String email;
    try {
      email = await FirebaseAuth.instance.verifyPasswordResetCode(oobCode);
    } on FirebaseAuthException catch (e) {
      setState(() => _banner =
          'This password reset link is no longer valid (${e.code}). Please request a new one.');
      _goLogin();
      return;
    } catch (_) {
      setState(() => _banner =
          'This password reset link is no longer valid. Please request a new one.');
      _goLogin();
      return;
    }
    context.goNamed(
      SetNewPasswordWidget.routeName,
      queryParameters: {'oobCode': oobCode, 'email': email},
    );
  }

  void _goLogin() {
    if (!mounted) return;
    // Route to the login screen. GoRouter replaces the current entry
    // (including the email-action URL with its mode/oobCode params), so a
    // refresh cannot re-run the handler.
    context.go(LoginUniWidget.routePath);
  }

  @override
  Widget build(BuildContext context) {
    if (_banner == null) return widget.child;
    return Column(
      children: [
        Material(
          color: const Color(0xFF10B981),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _banner!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18),
                    onPressed: () =>
                        setState(() => _banner = null),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
