import '/backend/email/email_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

class EmailTestWidget extends StatefulWidget {
  const EmailTestWidget({super.key});

  static String routeName = 'EmailTest';
  static String routePath = '/email-test';

  @override
  State<EmailTestWidget> createState() => _EmailTestWidgetState();
}

class _EmailTestWidgetState extends State<EmailTestWidget> {
  final _testEmailController = TextEditingController(text: '');
  String? _selectedTemplate;
  bool _isSending = false;
  String? _lastResult;

  @override
  void dispose() {
    _testEmailController.dispose();
    super.dispose();
  }

  Future<void> _sendTestEmail(String templateName) async {
    final email = _testEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _lastResult = null;
    });

    EmailResult result;
    switch (templateName) {
      case 'welcome':
        result = await EmailService.sendWelcomeEmail(
          to: email,
          displayName: 'Test User',
        );
        break;
      case 'password_reset':
        result = await EmailService.sendPasswordResetEmail(
          to: email,
          resetLink: 'https://thestackone.com/reset?token=test123',
        );
        break;
      case 'low_stock':
        result = await EmailService.sendLowStockAlert(
          to: email,
          pharmacyName: 'Test Pharmacy',
          items: const [
            LowStockItem(name: 'Paracetamol 500mg', currentStock: 3, minStock: 20),
            LowStockItem(name: 'Amoxicillin 250mg', currentStock: 1, minStock: 15),
          ],
        );
        break;
      case 'expiry_warning':
        result = await EmailService.sendExpiryWarning(
          to: email,
          pharmacyName: 'Test Pharmacy',
          items: const [
            ExpiryItem(name: 'Ibuprofen 400mg', batchNumber: 'B-2024-001', expiryDate: '15 Sep 2026'),
            ExpiryItem(name: 'Cetirizine 10mg', batchNumber: 'B-2024-042', expiryDate: '22 Sep 2026'),
          ],
        );
        break;
      default:
        result = EmailResult(success: false, error: 'Unknown template');
    }

    setState(() {
      _isSending = false;
      _lastResult = result.success
          ? '✅ Email sent successfully to $email'
          : '❌ Failed: ${result.error}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.primaryText, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Email Test Lab',
          style: theme.headlineSmall.override(
            fontFamily: theme.headlineSmallFamily,
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            useGoogleFonts: !theme.headlineSmallIsCustom,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Test email input ──
              _buildEmailInput(theme),
              const SizedBox(height: 24),

              // ── Template cards ──
              Text(
                'Email Templates',
                style: theme.titleMedium.override(
                  fontFamily: theme.titleMediumFamily,
                  color: theme.primaryText,
                  fontWeight: FontWeight.w700,
                  useGoogleFonts: !theme.titleMediumIsCustom,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Preview and send test emails using Resend.',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
              const SizedBox(height: 16),

              _buildTemplateCard(
                theme,
                name: 'welcome',
                title: 'Welcome Email',
                description: 'Sent to new users when they create an account.',
                icon: Icons.waving_hand_rounded,
                color: const Color(0xFF7C3AED),
              ),
              _buildTemplateCard(
                theme,
                name: 'password_reset',
                title: 'Password Reset',
                description: 'Sent when a user requests a password reset.',
                icon: Icons.lock_reset_rounded,
                color: const Color(0xFF2563EB),
              ),
              _buildTemplateCard(
                theme,
                name: 'low_stock',
                title: 'Low Stock Alert',
                description: 'Sent when inventory falls below reorder level.',
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFFDC2626),
              ),
              _buildTemplateCard(
                theme,
                name: 'expiry_warning',
                title: 'Expiry Warning',
                description: 'Sent daily for batches expiring within 30 days.',
                icon: Icons.timer_rounded,
                color: const Color(0xFFF59E0B),
              ),

              const SizedBox(height: 24),

              // ── Result banner ──
              if (_lastResult != null)
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _lastResult!.startsWith('✅')
                          ? const Color(0xFF059669).withValues(alpha: 0.1)
                          : const Color(0xFFDC2626).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _lastResult!.startsWith('✅')
                            ? const Color(0xFF059669).withValues(alpha: 0.3)
                            : const Color(0xFFDC2626).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _lastResult!,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: _lastResult!.startsWith('✅')
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                        fontWeight: FontWeight.w500,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInput(FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.lineColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send to',
            style: theme.labelMedium.override(
              fontFamily: theme.labelMediumFamily,
              color: theme.secondaryText,
              fontWeight: FontWeight.w600,
              useGoogleFonts: !theme.labelMediumIsCustom,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _testEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'test@example.com',
              hintStyle: TextStyle(color: theme.secondaryText.withValues(alpha: 0.5)),
              filled: true,
              fillColor: theme.primaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.lineColor.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.lineColor.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.primaryText,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    FlutterFlowTheme theme, {
    required String name,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedTemplate == name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.3) : theme.lineColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: theme.secondaryText,
                        fontSize: 12,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ],
                ),
              ),

              // Send button
              FFButtonWidget(
                onPressed: _isSending ? null : () => _sendTestEmail(name),
                text: _isSending && _selectedTemplate == name ? '' : 'Send',
                icon: _isSending && _selectedTemplate == name
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : null,
                options: FFButtonOptions(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  color: color,
                  textStyle: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
