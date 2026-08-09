import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import 'technology_provider.dart';

class TechnologyScreen extends ConsumerWidget {
  const TechnologyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techAsync = ref.watch(technologyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Technology')),
      body: techAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(onRetry: () => ref.invalidate(technologyProvider)),
        data: (tiles) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(technologyProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tiles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tile = tiles[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(tile.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(tile.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: BrandColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(tile.badge,
                                style: const TextStyle(fontSize: 11, color: BrandColors.gold, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(tile.summary, style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 10),
                      ...tile.features.map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: BrandColors.primary),
                                const SizedBox(width: 8),
                                Expanded(child: Text(f, style: const TextStyle(fontSize: 13))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
