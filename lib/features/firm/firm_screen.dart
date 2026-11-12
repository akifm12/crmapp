import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/firm.dart';
import '../../core/theme.dart';
import '../../widgets/anim.dart';
import '../../widgets/firm_widgets.dart';
import '../home/home_provider.dart';
import '../sentinel/sentinel_screen.dart';

/// The "Blue Arrow" tab: who we are, what we do, what we build, how to reach us.
class FirmScreen extends ConsumerWidget {
  final void Function(int tab) onOpenTab;
  const FirmScreen({super.key, required this.onOpenTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(homeProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _hero(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const FadeSlideIn(child: FirmStats()),
                  const SizedBox(height: 16),
                  const FadeSlideIn(index: 1, child: ContactButtons()),
                  const SizedBox(height: 26),
                  const SectionTitle('Who we are'),
                  const SizedBox(height: 10),
                  Text(
                    'Blue Arrow Management Consultants is a UAE-based AML and regulatory compliance consultancy, helping '
                    'Designated Non-Financial Businesses and Professions (DNFBPs) — bullion dealers, real estate brokers, '
                    'company service providers and accounting firms — build and run effective AML/CFT compliance programs.',
                    style: const TextStyle(height: 1.5, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We're also a technology company. We design and build our own software, including the RegTech platform "
                    'behind our compliance service, and take on custom software and mobile app development for clients.',
                    style: TextStyle(height: 1.5, fontSize: 15, color: context.muted),
                  ),
                  const SizedBox(height: 26),
                  const SectionTitle('What we do', subtitle: 'Compliance advisory by sector'),
                  const SizedBox(height: 12),
                  ...home.when(
                    loading: () => [const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))],
                    error: (_, _) => [Text('Services are unavailable offline.', style: TextStyle(color: context.muted))],
                    data: (d) => [
                      ServicesStrip(services: d.services),
                      const SizedBox(height: 26),
                      const SectionTitle('Built by us', subtitle: 'Our own software — use it with or without our advice'),
                      const SizedBox(height: 12),
                      TechStrip(tiles: d.techServices),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SentinelPromoCard(headline: 'Meet Sentinel', onTap: () => onOpenTab(2)),
                  const SizedBox(height: 26),
                  const SectionTitle('Why Blue Arrow'),
                  const SizedBox(height: 12),
                  const WhyUs(),
                  const SizedBox(height: 18),
                  const SectionTitle('Visit or reach us'),
                  const SizedBox(height: 12),
                  const OfficeCard(),
                  const SizedBox(height: 18),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.login),
                      title: const Text('Already a client?', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Log in to your Blue Arrow portal'),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => launchUrl(Uri.parse('https://bluearrow.ae/login'), mode: LaunchMode.externalApplication),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 12, 26),
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
          Row(
            children: [
              Image.asset('assets/splash/splash_logo.png', height: 40),
              const Spacer(),
              IconButton(
                tooltip: 'Account & settings',
                onPressed: () => context.push('/me'),
                icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BLUE ARROW',
                    style: TextStyle(color: BrandColors.gold, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 12)),
                const SizedBox(height: 4),
                const Text('Management Consultants',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.1)),
                const SizedBox(height: 10),
                Text(Firm.tagline, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
