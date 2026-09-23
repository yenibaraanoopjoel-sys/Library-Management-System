import 'package:flutter/material.dart';
import 'app/app.dart';
import 'services/firebase/firebase_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase across supported platforms
  await FirebaseInitializer.init();

  runApp(const LibraryApp());
}
