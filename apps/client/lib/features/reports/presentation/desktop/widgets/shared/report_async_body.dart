import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/reports_error_mapper.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_loading_skeleton.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides reload state to descendants so table areas can show a local loader.
class ReportReloadScope extends InheritedWidget {
  const ReportReloadScope({
    required this.isReloading,
    required super.child,
    super.key,
  });

  final bool isReloading;

  static bool isReloadingOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ReportReloadScope>()
            ?.isReloading ??
        false;
  }

  @override
  bool updateShouldNotify(ReportReloadScope oldWidget) =>
      isReloading != oldWidget.isReloading;
}

/// Semi-transparent overlay with spinner — use around the table body only.
class ReportTableArea extends StatelessWidget {
  const ReportTableArea({required this.child, super.key});

  final Widget child;

  static const _minOverlayHeight = 160.0;

  @override
  Widget build(BuildContext context) {
    final isReloading = ReportReloadScope.isReloadingOf(context);
    if (!isReloading) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : _minOverlayHeight;

        return SizedBox(
          height: constraints.maxHeight.isFinite ? null : height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.background.withValues(alpha: 0.72),
                  child: const Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReportAsyncBody<T> extends ConsumerWidget {
  const ReportAsyncBody({
    required this.value,
    required this.data,
    required this.onRetry,
    this.loadingMessage = 'Loading report…',
    this.empty,
    this.isEmpty,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback onRetry;
  final String loadingMessage;
  final Widget? empty;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTableLoading = ref.watch(
      reportFiltersProvider.select((filters) => filters.isTableLoading),
    );
    final isReloading = reportIsTableReloading(value, isTableLoading);
    final isOffline =
        ref.watch(connectivityStatusProvider).value ==
        SyncConnectivityStatus.offline;

    final previous = value.asData?.value;

    return ReportReloadScope(
      isReloading: isReloading,
      child: value.when(
        skipLoadingOnReload: true,
        loading: () {
          if (previous != null) {
            return RefreshIndicator(
              onRefresh: () async => onRetry(),
              child: data(previous),
            );
          }
          return const ReportLoadingSkeleton();
        },
        error: (error, _) {
          if (previous == null && ReportsErrorMapper.isTransientLoadError(error)) {
            return const ReportLoadingSkeleton();
          }
          if (previous != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: AppColors.error.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ReportsErrorMapper.messageFor(error),
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: onRetry,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => onRetry(),
                    child: data(previous),
                  ),
                ),
              ],
            );
          }
          return AppError(
            message: ReportsErrorMapper.messageFor(error),
            onRetry: onRetry,
          );
        },
        data: (result) {
          if (empty != null &&
              (isEmpty?.call(result) ?? _defaultIsEmpty(result))) {
            if (isOffline) {
              return AppError(
                message: OfflineUiMessages.noLocalDataYet,
                onRetry: onRetry,
              );
            }

            return empty!;
          }

          return RefreshIndicator(
            onRefresh: () async => onRetry(),
            child: data(result),
          );
        },
      ),
    );
  }

  bool _defaultIsEmpty(T result) {
    if (result is List) return result.isEmpty;
    return false;
  }
}

class ReportPaginationBar extends StatelessWidget {
  const ReportPaginationBar({
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final int page;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Page $page of $totalPages'),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
