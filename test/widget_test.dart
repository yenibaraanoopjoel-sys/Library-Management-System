import 'package:flutter_test/flutter_test.dart';
import 'package:library_management_system/app/app.dart';

void main() {
  testWidgets('LibraryApp smoke test mounts correctly', (WidgetTester tester) async {
    // Basic smoke test confirming app widget mounts
    await tester.pumpWidget(const LibraryApp());
    expect(find.byType(LibraryApp), findsOneWidget);
  });
}
