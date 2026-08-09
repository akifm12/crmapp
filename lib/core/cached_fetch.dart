import 'dart:async';
import 'dart:convert';

import 'api_client.dart';
import 'cache.dart';

/// Fetches [path], caching the raw JSON under [cacheKey] for instant
/// cold-start paint next time. Falls back to the cached copy if the
/// network call fails (offline, server down, etc.).
Future<T> fetchWithCache<T>({
  required String cacheKey,
  required String path,
  required T Function(dynamic json) parse,
  Map<String, dynamic>? queryParameters,
}) async {
  try {
    final response = await ApiClient.instance.get(path, queryParameters: queryParameters);
    unawaited(ResponseCache.write(cacheKey, jsonEncode(response.data)));
    return parse(response.data);
  } catch (_) {
    final cached = await ResponseCache.read(cacheKey);
    if (cached != null) return parse(jsonDecode(cached));
    rethrow;
  }
}
