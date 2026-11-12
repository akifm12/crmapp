import 'package:intl/intl.dart';

import '../../models/compliance_deadline.dart';

/// Identifies one cycle of a (possibly recurring) deadline so ticking it off
/// applies only to that due date — next cycle starts fresh.
String doneKey(ComplianceDeadline d) =>
    '${d.id}:${d.nextDueDate == null ? 'none' : DateFormat('yyyy-MM-dd').format(d.nextDueDate!)}';
