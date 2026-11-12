import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../widgets/anim.dart';

/// Fictional watchlist used ONLY by the in-app simulation. No real people.
class _Entry {
  final String name;
  final String list;
  final String detail;
  final Color color;
  const _Entry(this.name, this.list, this.detail, this.color);
}

const _entries = <_Entry>[
  _Entry('Viktor Demidov', 'Sanctions · sample list', 'Listed for sanctions evasion (fictional).', BrandColors.danger),
  _Entry('Layla Haddad-Rahman', 'PEP · sample list', 'Senior public official, Tier 1 (fictional).', BrandColors.warn),
  _Entry('Nordic Gold Trading FZE', 'Adverse media · sample', 'Press reports of gold-smuggling allegations (fictional).', BrandColors.warn),
];

const _sources = ['UN Security Council', 'OFAC (US)', 'EU Consolidated', 'UAE Local Terrorist List', 'PEP database', 'Adverse media'];

double _similarity(String a, String b) {
  String n(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  final x = n(a), y = n(b);
  if (x.isEmpty || y.isEmpty) return 0;
  final d = _lev(x, y);
  return 1 - d / (x.length > y.length ? x.length : y.length);
}

int _lev(String a, String b) {
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      cur[j] = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost].reduce((p, q) => p < q ? p : q);
    }
    prev = cur;
  }
  return prev[b.length];
}

class ScreeningDemo extends StatefulWidget {
  const ScreeningDemo({super.key});

  @override
  State<ScreeningDemo> createState() => _ScreeningDemoState();
}

class _ScreeningDemoState extends State<ScreeningDemo> {
  final _ctrl = TextEditingController();
  int _step = -1; // -1 idle, 0.._sources.length-1 running, _sources.length done
  String _screened = '';
  _Entry? _hit;
  double _score = 0;
  bool _busy = false;
  final _resultKey = GlobalKey();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty || _busy) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    _Entry? best;
    var bestScore = 0.0;
    for (final e in _entries) {
      final s = _similarity(name, e.name);
      if (s > bestScore) {
        bestScore = s;
        best = e;
      }
    }

    setState(() {
      _busy = true;
      _screened = name;
      _hit = null;
      _step = 0;
    });
    for (var i = 0; i < _sources.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      setState(() => _step = i + 1);
    }
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _busy = false;
      _score = bestScore;
      _hit = bestScore >= 0.72 ? best : null;
    });
    // bring the result into view — it lands below the fold on most phones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _resultKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeOut, alignment: 0.6);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final running = _step >= 0 && _step < _sources.length;
    final done = _step >= _sources.length;
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _run(),
              decoration: const InputDecoration(
                hintText: 'Enter a person or company name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final s in const ['Viktor Demidoff', 'Layla Haddad Rahman', 'Nordic Gold Trading', 'Amira Khan'])
                  ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    onPressed: _busy ? null : () => setState(() => _ctrl.text = s),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _run,
                icon: const Icon(Icons.radar, size: 18),
                label: Text(_busy ? 'Screening…' : 'Run screening'),
              ),
            ),
            if (_step >= 0) ...[
              const SizedBox(height: 16),
              for (var i = 0; i < _sources.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: i < _step
                            ? const Icon(Icons.check_circle, size: 18, color: BrandColors.ok)
                            : i == _step && running
                                ? CircularProgressIndicator(strokeWidth: 2, color: primary)
                                : Icon(Icons.circle_outlined, size: 18, color: context.muted),
                      ),
                      const SizedBox(width: 10),
                      Text(_sources[i], style: TextStyle(color: i <= _step ? null : context.muted)),
                    ],
                  ),
                ),
            ],
            if (done) ...[
              const SizedBox(height: 14),
              KeyedSubtree(key: _resultKey, child: FadeSlideIn(child: _result(context))),
            ],
            const SizedBox(height: 10),
            Text('Simulation using fictional sample data — not a real screening.',
                style: TextStyle(fontSize: 11, color: context.muted)),
          ],
        ),
      ),
    );
  }

  Widget _result(BuildContext context) {
    final hit = _hit;
    final color = hit?.color ?? BrandColors.ok;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          ProgressRing(
            value: hit == null ? 0.0 : _score,
            size: 60,
            stroke: 7,
            color: color,
            child: Text(hit == null ? '0%' : '${(_score * 100).round()}%',
                style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hit == null ? 'No matches found' : 'Possible match — review required',
                    style: TextStyle(fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 3),
                Text(
                  hit == null
                      ? '"$_screened" is clear on all ${_sources.length} sources.'
                      : '"$_screened" resembles ${hit.name}. ${hit.list}. ${hit.detail}',
                  style: const TextStyle(fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
