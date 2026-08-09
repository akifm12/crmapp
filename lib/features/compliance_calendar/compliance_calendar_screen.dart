import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/calendar_helper.dart';
import '../../core/theme.dart';
import '../../models/compliance_deadline.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/sector_filter_chip.dart';
import '../auth/auth_provider.dart';
import 'compliance_provider.dart';
import 'my_deadlines_tab.dart';
import 'set_deadline_sheet.dart';

class ComplianceCalendarScreen extends ConsumerWidget {
  const ComplianceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Compliance Calendar'),
          bottom: const TabBar(
            tabs: [Tab(text: 'General'), Tab(text: 'My Deadlines')],
          ),
        ),
        body: const TabBarView(
          children: [_GeneralCalendarTab(), MyDeadlinesTab()],
        ),
      ),
    );
  }
}

class _GeneralCalendarTab extends ConsumerWidget {
  const _GeneralCalendarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sector = ref.watch(selectedSectorProvider);
    final dataAsync = ref.watch(complianceCalendarProvider(sector));

    return dataAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(onRetry: () => ref.invalidate(complianceCalendarProvider(sector))),
      data: (data) => Column(
        children: [
          const SizedBox(height: 10),
          SectorFilterRow(
            sectors: data.sectors,
            selected: sector,
            onSelected: (value) => ref.read(selectedSectorProvider.notifier).state = value,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: data.deadlines.isEmpty
                ? const EmptyView(message: 'No deadlines for this sector yet.', icon: Icons.event_busy)
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(complianceCalendarProvider(sector)),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.deadlines.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _deadlineCard(context, ref, data.deadlines[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _deadlineCard(BuildContext context, WidgetRef ref, ComplianceDeadline deadline) {
    final myDeadline = deadline.myDeadline;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(deadline.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                CategoryBadge(label: deadline.category, colorKey: deadline.categoryColorKey),
              ],
            ),
            if (deadline.description != null) ...[
              const SizedBox(height: 6),
              Text(deadline.description!, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (deadline.authority != null)
                  Text(deadline.authority!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(deadline.recurrence, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 10),
            if (myDeadline != null)
              InkWell(
                onTap: () => showSetDeadlineSheet(context, deadline: deadline),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BadgeColors.fromTailwindClasses(myDeadline.badgeColor).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Your deadline: ${myDeadline.badgeText}',
                    style: TextStyle(
                      color: BadgeColors.fromTailwindClasses(myDeadline.badgeColor),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              TextButton.icon(
                onPressed: () => _onSetDeadline(context, ref, deadline),
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Set deadline'),
                style: TextButton.styleFrom(
                  foregroundColor: BrandColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            Row(
              children: [
                if (myDeadline != null)
                  TextButton.icon(
                    onPressed: () => addDeadlineToCalendar(
                      title: deadline.title,
                      description: myDeadline.notes ?? deadline.description,
                      dueDate: myDeadline.dueDate,
                    ),
                    icon: const Icon(Icons.event_available, size: 16),
                    label: const Text('Add to calendar'),
                    style: TextButton.styleFrom(
                      foregroundColor: BrandColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                if (deadline.sourceUrl != null)
                  TextButton(
                    onPressed: () => launchUrl(Uri.parse(deadline.sourceUrl!), mode: LaunchMode.externalApplication),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                    child: const Text('Source', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSetDeadline(BuildContext context, WidgetRef ref, ComplianceDeadline deadline) {
    if (!ref.read(authProvider).isLoggedIn) {
      context.push('/login');
      return;
    }
    showSetDeadlineSheet(context, deadline: deadline);
  }
}
