import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '/unification/components/success_payment/success_payment_widget.dart';

// Focus widget keys for this walkthrough
final columnB2b34h7p = GlobalKey();

/// Data
///
/// gfdfdfdf
List<TargetFocus> createWalkthroughTargets(BuildContext context) => [
      /// Step 1
      TargetFocus(
        keyTarget: columnB2b34h7p,
        enableOverlayTab: true,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        color: Colors.black,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, __) => SuccessPaymentWidget(),
          ),
        ],
      ),
    ];
