import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/account/account_screen.dart';
import '../features/compliance_calendar/compliance_calendar_screen.dart';
import '../features/home/home_screen.dart';
import '../features/sentinel/sentinel_screen.dart';
import '../features/tools/tools_screen.dart';

class AppShell extends StatefulWidget {
  final int initialTab;
  const AppShell({super.key, this.initialTab = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialTab.clamp(0, 4);

  @override
  void didUpdateWidget(AppShell old) {
    super.didUpdateWidget(old);
    if (old.initialTab != widget.initialTab) _index = widget.initialTab.clamp(0, 4);
  }

  late final List<Widget> _screens = [
    HomeScreen(onOpenTab: _go),
    const ComplianceCalendarScreen(),
    const SentinelScreen(),
    const ToolsScreen(),
    const AccountScreen(),
  ];

  void _go(int i) {
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Calendar'),
          NavigationDestination(
              icon: Icon(Icons.radar_outlined), selectedIcon: Icon(Icons.radar), label: 'Sentinel'),
          NavigationDestination(
              icon: Icon(Icons.dashboard_customize_outlined),
              selectedIcon: Icon(Icons.dashboard_customize),
              label: 'Tools'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
