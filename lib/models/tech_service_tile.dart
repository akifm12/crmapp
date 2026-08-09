class TechServiceTile {
  final String icon;
  final String badge;
  final String title;
  final String summary;
  final List<String> features;

  TechServiceTile({
    required this.icon,
    required this.badge,
    required this.title,
    required this.summary,
    required this.features,
  });

  factory TechServiceTile.fromJson(Map<String, dynamic> json) =>
      TechServiceTile(
        icon: json['icon'] as String,
        badge: json['badge'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        features: (json['features'] as List).cast<String>(),
      );
}
