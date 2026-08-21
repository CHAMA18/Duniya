import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Initialise Firebase.
/// Web uses an in-memory Firestore cache so multiple app tabs can coexist
/// without competing for IndexedDB's exclusive persistence lock.
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

    // The web SDK requires exclusive IndexedDB access for persistent cache.
    // A user with another Pulse tab open would otherwise get a
    // failed-precondition warning and an implicit fallback to memory anyway.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
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
