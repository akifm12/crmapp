import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cached_fetch.dart';
import '../../models/news_item.dart';
import '../../models/service_tile.dart';
import '../../models/tech_service_tile.dart';

class HomeData {
  final List<ServiceTile> services;
  final List<TechServiceTile> techServices;
  final List<NewsItem> news;

  HomeData({required this.services, required this.techServices, required this.news});

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
        services: (json['services'] as List)
            .map((e) => ServiceTile.fromJson(e as Map<String, dynamic>))
            .toList(),
        techServices: (json['tech_services'] as List)
            .map((e) => TechServiceTile.fromJson(e as Map<String, dynamic>))
            .toList(),
        news: (json['news'] as List)
            .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

final homeProvider = FutureProvider<HomeData>((ref) => fetchWithCache(
      cacheKey: 'home',
      path: '/home',
      parse: (json) => HomeData.fromJson(json as Map<String, dynamic>),
    ));
