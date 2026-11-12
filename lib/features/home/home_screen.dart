import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/user_prefs.dart';
import '../../models/compliance_deadline.dart';
import '../../widgets/anim.dart';
import '../../widgets/category_badge.dart';
import '../auth/auth_provider.dart';
import '../compliance_calendar/compliance_provider.dart';
import '../compliance_calendar/deadline_utils.dart';
import '../sentinel/sentinel_screen.dart';
import 'home_provider.dart';

/// Tab indexes in AppShell.
const kTabCalendar = 1;
const kTabSentinel = 2;
const kTabTools = 3;

class HomeScreen extends ConsumerWidget {
  final void Function(int tab) onOpenTab;
  const HomeScreen({super.key, required this.onOpenTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPrefsProvider);
    final user = ref.watch(authProvider).user;
    final calAsync = ref.watch(complianceCalendarProvider(prefs.sector));
    final homeAsync = ref.watch(homeProvider);

    final deadlines = calAsync.valueOrNull?.deadlines ?? const <ComplianceDeadline>[];
    final dated = deadlines.where((d) => d.nextDueDate != null).toList()
      ..sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
    final pending = dated.where((d) => !prefs.doneKeys.contains(doneKey(d))).toList();
    final next = pending.isEmpty ? null : pending.first;
    final doneCount = dated.length - pending.length;
    final dueSoon = pending.where((d) => daysUntil(d.nextDueDate!) <= 30).length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(complianceCalendarProvider(prefs.sector));
          ref.invalidate(homeProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Header(name: user?.name, sector: prefs.sector)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FadeSlideIn(
                    child: _NextDeadline(
                      loading: calAsync.isLoading && deadlines.isEmpty,
                      next: next,
                      doneCount: doneCount,
                      total: dated.length,
                      dueSoon: dueSoon,
                      onTap: () => onOpenTab(kTabCalendar),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(index: 1, child: SentinelPromoCard(onTap: () => onOpenTab(kTabSentinel))),
                  const SizedBox(height: 22),
                  _title(context, 'Quick actions'),
                  const SizedBox(height: 10),
                  FadeSlideIn(index: 2, child: _quickActions(context, prefs)),
                  const SizedBox(height: 24),
                  _title(context, 'Latest updates', onAll: () => context.push('/news')),
                  const SizedBox(height: 10),
                  ...homeAsync.when(
                    loading: () => [const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))],
                    error: (_, _) => [Text('News unavailable offline.', style: TextStyle(color: context.muted))],
                    data: (d) => [
                      for (final n in d.news)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              title: Text(n.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: CategoryBadge(label: n.categoryLabel, colorKey: n.categoryColorKey),
                                ),
                              ),
                              onTap: () => context.push('/news/${n.id}'),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _contactCta(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context, String t, {VoidCallback? onAll}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          if (onAll != null) TextButton(onPressed: onAll, child: const Text('See all')),
        ],
      );

  Widget _quickActions(BuildContext context, UserPrefs prefs) {
    final items = <({IconData icon, String label, String sub, VoidCallback onTap, Color color})>[
      (
        icon: Icons.health_and_safety_outlined,
        label: 'Health check',
        sub: prefs.healthScore == null ? '2-minute quiz' : 'Last score ${prefs.healthScore}',
        onTap: () => context.push('/health-check'),
        color: BrandColors.ok,
      ),
      (
        icon: Icons.alt_route,
        label: 'Find a service',
        sub: '3 quick taps',
        onTap: () => context.push('/service-finder'),
        color: BrandColors.primaryLight,
      ),
      (
        icon: Icons.speed,
        label: 'Risk rating',
        sub: 'Score a customer',
        onTap: () => context.push('/tools/risk'),
        color: BrandColors.warn,
      ),
      (
        icon: Icons.timer_outlined,
        label: 'goAML deadline',
        sub: 'When must I file?',
        onTap: () => context.push('/tools/goaml'),
        color: BrandColors.danger,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        for (final a in items)
          Pressable(
            onTap: a.onTap,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: a.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(11)),
                      child: Icon(a.icon, color: a.color, size: 20),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(a.sub, style: TextStyle(fontSize: 12, color: context.muted)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _contactCta(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Expanded(
              child: Text('Need a human? Talk to our compliance team.', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            const SizedBox(width: 10),
            FilledButton(onPressed: () => context.push('/contact'), child: const Text('Contact')),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? name;
  final String? sector;
  const _Header({this.name, this.sector});

  String get _greeting {
    final h = DateTime.now().hour;
    return h < 12 ? 'Good morning' : (h < 18 ? 'Good afternoon' : 'Good evening');
  }

  @override
  Widget build(BuildContext context) {
    final first = (name ?? '').trim().split(' ').first;
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B1B4D), BrandColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(first.isEmpty ? _greeting : '$_greeting, $first',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('UAE AML & regulatory compliance, made simple.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 14)),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => context.push('/sector'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(kSectors[sector]?.icon ?? Icons.public, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(kSectors[sector]?.short ?? 'All sectors',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more, size: 16, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextDeadline extends StatelessWidget {
  final bool loading;
  final ComplianceDeadline? next;
  final int doneCount, total, dueSoon;
  final VoidCallback onTap;

  const _NextDeadline({
    required this.loading,
    required this.next,
    required this.doneCount,
    required this.total,
    required this.dueSoon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Card(child: SizedBox(height: 130, child: Center(child: CircularProgressIndicator())));
    }
    final due = next?.nextDueDate;
    final days = due == null ? null : daysUntil(due);
    final color = days == null ? BrandColors.ok : urgencyColor(days);

    return Pressable(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              ProgressRing(
                value: total == 0 ? 0.0 : doneCount / total,
                size: 78,
                stroke: 9,
                color: color,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(days == null ? '✓' : (days < 0 ? '!' : '$days'),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
                    if (days != null && days >= 0) Text('days', style: TextStyle(fontSize: 10, color: context.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(next == null ? 'You are all caught up' : 'NEXT DEADLINE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: context.muted)),
                    const SizedBox(height: 4),
                    Text(next?.title ?? 'No upcoming deadlines for your sector.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, height: 1.2)),
                    const SizedBox(height: 6),
                    Text(
                      next == null
                          ? '$doneCount of $total completed'
                          : '${dueText(days!)} · $dueSoon due within 30 days · $doneCount/$total done',
                      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
