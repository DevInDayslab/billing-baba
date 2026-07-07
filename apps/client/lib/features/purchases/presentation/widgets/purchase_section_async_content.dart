import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a centered loading indicator (or error + retry) while purchase section
/// data is being fetched from the API.
class PurchaseSectionAsyncContent<T> extends StatelessWidget {
  const PurchaseSectionAsyncContent({
    required this.value,
    required this.builder,
    this.onRetry,
    this.minHeight = 400,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => SizedBox(
        height: minHeight,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SizedBox(
        height: minHeight,
        child: Center(
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
      ),
      data: builder,
    );
  }
}
