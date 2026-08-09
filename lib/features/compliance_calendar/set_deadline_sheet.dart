import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/compliance_deadline.dart';
import 'compliance_provider.dart';

Future<void> showSetDeadlineSheet(BuildContext context, {required ComplianceDeadline deadline}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => SetDeadlineSheet(deadline: deadline),
  );
}

class SetDeadlineSheet extends ConsumerStatefulWidget {
  final ComplianceDeadline deadline;
  const SetDeadlineSheet({super.key, required this.deadline});

  @override
  ConsumerState<SetDeadlineSheet> createState() => _SetDeadlineSheetState();
}

class _SetDeadlineSheetState extends ConsumerState<SetDeadlineSheet> {
  late DateTime _dueDate;
  late TextEditingController _notesCtrl;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.deadline.myDeadline != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.deadline.myDeadline;
    _dueDate = existing?.dueDate ?? DateTime.now();
    _notesCtrl = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final actions = ref.read(deadlineActionsProvider);
      final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
      final existing = widget.deadline.myDeadline;
      if (existing == null) {
        await actions.add(complianceDeadlineId: widget.deadline.id, dueDate: _dueDate, notes: notes);
      } else {
        await actions.update(existing.id,
            complianceDeadlineId: widget.deadline.id, dueDate: _dueDate, notes: notes);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _error = 'Could not save this deadline. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _remove() async {
    final existing = widget.deadline.myDeadline;
    if (existing == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(deadlineActionsProvider).delete(existing.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _saving = false;
        _error = 'Could not remove this deadline. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isEditing ? 'Update your deadline' : 'Set your deadline',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(widget.deadline.title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
          ],
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Your due date'),
              child: Text(DateFormat('d MMM yyyy').format(_dueDate)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _saving ? null : _remove,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
