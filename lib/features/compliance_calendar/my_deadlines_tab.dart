import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/calendar_helper.dart';
import '../../core/theme.dart';
import '../../models/user_deadline.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../auth/auth_provider.dart';
import 'compliance_provider.dart';
import 'deadline_form_sheet.dart';

class MyDeadlinesTab extends ConsumerWidget {
  const MyDeadlinesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isLoggedIn) {
      return _loggedOutPrompt(context);
    }

    final deadlinesAsync = ref.watch(myDeadlinesProvider);

    return Scaffold(
      body: deadlinesAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(onRetry: () => ref.invalidate(myDeadlinesProvider)),
        data: (deadlines) => deadlines.isEmpty
            ? const EmptyView(message: 'No deadlines tracked yet. Tap + to add one.', icon: Icons.event_available)
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(myDeadlinesProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: deadlines.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _deadlineCard(context, ref, deadlines[index]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDeadlineFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _loggedOutPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 40, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Sign in to track your own compliance deadlines.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.push('/login'), child: const Text('Sign in')),
            TextButton(onPressed: () => context.push('/register'), child: const Text('Create a free account')),
          ],
        ),
      ),
    );
  }

  Widget _deadlineCard(BuildContext context, WidgetRef ref, UserDeadline deadline) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(deadline.displayLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BadgeColors.fromTailwindClasses(deadline.badgeColor).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  deadline.badgeText,
                  style: TextStyle(
                    color: BadgeColors.fromTailwindClasses(deadline.badgeColor),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'calendar') {
              addDeadlineToCalendar(
                title: deadline.displayLabel,
                description: deadline.notes,
                dueDate: deadline.dueDate,
              );
            } else if (value == 'edit') {
              showDeadlineFormSheet(context, existing: deadline);
            } else if (value == 'delete') {
              await ref.read(deadlineActionsProvider).delete(deadline.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'calendar', child: Text('Add to calendar')),
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
