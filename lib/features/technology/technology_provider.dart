import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cached_fetch.dart';
import '../../models/tech_service_tile.dart';

final technologyProvider = FutureProvider<List<TechServiceTile>>((ref) => fetchWithCache(
      cacheKey: 'technology',
      path: '/technology',
      parse: (json) => ((json as Map<String, dynamic>)['tech_services'] as List)
          .map((e) => TechServiceTile.fromJson(e as Map<String, dynamic>))
          .toList(),
    ));
