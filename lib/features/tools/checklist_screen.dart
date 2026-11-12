import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/user_prefs.dart';
import '../../widgets/anim.dart';

const _individual = [
  'Valid passport or Emirates ID (copy retained)',
  'Proof of residential address',
  'Occupation / employer details',
  'Source of funds explanation',
  'Sanctions & PEP screening result',
];

const _corporate = [
  'Valid trade licence',
  'Memorandum / Articles of Association',
  'Register of shareholders and UBOs (25%+)',
  'Board resolution / authority of signatory',
  'ID of directors, UBOs and authorised signatories',
  'Proof of registered address',
  'Source of funds / expected activity profile',
  'Sanctions & PEP screening of entity, UBOs and directors',
];

const _extras = <String, List<String>>{
  'gold': [
    'Origin / supply-chain documents for the metal',
    'CAHRA (conflict-affected area) assessment',
    'Assay or refiner certificate where applicable',
    'Cash transaction record (DPMSR trigger check)',
  ],
  'real_estate': [
    'Title deed / property details',
    'Sale agreement (SPA/MOU) and payment schedule',
    'Source of funds for each payment',
    'Buyer and seller both identified (REAR trigger check)',
  ],
  'company_services': [
    'Purpose of company formation and business plan',
    'Ownership chain to ultimate beneficial owners',
    'Reasons for any nominee arrangement',
  ],
  'accounting': [
    'Signed engagement letter',
    'Understanding of the client\'s business and activity',
    'Reasons for any unusual request or structure',
  ],
};

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  bool _corp = true;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPrefsProvider);
    final sector = prefs.sector;
    final base = _corp ? _corporate : _individual;
    final extra = _extras[sector] ?? const <String>[];
    final all = [...base, ...extra];
    final tag = '${_corp ? 'c' : 'i'}:${sector ?? 'all'}';
    String key(String item) => '$tag:$item';
    final done = all.where((i) => prefs.checklist.contains(key(i))).length;

    return Scaffold(
      appBar: AppBar(title: const Text('KYC document checklist')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Company'), icon: Icon(Icons.business)),
              ButtonSegment(value: false, label: Text('Individual'), icon: Icon(Icons.person)),
            ],
            selected: {_corp},
            onSelectionChanged: (s) => setState(() => _corp = s.first),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ProgressRing(
                value: all.isEmpty ? 0.0 : done / all.length,
                size: 52,
                stroke: 7,
                color: BrandColors.ok,
                child: Text('$done/${all.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sector == null ? 'Standard documents' : 'Standard + ${kSectors[sector]!.short} extras',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final n = ref.read(userPrefsProvider.notifier);
                  for (final i in all) {
                    if (ref.read(userPrefsProvider).checklist.contains(key(i))) await n.toggleChecklist(key(i));
                  }
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in all)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: CheckboxListTile(
                  value: prefs.checklist.contains(key(item)),
                  onChanged: (_) {
                    HapticFeedback.selectionClick();
                    ref.read(userPrefsProvider.notifier).toggleChecklist(key(item));
                  },
                  title: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  controlAffinity: ListTileControlAffinity.leading,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text('A practical guide — your own policy and your supervisor\'s rules may require more.',
              style: TextStyle(fontSize: 11, color: context.muted)),
        ],
      ),
    );
  }
}
