import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/user_prefs.dart';
import '../../widgets/anim.dart';

/// First-run question ("what kind of business are you?") — also reused from
/// Me → Change sector. Personalises the calendar, home and checklists.
class SectorPickerScreen extends ConsumerWidget {
  final bool fromSettings;
  const SectorPickerScreen({super.key, this.fromSettings = false});

  Future<void> _pick(BuildContext context, WidgetRef ref, String? sector) async {
    await ref.read(userPrefsProvider.notifier).setSector(sector);
    if (!context.mounted) return;
    if (fromSettings && context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(userPrefsProvider.select((p) => p.sector));
    final entries = kSectors.entries.toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1B4D), BrandColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
            children: [
              if (fromSettings)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              const FadeSlideIn(
                child: Text('Welcome to Blue Arrow',
                    style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.1, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),
              const FadeSlideIn(
                index: 1,
                child: Text('What kind of business do you run?',
                    style: TextStyle(color: Colors.white, fontSize: 30, height: 1.15, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                index: 2,
                child: Text("We'll tailor your deadlines, checklists and alerts to your sector.",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15)),
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < entries.length; i++)
                FadeSlideIn(
                  index: 3 + i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Pressable(
                      onTap: () => _pick(context, ref, entries[i].key),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: selected == entries[i].key ? 0.24 : 0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected == entries[i].key ? BrandColors.gold : Colors.white24,
                            width: selected == entries[i].key ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(entries[i].value.icon, color: Colors.white),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(entries[i].value.label,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => _pick(context, ref, null),
                  child: const Text('Skip — show me everything', style: TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
