class UserDeadline {
  final int id;
  final int? complianceDeadlineId;
  final String type;
  final String typeLabel;
  final String? label;
  final String displayLabel;
  final DateTime dueDate;
  final String? notes;
  final String badgeColor;
  final String badgeText;

  UserDeadline({
    required this.id,
    required this.complianceDeadlineId,
    required this.type,
    required this.typeLabel,
    required this.label,
    required this.displayLabel,
    required this.dueDate,
    required this.notes,
    required this.badgeColor,
    required this.badgeText,
  });

  factory UserDeadline.fromJson(Map<String, dynamic> json) => UserDeadline(
        id: json['id'] as int,
        complianceDeadlineId: json['compliance_deadline_id'] as int?,
        type: json['type'] as String,
        typeLabel: json['type_label'] as String,
        label: json['label'] as String?,
        displayLabel: json['display_label'] as String,
        dueDate: DateTime.parse(json['due_date'] as String),
        notes: json['notes'] as String?,
        badgeColor: json['badge_color'] as String,
        badgeText: json['badge_text'] as String,
      );

  static const typeLabels = {
    'trade_license': 'Trade License',
    'ejari': 'Ejari Contract',
    'passport': 'Passport',
    'eid': 'Emirates ID',
    'dnfbp_registration': 'DNFBP / goAML Registration',
    'pi_insurance': 'Professional Indemnity Insurance',
    'regulatory_license': 'Regulatory License',
    'other': 'Other',
  };
}
