import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/news_item.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import 'news_provider.dart';

class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});

  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
        ref.read(newsListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: Column(
        children: [
          _categoryFilter(state.category),
          Expanded(
            child: state.isLoading
                ? const LoadingView()
                : state.error != null
                    ? ErrorView(message: state.error!, onRetry: () => ref.read(newsListProvider.notifier).load())
                    : state.items.isEmpty
                        ? const EmptyView(message: 'No news in this category yet.', icon: Icons.article_outlined)
                        : RefreshIndicator(
                            onRefresh: () => ref.read(newsListProvider.notifier).load(),
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: state.items.length + (state.hasMore ? 1 : 0),
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                if (index >= state.items.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  );
                                }
                                return _newsCard(context, state.items[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _categoryFilter(String? selected) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _chip('All', null, selected),
          for (final entry in NewsItem.categoryLabels.entries) _chip(entry.value, entry.key, selected),
        ],
      ),
    );
  }

  Widget _chip(String label, String? value, String? selected) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => ref.read(newsListProvider.notifier).setCategory(value),
      ),
    );
  }

  Widget _newsCard(BuildContext context, NewsItem item) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              CategoryBadge(label: item.categoryLabel, colorKey: item.categoryColorKey),
              const SizedBox(width: 8),
              if (item.publishedAt != null)
                Text(DateFormat('d MMM yyyy').format(item.publishedAt!),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
        onTap: () => context.push('/news/${item.id}'),
      ),
    );
  }
}
