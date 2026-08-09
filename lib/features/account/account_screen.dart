import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../auth/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: auth.isLoading
          ? const Center(child: CircularProgressIndicator())
          : auth.isLoggedIn
              ? _loggedInView(context, ref, auth.user!.name, auth.user!.email)
              : _loggedOutView(context),
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
        Text(email, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        _menuTile(context, icon: Icons.info_outline, label: 'About Blue Arrow', onTap: () => context.push('/about')),
        _menuTile(context, icon: Icons.mail_outline, label: 'Contact Us', onTap: () => context.push('/contact')),
        _menuTile(context, icon: Icons.language, label: 'Visit bluearrow.ae',
            onTap: () => launchUrl(Uri.parse('https://bluearrow.ae'), mode: LaunchMode.externalApplication)),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Sign Out'),
        ),
      ],
    );
  }

  Widget _loggedOutView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.account_circle_outlined, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('Sign in to track your compliance deadlines and manage your account.',
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () => context.push('/login'), child: const Text('Sign In')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () => context.push('/register'), child: const Text('Create Free Account')),
        const SizedBox(height: 32),
        _menuTile(context, icon: Icons.info_outline, label: 'About Blue Arrow', onTap: () => context.push('/about')),
        _menuTile(context, icon: Icons.mail_outline, label: 'Contact Us', onTap: () => context.push('/contact')),
      ],
    );
  }

  Widget _menuTile(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: BrandColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
