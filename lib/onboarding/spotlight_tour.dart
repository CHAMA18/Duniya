import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'onboarding_service.dart';

/// Stable anchors for controls that form the live, in-context product tour.
class PulseTourTargets {
  static final home = GlobalKey(debugLabel: 'tour-home');
  static final inventory = GlobalKey(debugLabel: 'tour-inventory');
  static final humanResources = GlobalKey(debugLabel: 'tour-human-resources');
  static final quickAccess = GlobalKey(debugLabel: 'tour-quick-access');
  static final stockBalances = GlobalKey(debugLabel: 'tour-stock-balances');
  static final userManagement = GlobalKey(debugLabel: 'tour-user-management');
}

class PulseSpotlightTour {
  PulseSpotlightTour._();

  static void show(BuildContext context) {
    final steps = <({GlobalKey key, String title, String body})>[
      (
        key: PulseTourTargets.home,
        title: 'Your dashboard',
        body:
            'Start here for a live overview of sales, stock value, and alerts for your active pharmacy.',
      ),
      (
        key: PulseTourTargets.inventory,
        title: 'Manage inventory',
        body:
            'Use Inventory to find products, review stock levels, and record stock movements.',
      ),
      (
        key: PulseTourTargets.stockBalances,
        title: 'Stock balances & monthly templates',
        body:
            'Stock Balances tracks opening, received, dispensed, transferred, '
            'and closing quantities. Use the Template dropdown to instantly '
            'review balances posted in any of the last 18 months — '
            'January, February, March, and more.',
      ),
      (
        key: PulseTourTargets.humanResources,
        title: 'Manage your team',
        body:
            'Human Resources / User Management is where you add staff and track '
            'their invitation status. Pulse Owners can invite new users with '
            'a branded email — invitees set their own passwords.',
      ),
      (
        key: PulseTourTargets.userManagement,
        title: 'User Management',
        body:
            'Open User Management to invite Pulse users, view role badges, and '
            'manage account status. Only Owner and Staff roles exist on the '
            'Pulse side.',
      ),
      (
        key: PulseTourTargets.quickAccess,
        title: 'Quick access',
        body:
            'Return here any time to replay this walkthrough or open your account tools.',
      ),
    ].where((step) => step.key.currentContext != null).toList();

    if (steps.isEmpty) return;

    final targets = <TargetFocus>[
      for (var index = 0; index < steps.length; index++)
        TargetFocus(
          identify: 'pulse-tour-$index',
          keyTarget: steps[index].key,
          shape: ShapeLightFocus.RRect,
          radius: 14,
          paddingFocus: 8,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.right,
              child: _TourMessage(
                title: steps[index].title,
                body: steps[index].body,
                position: index + 1,
                total: steps.length,
              ),
            ),
          ],
        ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF0B1020),
      opacityShadow: 0.78,
      paddingFocus: 8,
      textSkip: 'Skip tour',
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      onFinish: () => OnboardingService.instance.markTourCompleted(),
      onSkip: () {
        OnboardingService.instance.markTourCompleted();
        return true;
      },
    ).show(context: context, rootOverlay: true);
  }
}

class _TourMessage extends StatelessWidget {
  const _TourMessage({
    required this.title,
    required this.body,
    required this.position,
    required this.total,
  });

  final String title;
  final String body;
  final int position;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'STEP $position OF $total',
              style: const TextStyle(
                color: Color(0xFFD8B4FE),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.84),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tap anywhere to continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
