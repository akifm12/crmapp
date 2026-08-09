class ServiceTile {
  final String slug;
  final String icon;
  final bool portalBacked;
  final String title;
  final String summary;

  ServiceTile({
    required this.slug,
    required this.icon,
    required this.portalBacked,
    required this.title,
    required this.summary,
  });

  factory ServiceTile.fromJson(Map<String, dynamic> json) => ServiceTile(
        slug: json['slug'] as String,
        icon: json['icon'] as String,
        portalBacked: json['portal_backed'] as bool? ?? false,
        title: json['title'] as String,
        summary: json['summary'] as String,
      );
}
