// File generated / configured for Firebase project: library-management-syste-d58c1
// Default [FirebaseOptions] for use with your Firebase apps.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static const String projectId = 'library-management-syste-d58c1';
  static const String storageBucket = 'library-management-syste-d58c1.appspot.com';
  static const String authDomain = 'library-management-syste-d58c1.firebaseapp.com';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoWebApiKeyPlaceholder_LibSys2026',
    appId: '1:1029384756:web:d58c199002238471',
    messagingSenderId: '1029384756',
    projectId: projectId,
    authDomain: authDomain,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoAndroidApiKeyPlaceholder_LibSys2026',
    appId: '1:1029384756:android:d58c199002238472',
    messagingSenderId: '1029384756',
    projectId: projectId,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoIosApiKeyPlaceholder_LibSys2026',
    appId: '1:1029384756:ios:d58c199002238473',
    messagingSenderId: '1029384756',
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: 'com.library.management.system',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoWindowsApiKeyPlaceholder_LibSys2026',
    appId: '1:1029384756:windows:d58c199002238474',
    messagingSenderId: '1029384756',
    projectId: projectId,
    storageBucket: storageBucket,
  );
}
