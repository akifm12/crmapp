import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';

class _Factor {
  final String label;
  final String hint;
  final int points;
  const _Factor(this.label, this.hint, this.points);
}

const _factors = <_Factor>[
  _Factor('Customer is a Politically Exposed Person (or relative/associate)', 'PEPs always need enhanced due diligence.', 4),
  _Factor('Customer or UBO is in/linked to a high-risk jurisdiction', 'FATF high-risk or increased-monitoring countries.', 3),
  _Factor('Ownership structure is complex or the UBO is unclear', 'Layers, nominees or bearer shares.', 3),
  _Factor('Large or unusual cash payment', 'Cash-intensive or above reporting thresholds.', 3),
  _Factor('Customer is not met face to face', 'Remote or third-party introduced.', 2),
  _Factor('Source of funds / wealth is hard to verify', 'Explanation does not fit the profile.', 3),
  _Factor('Transaction has no clear commercial rationale', 'Unusual size, pattern or urgency.', 3),
  _Factor('Adverse media or a screening alert exists', 'Even if unconfirmed — it must be reviewed.', 4),
  _Factor('New customer with no prior relationship', 'Little history to rely on.', 1),
];

class RiskRatingScreen extends StatefulWidget {
  const RiskRatingScreen({super.key});

  @override
  State<RiskRatingScreen> createState() => _RiskRatingScreenState();
}

class _RiskRatingScreenState extends State<RiskRatingScreen> {
  final _on = <int>{};

  int get _points => _on.fold(0, (s, i) => s + _factors[i].points);

  @override
  Widget build(BuildContext context) {
    final p = _points;
    final high = _on.contains(0) || _on.contains(7) || p >= 8;
    final medium = !high && p >= 3;
    final color = high ? BrandColors.danger : medium ? BrandColors.warn : BrandColors.ok;
    final level = high ? 'High risk' : medium ? 'Medium risk' : 'Low risk';
    final action = high
        ? 'Enhanced Due Diligence (EDD): senior management approval, verify source of funds and wealth, and consider whether an STR is needed.'
        : medium
            ? 'Standard Due Diligence plus closer monitoring. Document your reasoning and review at a shorter interval.'
            : 'Simplified or standard Due Diligence is likely enough. Keep records and review periodically.';

    return Scaffold(
      appBar: AppBar(title: const Text('Customer risk rating')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Tick everything that applies to this customer or transaction.', style: TextStyle(color: context.muted)),
                const SizedBox(height: 12),
                for (var i = 0; i < _factors.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: CheckboxListTile(
                        value: _on.contains(i),
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          setState(() => v == true ? _on.add(i) : _on.remove(i));
                        },
                        title: Text(_factors[i].label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(_factors[i].hint, style: const TextStyle(fontSize: 12)),
                        controlAffinity: ListTileControlAffinity.leading,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text('Indicative guide only. Your own risk assessment and the regulator\'s rules always take precedence.',
                    style: TextStyle(fontSize: 11, color: context.muted)),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: context.isDark ? 0.22 : 0.1),
                border: Border(top: BorderSide(color: color, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(high ? Icons.warning_amber_rounded : medium ? Icons.info_outline : Icons.check_circle_outline, color: color),
                      const SizedBox(width: 8),
                      Text(level, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(action, style: const TextStyle(fontSize: 13, height: 1.35)),
                  if (high || medium) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/?tab=2'),
                      icon: const Icon(Icons.radar, size: 18),
                      label: const Text('Screen this customer in Sentinel'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
