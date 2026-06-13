import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
  } else {
    await Firebase.initializeApp();
  }
}
