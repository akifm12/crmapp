import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/firm.dart';
import '../core/theme.dart';
import '../models/service_tile.dart';
import '../models/tech_service_tile.dart';
import 'anim.dart';

Future<void> _open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

/// Credentials strip — the same claims bluearrow.ae makes on its About page.
class FirmStats extends StatelessWidget {
  const FirmStats({super.key});

  @override
  Widget build(BuildContext context) {
    const stats = [('25+', 'Years combined\nexperience'), ('5', 'DNFBP sectors\nserved'), ('100%', 'Compliance\nrate')];
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Column(
                  children: [
                    Text(stats[i].$1,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 2),
                    Text(stats[i].$2, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, height: 1.25, color: context.muted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Primary calls to action: consultation + call.
class ContactButtons extends StatelessWidget {
  const ContactButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/contact', extra: "I'd like a free consultation."),
            icon: const Icon(Icons.support_agent, size: 18),
            label: const Text('Free consultation'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () => _open('tel:${Firm.phoneDial}'),
            icon: const Icon(Icons.call_outlined, size: 18),
            label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Call')),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAll;
  const SectionTitle(this.title, {super.key, this.subtitle, this.onAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              if (subtitle != null) Text(subtitle!, style: TextStyle(color: context.muted, fontSize: 13)),
            ],
          ),
        ),
        if (onAll != null) TextButton(onPressed: onAll, child: const Text('See all')),
      ],
    );
  }
}

/// Horizontal strip of sector services; tap for details + enquiry.
class ServicesStrip extends StatelessWidget {
  final List<ServiceTile> services;
  const ServicesStrip({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final s = services[i];
          return Pressable(
            onTap: () => showServiceSheet(context, s),
            child: SizedBox(
              width: 220,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.icon, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 8),
                      Text(s.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(s.summary,
                            maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, height: 1.3, color: context.muted)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void showServiceSheet(BuildContext context, ServiceTile s) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(s.icon, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(child: Text(s.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          Text(s.summary, style: const TextStyle(fontSize: 15, height: 1.45)),
          const SizedBox(height: 12),
          if (s.portalBacked)
            _pill(ctx, Icons.verified_outlined, 'Delivered with the Blue Arrow KYC portal and Sentinel screening')
          else
            _pill(ctx, Icons.record_voice_over_outlined, 'Advisory service'),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/contact', extra: "I'm interested in your ${s.title} service.");
              },
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Enquire about this service'),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _pill(BuildContext context, IconData icon, String text) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrandColors.primary.withValues(alpha: context.isDark ? 0.25 : 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );

/// "Built by us" — the firm's own software.
class TechStrip extends StatelessWidget {
  final List<TechServiceTile> tiles;
  const TechStrip({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: tiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final t = tiles[i];
          return Pressable(
            onTap: () => showTechSheet(context, t),
            child: SizedBox(
              width: 240,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(t.icon, style: const TextStyle(fontSize: 24)),
                          const Spacer(),
                          Text(t.badge.toUpperCase(),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: BrandColors.gold, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(t.summary,
                            maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, height: 1.3, color: context.muted)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void showTechSheet(BuildContext context, TechServiceTile t) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (ctx, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              Text(t.icon, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(child: Text(t.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          Text(t.summary, style: const TextStyle(fontSize: 15, height: 1.45)),
          const SizedBox(height: 14),
          for (final f in t.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 18, color: BrandColors.ok),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f, style: const TextStyle(fontSize: 14, height: 1.35))),
                ],
              ),
            ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/contact', extra: "I'd like a demo of: ${t.title}.");
            },
            icon: const Icon(Icons.play_circle_outline, size: 18),
            label: const Text('Request a demo'),
          ),
        ],
      ),
    ),
  );
}

/// Why clients choose Blue Arrow (from the website's About copy).
class WhyUs extends StatelessWidget {
  const WhyUs({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.workspace_premium_outlined, 'Certified experts', 'Our consultants hold recognised regulatory compliance certifications.'),
      (Icons.account_balance_outlined, 'Regulator-aligned', 'We work to Ministry of Economy guidance and FIU goAML reporting obligations.'),
      (Icons.domain_verification_outlined, 'DNFBP specialists', 'Bullion, real estate, company services and accounting — five sectors served.'),
      (Icons.memory_outlined, 'Our own technology', 'We build and run the RegTech platform behind our service, so you get software and advice together.'),
    ];
    return Column(
      children: [
        for (final it in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: BrandColors.primary.withValues(alpha: context.isDark ? 0.3 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(it.$1, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(it.$3, style: TextStyle(fontSize: 13, height: 1.35, color: context.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Where to find us + every way to reach us.
class OfficeCard extends StatelessWidget {
  const OfficeCard({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String label, String value, VoidCallback onTap) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 11, color: context.muted, fontWeight: FontWeight.w700)),
                      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.muted),
              ],
            ),
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        child: Column(
          children: [
            row(Icons.place_outlined, 'OFFICE', Firm.address, () => _open(Firm.mapsUrl)),
            Divider(height: 1, color: context.hairline),
            row(Icons.call_outlined, 'PHONE', Firm.phoneDisplay, () => _open('tel:${Firm.phoneDial}')),
            Divider(height: 1, color: context.hairline),
            row(Icons.chat_outlined, 'WHATSAPP', 'Message us', () => _open(Firm.whatsapp)),
            Divider(height: 1, color: context.hairline),
            row(Icons.mail_outline, 'EMAIL', Firm.email, () => _open('mailto:${Firm.email}')),
            Divider(height: 1, color: context.hairline),
            row(Icons.language, 'WEBSITE', 'bluearrow.ae', () => _open(Firm.website)),
          ],
        ),
      ),
    );
  }
}
