import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cached_fetch.dart';
import '../../models/service_tile.dart';

final servicesProvider = FutureProvider<List<ServiceTile>>((ref) => fetchWithCache(
      cacheKey: 'services',
      path: '/services',
      parse: (json) => ((json as Map<String, dynamic>)['services'] as List)
          .map((e) => ServiceTile.fromJson(e as Map<String, dynamic>))
          .toList(),
    ));
