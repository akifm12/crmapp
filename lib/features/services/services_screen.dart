import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import 'services_provider.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: servicesAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(onRetry: () => ref.invalidate(servicesProvider)),
        data: (services) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(servicesProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tile = services[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tile.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tile.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(tile.summary, style: TextStyle(color: Colors.grey.shade700)),
                            if (!tile.portalBacked) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Advisory', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ],
                        ),
                      ),
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
