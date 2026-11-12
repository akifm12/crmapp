import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/calendar_helper.dart';
import '../../core/theme.dart';
import '../../core/user_prefs.dart';
import '../../models/compliance_deadline.dart';
import '../../widgets/anim.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/sector_filter_chip.dart';
import '../auth/auth_provider.dart';
import 'compliance_provider.dart';
import 'deadline_utils.dart';
import 'set_deadline_sheet.dart';

class GeneralCalendarTab extends ConsumerStatefulWidget {
  const GeneralCalendarTab({super.key});

  @override
  ConsumerState<GeneralCalendarTab> createState() => _GeneralCalendarTabState();
}

class _GeneralCalendarTabState extends ConsumerState<GeneralCalendarTab> {
  bool _monthView = false;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final sector = ref.watch(selectedSectorProvider);
    final done = ref.watch(userPrefsProvider.select((p) => p.doneKeys));
    final dataAsync = ref.watch(complianceCalendarProvider(sector));

    return dataAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(onRetry: () => ref.invalidate(complianceCalendarProvider(sector))),
      data: (data) {
        final dated = data.deadlines.where((d) => d.nextDueDate != null).toList()
          ..sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
        final undated = data.deadlines.where((d) => d.nextDueDate == null).toList();
        final doneCount = dated.where((d) => done.contains(doneKey(d))).length;

        return Column(
          children: [
            const SizedBox(height: 10),
            SectorFilterRow(
              sectors: data.sectors,
              selected: sector,
              onSelected: (v) => ref.read(selectedSectorProvider.notifier).state = v,
            ),
            const SizedBox(height: 10),
            _summary(context, doneCount, dated.length),
            Expanded(
              child: data.deadlines.isEmpty
                  ? const EmptyView(message: 'No deadlines for this sector yet.', icon: Icons.event_busy)
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(complianceCalendarProvider(sector)),
                      child: _monthView
                          ? _monthBody(context, dated, done)
                          : _timelineBody(context, dated, undated, done),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _summary(BuildContext context, int done, int total) {
    final pct = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ProgressRing(
            value: pct,
            size: 46,
            stroke: 6,
            color: BrandColors.ok,
            child: Text('${(pct * 100).round()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$done of $total deadlines done', style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('Tick a deadline when you have filed it.', style: TextStyle(fontSize: 12, color: context.muted)),
              ],
            ),
          ),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            segments: const [
              ButtonSegment(value: false, icon: Icon(Icons.view_agenda_outlined, size: 18)),
              ButtonSegment(value: true, icon: Icon(Icons.calendar_month_outlined, size: 18)),
            ],
            selected: {_monthView},
            onSelectionChanged: (s) => setState(() => _monthView = s.first),
          ),
        ],
      ),
    );
  }

  // ── Timeline ────────────────────────────────────────────────────────────

  Widget _timelineBody(BuildContext context, List<ComplianceDeadline> dated, List<ComplianceDeadline> undated, Set<String> done) {
    final groups = <String, List<ComplianceDeadline>>{
      'Overdue': [],
      'This week': [],
      'This month': [],
      'Later': [],
      'Completed': [],
    };
    for (final d in dated) {
      if (done.contains(doneKey(d))) {
        groups['Completed']!.add(d);
        continue;
      }
      final days = daysUntil(d.nextDueDate!);
      groups[days < 0 ? 'Overdue' : days <= 7 ? 'This week' : days <= 30 ? 'This month' : 'Later']!.add(d);
    }
    if (undated.isNotEmpty) groups['Later']!.addAll(undated);

    final children = <Widget>[];
    var i = 0;
    for (final e in groups.entries) {
      if (e.value.isEmpty) continue;
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
        child: Text(e.key.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: e.key == 'Overdue' ? BrandColors.danger : context.muted,
            )),
      ));
      for (final d in e.value) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FadeSlideIn(index: i++ < 6 ? i : 6, child: DeadlineCard(deadline: d, done: done.contains(doneKey(d)))),
        ));
      }
    }
    return ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: children);
  }

  // ── Month grid ──────────────────────────────────────────────────────────

  Widget _monthBody(BuildContext context, List<ComplianceDeadline> dated, Set<String> done) {
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final lead = first.weekday % 7; // Sunday-first grid
    final byDay = <int, List<ComplianceDeadline>>{};
    for (final d in dated) {
      final due = d.nextDueDate!;
      if (due.year == _month.year && due.month == _month.month) byDay.putIfAbsent(due.day, () => []).add(d);
    }
    final today = dateOnly(DateTime.now());
    final selected = _selectedDay;
    final selectedItems = selected == null ? <ComplianceDeadline>[] : (byDay[selected.day] ?? []);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                _month = DateTime(_month.year, _month.month - 1);
                _selectedDay = null;
              }),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(DateFormat('MMMM yyyy').format(_month),
                  textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            IconButton(
              onPressed: () => setState(() {
                _month = DateTime(_month.year, _month.month + 1);
                _selectedDay = null;
              }),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Row(
          children: [
            for (final w in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
              Expanded(child: Center(child: Text(w, style: TextStyle(color: context.muted, fontWeight: FontWeight.w700)))),
          ],
        ),
        const SizedBox(height: 6),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lead + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 48),
          itemBuilder: (context, idx) {
            if (idx < lead) return const SizedBox();
            final day = idx - lead + 1;
            final date = DateTime(_month.year, _month.month, day);
            final items = byDay[day] ?? const <ComplianceDeadline>[];
            final isToday = date == today;
            final isSel = selected != null && date == selected;
            final pendingCount = items.where((d) => !done.contains(doneKey(d))).length;
            final dot = items.isEmpty
                ? null
                : pendingCount == 0
                    ? BrandColors.ok
                    : urgencyColor(daysUntil(date));
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: items.isEmpty
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedDay = date);
                    },
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSel ? BrandColors.primary : null,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSel ? Border.all(color: BrandColors.primary) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$day', style: TextStyle(fontWeight: FontWeight.w700, color: isSel ? Colors.white : null)),
                    const SizedBox(height: 3),
                    if (dot != null)
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: isSel ? Colors.white : dot, shape: BoxShape.circle))
                    else
                      const SizedBox(height: 6),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        if (selected == null)
          Text('Tap a day with a dot to see what is due.', textAlign: TextAlign.center, style: TextStyle(color: context.muted))
        else
          for (final d in selectedItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DeadlineCard(deadline: d, done: done.contains(doneKey(d))),
            ),
      ],
    );
  }
}

