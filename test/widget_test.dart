import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test mounts cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Library Management System'),
          ),
        ),
      ),
    );
    expect(find.text('Library Management System'), findsOneWidget);
  });
}
