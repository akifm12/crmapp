import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/cached_fetch.dart';
import '../../models/compliance_deadline.dart';
import '../../models/user_deadline.dart';

class ComplianceCalendarData {
  final List<ComplianceDeadline> deadlines;
  final Map<String, String> sectors;

  ComplianceCalendarData({required this.deadlines, required this.sectors});

  factory ComplianceCalendarData.fromJson(Map<String, dynamic> json) => ComplianceCalendarData(
        deadlines: (json['deadlines'] as List)
            .map((e) => ComplianceDeadline.fromJson(e as Map<String, dynamic>))
            .toList(),
        sectors: (json['sectors'] as Map).cast<String, String>(),
      );
}

final selectedSectorProvider = StateProvider<String?>((ref) => null);

final complianceCalendarProvider = FutureProvider.family<ComplianceCalendarData, String?>(
  (ref, sector) => fetchWithCache(
    cacheKey: 'compliance_${sector ?? 'all'}',
    path: '/compliance-calendar',
    queryParameters: {'sector': ?sector},
    parse: (json) => ComplianceCalendarData.fromJson(json as Map<String, dynamic>),
  ),
);

final myDeadlinesProvider = FutureProvider<List<UserDeadline>>((ref) async {
  final response = await ApiClient.instance.get('/account/deadlines');
  return (response.data['data'] as List).map((e) => UserDeadline.fromJson(e as Map<String, dynamic>)).toList();
});

class DeadlineActions {
  final Ref ref;
  DeadlineActions(this.ref);

  Future<void> add({
    String? type,
    String? label,
    required DateTime dueDate,
    String? notes,
    int? complianceDeadlineId,
  }) async {
    await ApiClient.instance.post('/account/deadlines', data: {
      'compliance_deadline_id': complianceDeadlineId,
      'type': type,
      'label': label,
      'due_date': dueDate.toIso8601String().split('T').first,
      'notes': notes,
    });
    _refresh();
  }

  Future<void> update(
    int id, {
    String? type,
    String? label,
    required DateTime dueDate,
    String? notes,
    int? complianceDeadlineId,
  }) async {
    await ApiClient.instance.patch('/account/deadlines/$id', data: {
      'compliance_deadline_id': complianceDeadlineId,
      'type': type,
      'label': label,
      'due_date': dueDate.toIso8601String().split('T').first,
      'notes': notes,
    });
    _refresh();
  }

  Future<void> delete(int id) async {
    await ApiClient.instance.delete('/account/deadlines/$id');
    _refresh();
  }

  void _refresh() {
    ref.invalidate(myDeadlinesProvider);
    ref.invalidate(complianceCalendarProvider);
  }
}

final deadlineActionsProvider = Provider((ref) => DeadlineActions(ref));