class DeadlineCard extends ConsumerStatefulWidget {
  final ComplianceDeadline deadline;
  final bool done;
  const DeadlineCard({super.key, required this.deadline, required this.done});

  @override
  ConsumerState<DeadlineCard> createState() => _DeadlineCardState();
}

class _DeadlineCardState extends ConsumerState<DeadlineCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.deadline;
    final due = d.nextDueDate;
    final days = due == null ? null : daysUntil(due);
    final color = widget.done ? BrandColors.ok : (days == null ? context.muted : urgencyColor(days));
    final my = d.myDeadline;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref.read(userPrefsProvider.notifier).toggleDone(doneKey(d));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.done ? BrandColors.ok : Colors.transparent,
                          border: Border.all(color: widget.done ? BrandColors.ok : context.muted, width: 2),
                        ),
                        child: widget.done ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: widget.done ? TextDecoration.lineThrough : null,
                                color: widget.done ? context.muted : null,
                              )),
                          const SizedBox(height: 3),
                          Text(
                            widget.done
                                ? 'Completed'
                                : due == null
                                    ? d.recurrence
                                    : '${DateFormat('d MMM yyyy').format(due)} · ${dueText(days!)}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                          ),
                        ],
                      ),
                    ),
                    Icon(_open ? Icons.expand_less : Icons.expand_more, color: context.muted),
                  ],
                ),
                if (_open) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CategoryBadge(label: d.category, colorKey: d.categoryColorKey),
                      if (d.authority != null) Text(d.authority!, style: TextStyle(fontSize: 12, color: context.muted)),
                      Text(d.recurrence, style: TextStyle(fontSize: 12, color: context.muted)),
                    ],
                  ),
                  if (d.description != null) ...[
                    const SizedBox(height: 8),
                    Text(d.description!, style: const TextStyle(fontSize: 13, height: 1.35)),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: [
                      if (my != null)
                        TextButton.icon(
                          onPressed: () => addDeadlineToCalendar(
                            title: d.title,
                            description: my.notes ?? d.description,
                            dueDate: my.dueDate,
                          ),
                          icon: const Icon(Icons.event_available, size: 16),
                          label: const Text('Add to calendar'),
                        )
                      else if (due != null)
                        TextButton.icon(
                          onPressed: () => addDeadlineToCalendar(title: d.title, description: d.description, dueDate: due),
                          icon: const Icon(Icons.event_available, size: 16),
                          label: const Text('Add to calendar'),
                        ),
                      TextButton.icon(
                        onPressed: () {
                          if (!ref.read(authProvider).isLoggedIn) {
                            context.push('/login');
                            return;
                          }
                          showSetDeadlineSheet(context, deadline: d);
                        },
                        icon: Icon(my == null ? Icons.edit_calendar_outlined : Icons.edit_outlined, size: 16),
                        label: Text(my == null ? 'Set my own date' : 'Your date: ${my.badgeText}'),
                      ),
                      if (d.sourceUrl != null)
                        TextButton.icon(
                          onPressed: () => launchUrl(Uri.parse(d.sourceUrl!), mode: LaunchMode.externalApplication),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Source'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
