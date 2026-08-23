import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../base_auth_user_provider.dart';
import '../email_action_urls.dart';

export '../base_auth_user_provider.dart';

class MediTrackerFirebaseUser extends BaseAuthUser {
  MediTrackerFirebaseUser(this.user);
  User? user;
  bool get loggedIn => user != null;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: user?.uid,
        email: user?.email,
        displayName: user?.displayName,
        photoUrl: user?.photoURL,
        phoneNumber: user?.phoneNumber,
      );

  @override
  Future? delete() => user?.delete();

  @override
  Future? updateEmail(String email) async {
    try {
      await user?.updateEmail(email);
    } catch (_) {
      await user?.verifyBeforeUpdateEmail(email);
    }
  }

  @override
  Future? updatePassword(String newPassword) async {
    await user?.updatePassword(newPassword);
  }

  @override
  Future? sendEmailVerification() => user?.sendEmailVerification(
        // Route the verification link directly into the deployed app
        // (handleCodeInApp) — this bypasses the legacy custom action URL
        // (pharmaaid.page.link) in the Firebase email templates, which is
        // no longer an authorized domain and showed Firebase's
        // "domain is not authorized" error when clicked.
        // EmailActionHandler on /loginUni applies the oobCode in-app.
        ActionCodeSettings(
          url: emailVerificationUrl(),
          handleCodeInApp: true,
          androidPackageName: 'com.mycompany.meditrackerpro',
          androidInstallApp: true,
          iOSBundleId: 'com.stackone.pharmaaid',
        ),
      );

  @override
  bool get emailVerified {
    // Reloads the user when checking in order to get the most up to date
    // email verified status.
    final u = user;
    if (u != null && !u.emailVerified) {
      refreshUser();
    }
    return u?.emailVerified ?? false;
  }

  @override
  Future refreshUser() async {
    await FirebaseAuth.instance.currentUser
        ?.reload()
        .then((_) => user = FirebaseAuth.instance.currentUser);
  }

  static BaseAuthUser fromUserCredential(UserCredential userCredential) =>
      fromFirebaseUser(userCredential.user);
  static BaseAuthUser fromFirebaseUser(User? user) =>
      MediTrackerFirebaseUser(user);
}

Stream<BaseAuthUser> mediTrackerFirebaseUserStream() => FirebaseAuth.instance
        .authStateChanges()
        .debounce((user) => user == null && !loggedIn
            ? TimerStream(true, const Duration(seconds: 1))
            : Stream.value(user))
        .map<BaseAuthUser>(
      (user) {
        final authUser = MediTrackerFirebaseUser(user);
        currentUser = authUser;
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.setUserIdentifier(user?.uid ?? '');
        }
        return authUser;
      },
    );
