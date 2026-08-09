import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cached_fetch.dart';
import '../../models/resource_document.dart';

class ResourcesData {
  final List<ResourceDocument> resources;
  final Map<String, String> sectors;

  ResourcesData({required this.resources, required this.sectors});

  factory ResourcesData.fromJson(Map<String, dynamic> json) => ResourcesData(
        resources: (json['resources'] as List)
            .map((e) => ResourceDocument.fromJson(e as Map<String, dynamic>))
            .toList(),
        sectors: (json['sectors'] as Map).cast<String, String>(),
      );
}

final selectedResourceSectorProvider = StateProvider<String?>((ref) => null);

final resourcesProvider = FutureProvider.family<ResourcesData, String?>(
  (ref, sector) => fetchWithCache(
    cacheKey: 'resources_${sector ?? 'all'}',
    path: '/resources',
    queryParameters: {'sector': ?sector},
    parse: (json) => ResourcesData.fromJson(json as Map<String, dynamic>),
  ),
);
