import 'user_deadline.dart';

class ComplianceDeadline {
  final int id;
  final String title;
  final String? description;
  final String? sector;
  final String category;
  final String? authority;
  final String recurrence;
  final DateTime? nextDueDate;
  final String? sourceUrl;
  final UserDeadline? myDeadline;

  ComplianceDeadline({
    required this.id,
    required this.title,
    required this.description,
    required this.sector,
    required this.category,
    required this.authority,
    required this.recurrence,
    required this.nextDueDate,
    required this.sourceUrl,
    required this.myDeadline,
  });

  factory ComplianceDeadline.fromJson(Map<String, dynamic> json) =>
      ComplianceDeadline(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        sector: json['sector'] as String?,
        category: json['category'] as String,
        authority: json['authority'] as String?,
        recurrence: json['recurrence'] as String,
        nextDueDate: json['next_due_date'] != null
            ? DateTime.tryParse(json['next_due_date'] as String)
            : null,
        sourceUrl: json['source_url'] as String?,
        myDeadline: json['my_deadline'] != null
            ? UserDeadline.fromJson(json['my_deadline'] as Map<String, dynamic>)
            : null,
      );

  String get categoryColorKey => switch (category) {
        'goaml' => 'red',
        'licensing' => 'amber',
        'screening' => 'blue',
        'training' => 'purple',
        'reporting' => 'emerald',
        _ => 'gray',
      };
}
