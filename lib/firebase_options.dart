import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration options for each platform.
/// 
/// To get the web appId and messagingSenderId:
/// 1. Go to Firebase Console → Project Settings → General
/// 2. Scroll to "Your apps" → Click "Add app" → Web (</> icon)
/// 3. Register the app and copy the config values
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ─── Android (auto-read from google-services.json, but we define fallback) ───
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVd9O1Cxyppg691JCYGb7PtZMkDsdCVBk',
    appId: '1:387483385056:android:bd8bb2e62c13270534e485',
    messagingSenderId: '387483385056',
    projectId: 'ac-diary-aa61b',
    storageBucket: 'ac-diary-aa61b.firebasestorage.app',
  );

  // ─── Web ───
  // These values come from the same Firebase project.
  // The apiKey and projectId are shared; appId is web-specific.
  // Go to Firebase Console → Project Settings → Your apps → Web app
  // to find the correct appId for web.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDVd9O1Cxyppg691JCYGb7PtZMkDsdCVBk',
    appId: '1:387483385056:web:47de7d2219f1987634e485',  // ← UPDATE THIS after adding web app in Firebase
    messagingSenderId: '387483385056',
    projectId: 'ac-diary-aa61b',
    storageBucket: 'ac-diary-aa61b.firebasestorage.app',
    authDomain: 'ac-diary-aa61b.firebaseapp.com',
  );
}
