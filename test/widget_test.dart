import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:halati/main.dart';
import 'package:halati/services/settings_service.dart';
import 'package:halati/screens/root_shell.dart';

void main() {
  testWidgets('Halati app boots with its root shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsService()..load(),
        child: const HalatiApp(),
      ),
    );

    // SettingsService initializes asynchronously. Advance the fake clock in
    // small steps, but never use pumpAndSettle because RootShell starts
    // background update/network work after its first frame.
    for (var i = 0; i < 20 && find.byType(RootShell).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(find.byType(RootShell), findsOneWidget);
  });
}
