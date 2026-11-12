import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/user_prefs.dart';
import '../../widgets/anim.dart';

class _Q {
  final String text;
  final String why;
  final String fix;
  final bool sentinel;
  const _Q(this.text, this.why, this.fix, {this.sentinel = false});
}

const _questions = <_Q>[
  _Q('Is your business registered on goAML with the UAE FIU?',
      'Registered entities must be able to file STR/SAR and other reports.',
      'Register on goAML and confirm your reporting access.'),
  _Q('Have you appointed a Compliance Officer / MLRO?',
      'A suitably qualified compliance officer is a core AML/CFT requirement.',
      'Appoint and document a Compliance Officer (and a deputy).'),
  _Q('Do you have a written AML/CFT policy reviewed in the last 12 months?',
      'Policies must reflect your actual business and current rules.',
      'Draft or refresh your AML/CFT policy and get it approved by management.'),
  _Q('Is there a documented business-wide risk assessment?',
      'You need to identify and rate your customer, product and geography risks.',
      'Complete a business risk assessment and review it every year.'),
  _Q('Do you identify every customer and their beneficial owners (CDD/KYC)?',
      'Customer due diligence is required before you transact.',
      'Introduce a standard onboarding checklist covering ID and UBOs.'),
  _Q('Do you screen customers against sanctions, PEP and adverse-media lists?',
      'Screening must happen at onboarding and continue throughout the relationship.',
      'Use an automated screening tool such as Sentinel, with ongoing re-screening.',
      sentinel: true),
  _Q('Have all relevant staff had AML training in the last 12 months?',
      'Staff must recognise red flags and know how to escalate.',
      'Book refresher training and keep attendance records.'),
  _Q('Do you keep customer and transaction records for at least five years?',
      'Records must be retrievable for regulators and the FIU.',
      'Set up a retention policy and a secure, searchable archive.'),
  _Q('Do you know when and how to file STR/SAR and other goAML reports?',
      'Reports are time-bound and a missed filing is a breach.',
      'Document a reporting procedure and who files what, by when.'),
  _Q('Is your AML programme independently reviewed or audited?',
      'Independent testing shows the programme actually works.',
      'Arrange an independent review at least annually.'),
];

class HealthCheckScreen extends ConsumerStatefulWidget {
  const HealthCheckScreen({super.key});

  @override
  ConsumerState<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends ConsumerState<HealthCheckScreen> {
  final _answers = List<int?>.filled(_questions.length, null); // 2 yes, 1 partly, 0 no
  int _i = 0;
  bool _finished = false;

  int get _score => (_answers.fold<int>(0, (s, a) => s + (a ?? 0)) * 100 / (_questions.length * 2)).round();

  void _answer(int v) {
    HapticFeedback.selectionClick();
    setState(() => _answers[_i] = v);
    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      if (_i == _questions.length - 1) {
        ref.read(userPrefsProvider.notifier).saveHealth(_score);
        HapticFeedback.heavyImpact();
        setState(() => _finished = true);
      } else {
        setState(() => _i++);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compliance health check')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _finished ? _result(context) : _question(context),
      ),
    );
  }

  Widget _question(BuildContext context) {
    final q = _questions[_i];
    return Padding(
      key: ValueKey(_i),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: (_i + 1) / _questions.length),
                    duration: const Duration(milliseconds: 350),
                    builder: (context, v, _) => LinearProgressIndicator(value: v, minHeight: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_i + 1}/${_questions.length}', style: TextStyle(color: context.muted, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 32),
          Text(q.text, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 10),
          Text(q.why, style: TextStyle(color: context.muted, height: 1.4)),
          const Spacer(),
          _opt('Yes, fully in place', 2, BrandColors.ok, Icons.check_circle_outline),
          const SizedBox(height: 10),
          _opt('Partly / not sure', 1, BrandColors.warn, Icons.remove_circle_outline),
          const SizedBox(height: 10),
          _opt('No, not yet', 0, BrandColors.danger, Icons.cancel_outlined),
          if (_i > 0)
            TextButton(onPressed: () => setState(() => _i--), child: const Text('Back')),
        ],
      ),
    );
  }

  Widget _opt(String label, int v, Color c, IconData icon) {
    final sel = _answers[_i] == v;
    return Pressable(
      onTap: () => _answer(v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.withValues(alpha: sel ? 0.2 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.withValues(alpha: sel ? 1 : 0.35), width: sel ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: c),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _result(BuildContext context) {
    final score = _score;
    final color = score >= 80 ? BrandColors.ok : score >= 50 ? BrandColors.warn : BrandColors.danger;
    final grade = score >= 80 ? 'Strong foundations' : score >= 50 ? 'Some gaps to close' : 'Significant gaps';
    final gaps = <_Q>[
      for (var i = 0; i < _questions.length; i++)
        if ((_answers[i] ?? 0) < 2) _questions[i],
    ];
    final needsSentinel = gaps.any((g) => g.sentinel);

    return ListView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        Center(
          child: ProgressRing(
            value: score / 100,
            size: 160,
            stroke: 14,
            color: color,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$score', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: color)),
                Text('out of 100', style: TextStyle(color: context.muted, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(child: Text(grade, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
        const SizedBox(height: 6),
        Center(
          child: Text(gaps.isEmpty ? 'No gaps found — keep it up.' : '${gaps.length} area${gaps.length == 1 ? '' : 's'} to work on',
              style: TextStyle(color: context.muted)),
        ),
        const SizedBox(height: 22),
        for (final g in gaps)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.text, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_forward, size: 16, color: BrandColors.primaryLight),
                        const SizedBox(width: 6),
                        Expanded(child: Text(g.fix, style: const TextStyle(fontSize: 13, height: 1.35))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (needsSentinel) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BrandColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BrandColors.primary.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Close your screening gap with Sentinel', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Sanctions, PEP and adverse-media screening with ongoing monitoring.',
                    style: TextStyle(fontSize: 13, color: context.muted)),
                const SizedBox(height: 10),
                FilledButton(onPressed: () => context.go('/?tab=2'), child: const Text('See Sentinel in action')),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton.icon(
          onPressed: () => context.push('/contact',
              extra: 'I took the compliance health check and scored $score/100. I would like help closing the gaps.'),
          icon: const Icon(Icons.support_agent),
          label: const Text('Get help from our team'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() {
            _finished = false;
            _i = 0;
            for (var k = 0; k < _answers.length; k++) {
              _answers[k] = null;
            }
          }),
          child: const Text('Retake the check'),
        ),
        Text('A general self-assessment, not legal advice or a regulatory rating.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: context.muted)),
      ],
    );
  }
}
