import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:halati/main.dart';
import 'package:halati/services/settings_service.dart';
import 'package:halati/screens/root_shell.dart';

void main() {
  testWidgets('Halati app boots with its root shell', (WidgetTester tester) async {
    final settings = SettingsService();
    await settings.load();

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsService>.value(
        value: settings,
        child: const HalatiApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(RootShell), findsOneWidget);
  });
}
