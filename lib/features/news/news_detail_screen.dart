import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/category_badge.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import 'news_provider.dart';

class NewsDetailScreen extends ConsumerWidget {
  final int id;
  const NewsDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: newsAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(onRetry: () => ref.invalidate(newsDetailProvider(id))),
        data: (item) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CategoryBadge(label: item.categoryLabel, colorKey: item.categoryColorKey),
                if (item.isAiGenerated) ...[
                  const SizedBox(width: 8),
                  const CategoryBadge(label: 'AI-assisted', colorKey: 'purple'),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
            const SizedBox(height: 8),
            Text(
              [
                item.sourceName,
                if (item.publishedAt != null) DateFormat('d MMM yyyy').format(item.publishedAt!),
              ].join(' · '),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(item.summary, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.5)),
            if (item.body != null && item.body!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(item.body!, style: const TextStyle(fontSize: 14, height: 1.6)),
            ],
            if (item.sourceUrl != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(item.sourceUrl!), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('View original source'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
