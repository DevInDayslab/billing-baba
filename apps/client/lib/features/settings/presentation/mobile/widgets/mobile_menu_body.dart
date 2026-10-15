import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:billing_baba/features/settings/application/mobile_menu_catalog.dart';
import 'package:billing_baba/features/settings/application/mobile_menu_expansion_provider.dart';
import 'package:billing_baba/features/settings/models/mobile_menu_item.dart';
import 'package:billing_baba/features/settings/presentation/mobile/widgets/mobile_menu_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Renders the full Menu hub body from [MobileMenuCatalog].
class MobileMenuBody extends ConsumerWidget {
  const MobileMenuBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionServiceProvider);
    final enableOtherIncome =
        ref.watch(generalSettingsProvider).value?.enableOtherIncome ?? true;
    final expandedSectionId = ref.watch(mobileMenuExpandedSectionProvider);

    final children = <Widget>[];
    for (final section in MobileMenuCatalog.sections) {
      final items = MobileMenuCatalog.visibleItemsForSection(
        section,
        permissions,
        enableOtherIncome: enableOtherIncome,
      );
      if (items.isEmpty) continue;

      if (section.showHeader) {
        children.add(MobileMenuGroupHeader(label: section.label));
      }
      for (final item in items) {
        children.addAll(
          _buildTopLevelItem(
            context: context,
            ref: ref,
            item: item,
            section: section,
            expandedSectionId: expandedSectionId,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  List<Widget> _buildTopLevelItem({
    required BuildContext context,
    required WidgetRef ref,
    required MobileMenuItem item,
    required MobileMenuSection section,
    required String? expandedSectionId,
  }) {
    if (item.isAccordion) {
      final isExpanded = expandedSectionId == item.id;

      if (item.useFlatExpandable) {
        return [
          MobileMenuExpandableTile(
            item: item,
            isExpanded: isExpanded,
            onToggle: () {
              final notifier = ref.read(
                mobileMenuExpandedSectionProvider.notifier,
              );
              unawaited(notifier.setExpanded(isExpanded ? null : item.id));
            },
            child: _MobileMenuFlatAccordionChildren(children: item.children),
          ),
          const _MenuItemDivider(),
        ];
      }

      return [
        MobileMenuAccordionCard(
          title: item.title,
          icon: item.icon,
          subtitle: item.subtitle,
          isExpanded: isExpanded,
          onToggle: () {
            final notifier = ref.read(
              mobileMenuExpandedSectionProvider.notifier,
            );
            unawaited(notifier.setExpanded(isExpanded ? null : item.id));
          },
          child: _MobileMenuAccordionChildren(children: item.children),
        ),
      ];
    }

    if (item.action == MobileMenuAction.versionInfo) {
      return [_MobileMenuVersionTile(item: item)];
    }

    if (section.useNavCards || !section.showHeader) {
      return [
        MobileMenuNavCard(
          item: item,
          isDestructive: item.action == MobileMenuAction.logout,
          onTap: () => MobileMenuNavigation.onItemTap(context, ref, item),
        ),
      ];
    }

    return [
      MobileMenuLeafTile(
        item: item,
        onTap: () => MobileMenuNavigation.onItemTap(context, ref, item),
      ),
      const _MenuItemDivider(),
    ];
  }
}

class _MenuItemDivider extends StatelessWidget {
  const _MenuItemDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 72, color: Color(0xFFE8ECF1));
  }
}

class _MobileMenuFlatAccordionChildren extends ConsumerWidget {
  const _MobileMenuFlatAccordionChildren({required this.children});

  final List<MobileMenuItem> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionServiceProvider);
    final visible = children
        .where((child) => MobileMenuCatalog.isItemVisible(child, permissions))
        .toList();

    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          MobileMenuLeafTile(
            item: visible[i],
            dense: true,
            showSubtitle: false,
            onTap: () =>
                MobileMenuNavigation.onItemTap(context, ref, visible[i]),
          ),
          if (i < visible.length - 1) const _MenuItemDivider(),
        ],
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

class _MobileMenuAccordionChildren extends ConsumerWidget {
  const _MobileMenuAccordionChildren({required this.children});

  final List<MobileMenuItem> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionServiceProvider);
    final visible = children
        .where((child) => MobileMenuCatalog.isItemVisible(child, permissions))
        .toList();

    if (visible.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            MobileMenuLeafTile(
              item: visible[i],
              dense: true,
              showSubtitle: false,
              onTap: () =>
                  MobileMenuNavigation.onItemTap(context, ref, visible[i]),
            ),
            if (i < visible.length - 1)
              const Divider(
                height: 1,
                indent: AppSpacing.lg,
                color: Color(0xFFE8ECF1),
              ),
          ],
        ],
      ),
    );
  }
}

class _MobileMenuVersionTile extends StatelessWidget {
  const _MobileMenuVersionTile({required this.item});

  final MobileMenuItem item;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '—';
        final build = snapshot.data?.buildNumber ?? '—';
        return MobileMenuLeafTile(
          item: MobileMenuItem(
            id: item.id,
            title: item.title,
            subtitle: 'Version $version ($build)',
            action: MobileMenuAction.versionInfo,
          ),
          showChevron: false,
          onTap: () {},
        );
      },
    );
  }
}
