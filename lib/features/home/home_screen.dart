import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../models/news_item.dart';
import '../../models/service_tile.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Blue Arrow')),
      body: homeAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(onRetry: () => ref.invalidate(homeProvider)),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(homeProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _hero(context),
              const SizedBox(height: 24),
              _sectionHeader(context, 'Compliance Solutions', onSeeAll: () => context.push('/services')),
              const SizedBox(height: 12),
              _servicesGrid(data.services),
              const SizedBox(height: 28),
              _sectionHeader(context, 'Our Software', onSeeAll: () => context.push('/technology')),
              const SizedBox(height: 12),
              _techBanner(context),
              const SizedBox(height: 28),
              _sectionHeader(context, 'Latest Updates'),
              const SizedBox(height: 12),
              ...data.news.map((n) => _newsTile(context, n)),
              const SizedBox(height: 28),
              _contactCta(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BrandColors.primaryDark, BrandColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UAE AML & Regulatory Compliance',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track deadlines, stay informed, and get compliant — right from your phone.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }

  Widget _servicesGrid(List<ServiceTile> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final tile = services[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tile.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(tile.title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    tile.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _techBanner(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: BrandColors.gold,
          child: Icon(Icons.shield_outlined, color: Colors.white),
        ),
        title: const Text('KYC Portal & Bullion Accounting', style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('See what our compliance software can do for you.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/technology'),
      ),
    );
  }

  Widget _newsTile(BuildContext context, NewsItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: CategoryBadge(label: item.categoryLabel, colorKey: item.categoryColorKey),
        ),
        onTap: () => context.push('/news/${item.id}'),
      ),
    );
  }

  Widget _contactCta(BuildContext context) {
    return Card(
      color: BrandColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help with compliance?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: BrandColors.primary),
              onPressed: () => context.push('/contact'),
              child: const Text('Get in touch'),
            ),
          ],
        ),
      ),
    );
  }
}
