import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../core/user_prefs.dart';
import '../auth/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Me')),
      body: auth.isLoading
          ? const Center(child: CircularProgressIndicator())
          : auth.isLoggedIn
              ? _loggedInView(context, ref, auth.user!.name, auth.user!.email)
              : _loggedOutView(context, ref),
    );
  }

  Widget _loggedInView(BuildContext context, WidgetRef ref, String name, String email) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: BrandColors.primary,
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 24)),
        ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(email, style: TextStyle(color: context.muted)),
        const SizedBox(height: 16),
        _prefsCard(context, ref),
        const SizedBox(height: 8),
        ..._links(context),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Sign Out'),
        ),
      ],
    );
  }

  Widget _loggedOutView(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Icon(Icons.account_circle_outlined, size: 52, color: context.muted),
                const SizedBox(height: 10),
                const Text('Sign in to sync your own compliance deadlines.', textAlign: TextAlign.center),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: () => context.push('/login'), child: const Text('Sign In')),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(onPressed: () => context.push('/register'), child: const Text('Create Free Account')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _prefsCard(context, ref),
        const SizedBox(height: 8),
        ..._links(context),
      ],
    );
  }

  List<Widget> _links(BuildContext context) => [
        _menuTile(context, icon: Icons.business_center_outlined, label: 'Our services', onTap: () => context.push('/services')),
        _menuTile(context, icon: Icons.memory_outlined, label: 'Our software', onTap: () => context.push('/technology')),
        _menuTile(context, icon: Icons.info_outline, label: 'About Blue Arrow', onTap: () => context.push('/about')),
        _menuTile(context, icon: Icons.mail_outline, label: 'Contact Us', onTap: () => context.push('/contact')),
        _menuTile(context, icon: Icons.language, label: 'Visit bluearrow.ae',
            onTap: () => launchUrl(Uri.parse('https://bluearrow.ae'), mode: LaunchMode.externalApplication)),
      ];

  Widget _prefsCard(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPrefsProvider);
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(kSectors[prefs.sector]?.icon ?? Icons.public, color: BrandColors.primary),
            title: const Text('My sector'),
            subtitle: Text(kSectors[prefs.sector]?.label ?? 'All sectors'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/sector'),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ],
                selected: {prefs.themeMode},
                onSelectionChanged: (s) => ref.read(userPrefsProvider.notifier).setThemeMode(s.first),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
