import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/application/contacts_provider.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileContactsScreen extends ConsumerWidget {
  const MobileContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Contacts',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppError(
          message: error.toString(),
          onRetry: () => ref.read(contactsProvider.notifier).refresh(),
        ),
        data: (contacts) {
          if (contacts.isEmpty) {
            return const MobileEmptyState(
              title: 'No contacts yet',
              message: 'Contacts from CRM will appear here.',
              icon: Icons.contacts_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(contactsProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: contacts.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Card(
                  elevation: 0,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  child: ListTile(
                    title: Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      [
                        contact.phone,
                        contact.email,
                        contact.accountName,
                      ].whereType<String>().where((v) => v.isNotEmpty).join(' · '),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
