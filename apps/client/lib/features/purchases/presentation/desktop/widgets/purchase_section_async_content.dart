import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Purchase section body with stale-while-revalidate loading.
///
/// Keeps the previous table/filters visible during reload and only shows a
/// full-screen spinner on the first load (when there is no cached value).
class PurchaseSectionAsyncContent<T> extends StatelessWidget {
  const PurchaseSectionAsyncContent({
    required this.value,
    required this.builder,
    this.onRetry,
    this.minHeight = 400,
    this.expand = false,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final double minHeight;
  final bool expand;

  Widget _loadingShell(Widget child) {
    if (expand) return child;
    return SizedBox(height: minHeight, child: child);
  }

  Widget _withReloadOverlay(Widget child, {required bool isReloading}) {
    if (!isReloading) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ColoredBox(
            color: AppColors.background.withValues(alpha: 0.55),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final previous = value.asData?.value;

    return value.when(
      skipLoadingOnReload: true,
      loading: () {
        if (previous != null) {
          return _withReloadOverlay(
            builder(previous),
            isReloading: true,
          );
        }
        return _loadingShell(
          const Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, _) {
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
                          PurchaseErrorMapper.messageFor(error),
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (onRetry != null)
                        TextButton(
                          onPressed: onRetry,
                          child: const Text('Retry'),
                        ),
                    ],
                  ),
                ),
              ),
              builder(previous),
            ],
          );
        }
        return _loadingShell(
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    PurchaseErrorMapper.messageFor(error),
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      data: (data) => _withReloadOverlay(
        builder(data),
        isReloading: value.isReloading,
      ),
    );
  }
}
