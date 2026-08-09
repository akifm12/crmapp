class NewsItem {
  final int id;
  final String title;
  final String summary;
  final String? body;
  final String sourceName;
  final String? sourceUrl;
  final String category;
  final bool isAiGenerated;
  final DateTime? publishedAt;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.sourceName,
    required this.sourceUrl,
    required this.category,
    required this.isAiGenerated,
    required this.publishedAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
        id: json['id'] as int,
        title: json['title'] as String,
        summary: json['summary'] as String,
        body: json['body'] as String?,
        sourceName: json['source_name'] as String,
        sourceUrl: json['source_url'] as String?,
        category: json['category'] as String,
        isAiGenerated: json['is_ai_generated'] as bool? ?? false,
        publishedAt: json['published_at'] != null
            ? DateTime.tryParse(json['published_at'] as String)
            : null,
      );

  static const categoryLabels = {
    'aml': 'AML',
    'sanctions': 'Sanctions',
    'regulatory': 'Regulatory',
    'industry': 'Industry',
    'insight': 'BA-Digest',
  };

  String get categoryLabel => categoryLabels[category] ?? category;

  String get categoryColorKey => switch (category) {
        'aml' => 'red',
        'sanctions' => 'orange',
        'regulatory' => 'blue',
        'industry' => 'emerald',
        'insight' => 'purple',
        _ => 'gray',
      };
}
