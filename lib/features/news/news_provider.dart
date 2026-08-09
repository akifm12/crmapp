import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/cached_fetch.dart';
import '../../models/news_item.dart';

class NewsListState {
  final List<NewsItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? category;
  final String? error;

  const NewsListState({
    this.items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.category,
    this.error,
  });

  NewsListState copyWith({
    List<NewsItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? category,
    bool clearCategory = false,
    String? error,
    bool clearError = false,
  }) {
    return NewsListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      category: clearCategory ? null : (category ?? this.category),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NewsListNotifier extends StateNotifier<NewsListState> {
  NewsListNotifier() : super(const NewsListState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, page: 1, clearError: true);
    try {
      final items = await fetchWithCache(
        cacheKey: 'news_${state.category ?? 'all'}',
        path: '/news',
        queryParameters: {if (state.category != null) 'category': state.category, 'page': 1},
        parse: (json) => ((json as Map<String, dynamic>)['data'] as List)
            .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      state = state.copyWith(items: items, isLoading: false, page: 1, hasMore: items.isNotEmpty);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: "Couldn't load news.");
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;
    try {
      final response = await ApiClient.instance.get('/news', queryParameters: {
        if (state.category != null) 'category': state.category,
        'page': nextPage,
      });
      final newItems = (response.data['data'] as List)
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoadingMore: false,
        page: nextPage,
        hasMore: newItems.isNotEmpty,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setCategory(String? category) {
    state = NewsListState(category: category);
    load();
  }
}

final newsListProvider = StateNotifierProvider<NewsListNotifier, NewsListState>((ref) => NewsListNotifier());

final newsDetailProvider = FutureProvider.family<NewsItem, int>((ref, id) => fetchWithCache(
      cacheKey: 'news_detail_$id',
      path: '/news/$id',
      parse: (json) => NewsItem.fromJson(json as Map<String, dynamic>),
    ));
