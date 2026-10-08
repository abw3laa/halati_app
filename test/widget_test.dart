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

    // Wait for SettingsService.load() without waiting for background update/network work.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(RootShell), findsOneWidget);
  });
}
