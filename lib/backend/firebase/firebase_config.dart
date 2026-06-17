import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Initialise Firebase.
/// Firestore offline persistence is enabled via Settings.persistenceEnabled
/// (the modern API). We do NOT call enablePersistence() separately because
/// that causes "SDK cache is already specified" errors on web.
Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBq" + "n_Bwk4xPtBVW-2VlVNBRFaxtyquP8ak",
            authDomain: "pharmacy-system-2fb27.firebaseapp.com",
            projectId: "pharmacy-system-2fb27",
            storageBucket: "pharmacy-system-2fb27.appspot.com",
            messagingSenderId: "383121081031",
            appId: "1:383121081031:web:aa20a504fbfc44f934b4e2",
            measurementId: "G-WK3493Q779"));

    // Enable offline persistence via Settings (modern API).
    // This is all that's needed — no separate enablePersistence() call.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 100 * 1024 * 1024,
    );
  } else {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 100 * 1024 * 1024,
    );
  }
}
