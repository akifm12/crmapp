import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/resource_document.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/sector_filter_chip.dart';
import 'resources_provider.dart';

class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sector = ref.watch(selectedResourceSectorProvider);
    final dataAsync = ref.watch(resourcesProvider(sector));

    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: dataAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(onRetry: () => ref.invalidate(resourcesProvider(sector))),
        data: (data) => Column(
          children: [
            const SizedBox(height: 10),
            SectorFilterRow(
              sectors: data.sectors,
              selected: sector,
              onSelected: (value) => ref.read(selectedResourceSectorProvider.notifier).state = value,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: data.resources.isEmpty
                  ? const EmptyView(message: 'No resources for this sector yet.', icon: Icons.folder_off_outlined)
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(resourcesProvider(sector)),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.resources.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _resourceCard(data.resources[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resourceCard(ResourceDocument resource) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(child: Icon(Icons.description_outlined)),
        title: Text(resource.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resource.description != null) ...[
              const SizedBox(height: 4),
              Text(resource.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 4),
            Text('${resource.category} · ${resource.fileSizeHuman}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
        trailing: const Icon(Icons.download_outlined),
        onTap: () => launchUrl(Uri.parse(resource.downloadUrl), mode: LaunchMode.externalApplication),
      ),
    );
  }
}
