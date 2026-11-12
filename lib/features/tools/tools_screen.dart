import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/anim.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = <({IconData icon, String title, String sub, String route, Color color})>[
      (icon: Icons.health_and_safety_outlined, title: 'Compliance health check', sub: '10 questions → your score & gaps', route: '/health-check', color: BrandColors.ok),
      (icon: Icons.alt_route, title: 'Service finder', sub: 'Which Blue Arrow service fits you?', route: '/service-finder', color: BrandColors.primaryLight),
      (icon: Icons.speed, title: 'Customer risk rating', sub: 'Low / medium / high in a few taps', route: '/tools/risk', color: BrandColors.warn),
      (icon: Icons.timer_outlined, title: 'goAML deadline calculator', sub: 'Work out your filing date', route: '/tools/goaml', color: BrandColors.danger),
      (icon: Icons.checklist_rtl, title: 'KYC document checklist', sub: 'Per customer type & sector', route: '/tools/checklist', color: Color(0xFF9333EA)),
      (icon: Icons.folder_outlined, title: 'Resources', sub: 'Templates and guides to download', route: '/resources', color: Color(0xFF0891B2)),
      (icon: Icons.article_outlined, title: 'News & alerts', sub: 'Regulatory updates', route: '/news', color: Color(0xFF475569)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tools.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('Free tools to help you stay compliant.', style: TextStyle(color: context.muted, fontSize: 15)),
            );
          }
          final t = tools[i - 1];
          return FadeSlideIn(
            index: i,
            child: Pressable(
              onTap: () => context.push(t.route),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: t.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                        child: Icon(t.icon, color: t.color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(t.sub, style: TextStyle(fontSize: 12.5, color: context.muted)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.muted),
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
