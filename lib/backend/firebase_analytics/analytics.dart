import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../auth/firebase_auth/auth_util.dart';
import 'package:firebase_auth/firebase_auth.dart';

const kMaxEventNameLength = 40;
const kMaxParameterLength = 100;

void _writeAuditLog(String eventName, Map<String, Object> parameters) {
  final uid = currentUserUid;
  if (uid.isEmpty) return;

  final scopeId = currentUserDocument?.ownerRef?.path ?? 'User/$uid';
  final payload = <String, Object?>{
    'actorId': uid,
    'actorEmail': currentUserEmail,
    'actorName': currentUserDisplayName,
    'scopeId': scopeId,
    'eventName': eventName,
    'parameters': parameters,
    'createdAt': FieldValue.serverTimestamp(),
    'clientCreatedAt': Timestamp.now(),
  };

  // Audit logging must never block or break the user action that generated it.
  unawaited(
    FirebaseFirestore.instance.collection('AuditLogs').add(payload).then<void>(
          (_) {},
          onError: (_) {},
        ),
  );
}

void logFirebaseEvent(String eventName, {Map<String?, dynamic>? parameters}) {
  // https://firebase.google.com/docs/reference/cpp/group/event-names
  assert(eventName.length <= kMaxEventNameLength);

  parameters ??= {};
  parameters.putIfAbsent(
      'user', () => currentUserUid.isEmpty ? 'unset' : currentUserUid);
  parameters.removeWhere((k, v) => k == null || v == null);
  final params = parameters.map((k, v) => MapEntry(k!, v));

  // FB Analytics allows num values but others need to be converted to strings
  // and cannot be more than 100 characters.
  for (final entry in params.entries) {
    if (entry.value is! num) {
      var valStr = entry.value.toString();
      if (valStr.length > kMaxParameterLength) {
        valStr = valStr.substring(0, min(valStr.length, kMaxParameterLength));
      }
      params[entry.key] = valStr;
    }
  }

  FirebaseAnalytics.instance
      .logEvent(name: eventName, parameters: params.cast<String, Object>());
  _writeAuditLog(eventName, params.cast<String, Object>());
}

void logFirebaseAuthEvent(User? user, String method) {
  final isSignup = user!.metadata.creationTime == user.metadata.lastSignInTime;
  final authEvent = isSignup ? 'sign_up' : 'login';
  logFirebaseEvent(authEvent, parameters: {'method': method});
}
