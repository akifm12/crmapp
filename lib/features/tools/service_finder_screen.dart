import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/user_prefs.dart';
import '../../widgets/anim.dart';

const _needs = <String, ({String label, IconData icon})>{
  'onboarding': (label: 'Onboard customers (KYC/KYB)', icon: Icons.how_to_reg_outlined),
  'screening': (label: 'Screen for sanctions, PEPs & media', icon: Icons.radar),
  'policy': (label: 'AML policy & risk assessment', icon: Icons.description_outlined),
  'goaml': (label: 'goAML reporting support', icon: Icons.upload_file_outlined),
  'training': (label: 'Staff AML training', icon: Icons.school_outlined),
  'advice': (label: 'Not sure — I need advice', icon: Icons.help_outline),
};

const _sizes = <String, String>{
  'solo': 'Just me / 1–5 people',
  'mid': '6–25 people',
  'large': '26+ people',
};

class _Rec {
  final String title;
  final String text;
  final IconData icon;
  final bool sentinel;
  const _Rec(this.title, this.text, this.icon, {this.sentinel = false});
}

const _recs = <String, _Rec>{
  'onboarding': _Rec('KYC & Client Onboarding Portal',
      'Send customers a secure self-fill link; documents are scanned and screened automatically.', Icons.how_to_reg_outlined),
  'screening': _Rec('Blue Arrow Sentinel',
      'Sanctions, PEP and adverse-media screening with fuzzy matching and ongoing monitoring.', Icons.radar,
      sentinel: true),
  'policy': _Rec('AML/CFT Policy & Risk Assessment',
      'A policy and business risk assessment written for your sector and size.', Icons.description_outlined),
  'goaml': _Rec('goAML Reporting Support',
      'Help preparing and filing STR/SAR, DPMSR and other goAML reports on time.', Icons.upload_file_outlined),
  'training': _Rec('AML Staff Training',
      'Practical training for your team, with attendance records and certificates.', Icons.school_outlined),
  'advice': _Rec('Free consultation',
      'Talk to our compliance team and we will point you to the right starting place.', Icons.support_agent),
};

class ServiceFinderScreen extends StatefulWidget {
  const ServiceFinderScreen({super.key});

  @override
  State<ServiceFinderScreen> createState() => _ServiceFinderScreenState();
}

class _ServiceFinderScreenState extends State<ServiceFinderScreen> {
  int _step = 0;
  String? _sector, _need, _size;

  List<String> get _recKeys {
    final keys = <String>[_need!];
    // sensible companions
    if (_need == 'onboarding') keys.add('screening');
    if (_need == 'policy') keys.add('training');
    if (_need == 'screening' && _size != 'solo') keys.add('onboarding');
    if (_need == 'goaml') keys.add('policy');
    if (_need == 'training') keys.add('policy');
    if (_need == 'advice') keys.addAll(['policy', 'screening']);
    return keys.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service finder')),
      body: PopScope(
        canPop: _step == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _step--);
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: KeyedSubtree(key: ValueKey(_step), child: _body(context)),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    switch (_step) {
      case 0:
        return _choices(context, 'What type of business are you?', 1, [
          for (final e in kSectors.entries) (e.key, e.value.short, e.value.icon),
        ], (v) => _sector = v);
      case 1:
        return _choices(context, 'What do you need help with?', 2, [
          for (final e in _needs.entries) (e.key, e.value.label, e.value.icon),
        ], (v) => _need = v);
      case 2:
        return _choices(context, 'How big is your team?', 3, [
          for (final e in _sizes.entries) (e.key, e.value, Icons.groups_outlined),
        ], (v) => _size = v);
      default:
        return _results(context);
    }
  }

  Widget _choices(BuildContext context, String title, int next, List<(String, String, IconData)> options, void Function(String) set) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Step ${_step + 1} of 3',
            style: TextStyle(color: context.muted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        for (var i = 0; i < options.length; i++)
          FadeSlideIn(
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Pressable(
                onTap: () {
                  set(options[i].$1);
                  setState(() => _step = next);
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(options[i].$3, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 14),
                        Expanded(child: Text(options[i].$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                        Icon(Icons.chevron_right, color: context.muted),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _results(BuildContext context) {
    final keys = _recKeys;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Our recommendation', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('For ${kSectors[_sector]?.short ?? 'your business'} · ${_sizes[_size]}', style: TextStyle(color: context.muted)),
        const SizedBox(height: 18),
        for (var i = 0; i < keys.length; i++)
          FadeSlideIn(
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: i == 0 ? BrandColors.primary.withValues(alpha: context.isDark ? 0.25 : 0.08) : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_recs[keys[i]]!.icon, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_recs[keys[i]]!.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                          if (i == 0)
                            const Text('BEST FIT',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: BrandColors.gold, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_recs[keys[i]]!.text, style: const TextStyle(height: 1.4)),
                      if (_recs[keys[i]]!.sentinel) ...[
                        const SizedBox(height: 10),
                        OutlinedButton(onPressed: () => context.go('/?tab=2'), child: const Text('Try Sentinel')),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: () => context.push('/contact',
              extra: "I'm in ${kSectors[_sector]?.short ?? 'my sector'} (${_sizes[_size]}) and I'm interested in: ${keys.map((k) => _recs[k]!.title).join(', ')}."),
          icon: const Icon(Icons.send),
          label: const Text('Request a consultation'),
        ),
        TextButton(onPressed: () => setState(() => _step = 0), child: const Text('Start over')),
      ],
    );
  }
}
