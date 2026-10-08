import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:halati/main.dart';
import 'package:halati/services/settings_service.dart';

void main() {
  testWidgets('Halati app boots with its root shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsService()..load(),
        child: const HalatiApp(),
      ),
    );

    // Allow SettingsService.load() and the first frame to settle.
    await tester.pumpAndSettle();

    expect(find.text('Halati'), findsOneWidget);
  });
}
