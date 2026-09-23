import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Handles Firebase app initialization for all supported platforms with graceful error handling
class FirebaseInitializer {
  static bool _isInitialized = false;
  static String? _initError;

  static bool get isInitialized => _isInitialized;
  static String? get initError => _initError;

  static Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return true;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      if (kDebugMode) {
        print('✅ Firebase successfully initialized for project: ${DefaultFirebaseOptions.projectId}');
      }
      return true;
    } catch (e, stack) {
      _initError = e.toString();
      if (kDebugMode) {
        print('⚠️ Firebase initialization warning: $e');
        print(stack);
      }
      // Return false to allow application to proceed gracefully
      return false;
    }
  }
}
