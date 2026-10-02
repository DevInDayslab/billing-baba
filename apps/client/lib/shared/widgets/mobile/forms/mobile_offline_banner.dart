import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Banner shown when a screen requires internet and the device is offline.
class MobileOfflineBanner extends ConsumerWidget {
  const MobileOfflineBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityStatusProvider).value;
    if (status != SyncConnectivityStatus.offline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: const Color(0xFFFFF3E0),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: Color(0xFFE65100),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message ?? 'You are offline. This action needs internet.',
              style: AppTypography.inter(
                fontSize: AppTypography.captionSize,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
