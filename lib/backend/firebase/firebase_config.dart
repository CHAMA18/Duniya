import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Initialise Firebase with an on-device Firestore cache.
///
/// Web persists Firestore data in IndexedDB so cached reads and pending writes
/// survive reloads. The installed FlutterFire version uses the SDK's legacy
/// tab manager; if a second legacy tab cannot acquire the cache, query
/// fallbacks keep the UI usable instead of leaving it on a loading state.
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

    // Persist queries and writes across browser restarts. This enables cached
    // reads and Firestore's built-in queued-write synchronization offline.
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
