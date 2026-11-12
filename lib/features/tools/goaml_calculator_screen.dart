import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../widgets/anim.dart';

class _Report {
  final String code;
  final String name;
  final String trigger;
  final int? businessDays; // null = "without delay"
  final String note;
  const _Report(this.code, this.name, this.trigger, this.businessDays, this.note);
}

const _reports = <_Report>[
  _Report('STR', 'Suspicious Transaction Report (STR/SAR)', 'Date you formed the suspicion', null,
      'File without delay — do not wait for a deadline, and never tip off the customer.'),
  _Report('DPMSR', 'Dealers in Precious Metals & Stones Report', 'Date of the cash / virtual-asset transaction', 15,
      'For qualifying cash transactions at or above AED 55,000. Typically due within 15 business days.'),
  _Report('REAR', 'Real Estate Activity Report', 'Date of the qualifying transaction', 15,
      'For qualifying real-estate transactions. Typically due within 15 business days.'),
  _Report('FFR', 'Funds Freeze Report (targeted financial sanctions)', 'Date you froze the funds', 5,
      'Freeze without delay (within 24 hours) and report. Typically within 5 business days.'),
  _Report('PNMR', 'Partial Name Match Report', 'Date of the partial match', 5,
      'When a possible match cannot be confirmed. Typically within 5 business days.'),
];

DateTime _addBusinessDays(DateTime start, int n) {
  var d = DateTime(start.year, start.month, start.day);
  var left = n;
  while (left > 0) {
    d = d.add(const Duration(days: 1));
    if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) left--;
  }
  return d;
}

class GoamlCalculatorScreen extends StatefulWidget {
  const GoamlCalculatorScreen({super.key});

  @override
  State<GoamlCalculatorScreen> createState() => _GoamlCalculatorScreenState();
}

class _GoamlCalculatorScreenState extends State<GoamlCalculatorScreen> {
  int _sel = 1;
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final r = _reports[_sel];
    final due = r.businessDays == null ? null : _addBusinessDays(_date, r.businessDays!);
    final days = due == null ? null : daysUntil(due);
    final color = days == null ? BrandColors.danger : urgencyColor(days);

    return Scaffold(
      appBar: AppBar(title: const Text('goAML deadline calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Which report?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _reports.length; i++)
                ChoiceChip(
                  label: Text(_reports[i].code),
                  selected: _sel == i,
                  onSelected: (_) => setState(() => _sel = i),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          Text(r.trigger, style: TextStyle(color: context.muted)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null) setState(() => _date = d);
            },
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(DateFormat('EEEE, d MMMM yyyy').format(_date)),
          ),
          const SizedBox(height: 22),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: context.isDark ? 0.22 : 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(due == null ? 'WITHOUT DELAY' : 'FILE BY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: color)),
                const SizedBox(height: 6),
                Text(due == null ? 'As soon as possible' : DateFormat('EEEE, d MMMM yyyy').format(due),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
                if (days != null) ...[
                  const SizedBox(height: 4),
                  Text(dueText(days), style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                ],
                const SizedBox(height: 12),
                Text(r.note, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Counts business days Monday–Friday and ignores public holidays. Always check the latest UAE FIU / supervisor guidance for your case.',
            style: TextStyle(fontSize: 11, color: context.muted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.push('/contact', extra: 'I need help with a goAML ${r.code} filing.'),
            child: const Text('Need help filing? Talk to us'),
          ),
        ],
      ),
    );
  }
}
