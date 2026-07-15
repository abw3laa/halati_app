import 'package:flutter/material.dart';

import '../services/update_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/update_dialog.dart';
import 'updates_screen.dart';
import 'download_screen.dart';
import 'settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _screens = const [
    UpdatesScreen(),
    DownloadScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Silent, rate-limited (see UpdateService) check on every app start.
    // Never blocks first paint and fails quietly if offline.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    final result = await UpdateService.instance.checkForUpdate();
    if (!mounted) return;
    await showUpdateDialogIfNeeded(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: HalatiBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
