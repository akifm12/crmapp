import 'package:flutter/material.dart';

import 'general_calendar_tab.dart';
import 'my_deadlines_tab.dart';

class ComplianceCalendarScreen extends StatelessWidget {
  const ComplianceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Compliance Calendar'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [Tab(text: 'Deadlines'), Tab(text: 'My Deadlines')],
          ),
        ),
        body: const TabBarView(
          children: [GeneralCalendarTab(), MyDeadlinesTab()],
        ),
      ),
    );
  }
}
