import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../widgets/anim.dart';
import 'screening_demo.dart';

const _sentinelUrl = 'https://aml.bluearrow.ae';

Future<void> openSentinel() => launchUrl(Uri.parse(_sentinelUrl), mode: LaunchMode.externalApplication);

/// The hallmark tab: Blue Arrow's proprietary sanctions / PEP / adverse-media
/// screening engine, with an interactive screening simulation.
class SentinelScreen extends StatelessWidget {
  const SentinelScreen({super.key});

  static const _caps = <({IconData icon, String title, String text})>[
    (icon: Icons.gavel_outlined, title: 'Sanctions', text: 'UN, OFAC, EU and UAE local lists'),
    (icon: Icons.account_balance_outlined, title: 'PEP checks', text: 'Politically exposed persons & relatives'),
    (icon: Icons.newspaper_outlined, title: 'Adverse media', text: 'Reputational risk signals from the news'),
    (icon: Icons.spellcheck, title: 'Fuzzy matching', text: 'Catches transliteration & spelling variants'),
    (icon: Icons.autorenew, title: 'Ongoing monitoring', text: 'Re-screens clients, not only at onboarding'),
    (icon: Icons.fact_check_outlined, title: 'Audit trail', text: 'Every review decision logged for regulators'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _Hero()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Try a screening', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('See how Sentinel checks a name in seconds.', style: TextStyle(color: context.muted)),
                  const SizedBox(height: 12),
                  const ScreeningDemo(),
                  const SizedBox(height: 28),
                  Text('What Sentinel does', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              itemCount: _caps.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 128,
              ),
              itemBuilder: (context, i) => FadeSlideIn(
                index: i,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_caps[i].icon, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 8),
                        Text(_caps[i].title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(_caps[i].text, style: TextStyle(fontSize: 12, color: context.muted)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ready for the real thing?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Sentinel runs standalone at aml.bluearrow.ae, or built into our KYC portal.',
                      style: TextStyle(color: context.muted)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: openSentinel,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Open Sentinel'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/contact',
                          extra: "I'd like a demo of Blue Arrow Sentinel (AML screening software)."),
                      icon: const Icon(Icons.event_available_outlined, size: 18),
                      label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Book a demo')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatefulWidget {
  const _Hero();

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF06122E), Color(0xFF12307A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BrandColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('BY BLUE ARROW',
                      style: TextStyle(color: BrandColors.gold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 12),
                const Text('Sentinel',
                    style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, height: 1)),
                const SizedBox(height: 8),
                Text('Know exactly who you are doing business with.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, height: 1.35)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in ['UN', 'OFAC', 'EU', 'UAE', 'PEP', 'Media']) _chip(t),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            height: 120,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(painter: _RadarPainter(_c.value)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

class _RadarPainter extends CustomPainter {
  final double t;
  _RadarPainter(this.t);

  static const _blips = [
    (0.55, 0.9),
    (2.4, 0.6),
    (4.1, 0.75),
    (5.3, 0.4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.22);
    for (final f in [1.0, 0.66, 0.33]) {
      canvas.drawCircle(c, r * f, line);
    }
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), line);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), line);

    final angle = t * 2 * math.pi;
    final sweep = Paint()
      ..shader = SweepGradient(
        colors: [Colors.transparent, const Color(0xFF6EA0FF).withValues(alpha: 0.65)],
        stops: const [0.75, 1],
        transform: GradientRotation(angle - math.pi / 2),
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, sweep);

    for (final (a, d) in _blips) {
      // brighten a blip as the sweep passes over it
      var diff = (angle - a) % (2 * math.pi);
      if (diff < 0) diff += 2 * math.pi;
      final glow = (1 - diff / (math.pi * 1.2)).clamp(0.0, 1.0);
      final p = c + Offset(math.cos(a - math.pi / 2), math.sin(a - math.pi / 2)) * (r * d);
      canvas.drawCircle(p, 3 + glow * 2, Paint()..color = const Color(0xFFFFC857).withValues(alpha: 0.25 + glow * 0.75));
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.t != t;
}

/// Small reusable promo card used on Home and in recommendations.
class SentinelPromoCard extends StatelessWidget {
  final VoidCallback onTap;
  final String headline;
  const SentinelPromoCard({super.key, required this.onTap, this.headline = 'Screen anyone in seconds'});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06122E), Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SENTINEL',
                      style: TextStyle(color: BrandColors.gold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                  const SizedBox(height: 4),
                  Text(headline, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Sanctions, PEP and adverse media — try it live.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.radar, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }
}
