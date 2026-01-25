import 'package:flutter_test/flutter_test.dart';
import 'package:musically/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MusicallyApp());

    // Verify that the app launches
    expect(find.text('Musically'), findsOneWidget);
  });
}
