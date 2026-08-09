import 'package:flutter/material.dart';

import '../features/account/account_screen.dart';
import '../features/compliance_calendar/compliance_calendar_screen.dart';
import '../features/home/home_screen.dart';
import '../features/news/news_list_screen.dart';
import '../features/resources/resources_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    ComplianceCalendarScreen(),
    ResourcesScreen(),
    NewsListScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined), activeIcon: Icon(Icons.event), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Resources'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
