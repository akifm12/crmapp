import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/user_deadline.dart';
import 'compliance_provider.dart';

Future<void> showDeadlineFormSheet(BuildContext context, {UserDeadline? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => DeadlineFormSheet(existing: existing),
  );
}

class DeadlineFormSheet extends ConsumerStatefulWidget {
  final UserDeadline? existing;
  const DeadlineFormSheet({super.key, this.existing});

  @override
  ConsumerState<DeadlineFormSheet> createState() => _DeadlineFormSheetState();
}

class _DeadlineFormSheetState extends ConsumerState<DeadlineFormSheet> {
  late String _type;
  late TextEditingController _labelCtrl;
  late TextEditingController _notesCtrl;
  late DateTime _dueDate;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? UserDeadline.typeLabels.keys.first;
    _labelCtrl = TextEditingController(text: e?.label ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _dueDate = e?.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
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
      final label = _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim();
      final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
      if (widget.existing == null) {
        await actions.add(type: _type, label: label, dueDate: _dueDate, notes: notes);
      } else {
        await actions.update(widget.existing!.id, type: _type, label: label, dueDate: _dueDate, notes: notes);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _error = 'Could not save this deadline. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existing == null ? 'Add deadline' : 'Edit deadline',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
          ],
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: UserDeadline.typeLabels.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _labelCtrl,
            decoration: const InputDecoration(labelText: 'Custom label (optional)'),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Due date'),
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
        ],
      ),
    );
  }
}
