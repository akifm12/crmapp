class ResourceDocument {
  final int id;
  final String title;
  final String? description;
  final String? sector;
  final String category;
  final String downloadUrl;
  final String fileSizeHuman;

  ResourceDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.sector,
    required this.category,
    required this.downloadUrl,
    required this.fileSizeHuman,
  });

  factory ResourceDocument.fromJson(Map<String, dynamic> json) =>
      ResourceDocument(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        sector: json['sector'] as String?,
        category: json['category'] as String,
        downloadUrl: json['download_url'] as String,
        fileSizeHuman: json['file_size_human'] as String? ?? '',
      );
}
