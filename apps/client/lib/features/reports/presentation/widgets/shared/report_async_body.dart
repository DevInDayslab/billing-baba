import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_error.dart';
import 'package:billing_baba/core/widgets/app_loader.dart';
import 'package:billing_baba/features/reports/application/reports_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportAsyncBody<T> extends StatelessWidget {
  const ReportAsyncBody({
    required this.value,
    required this.data,
    required this.onRetry,
    this.loadingMessage = 'Loading report…',
    this.empty,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback onRetry;
  final String loadingMessage;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => AppLoader(message: loadingMessage),
      error: (error, _) => AppError(
        message: ReportsErrorMapper.messageFor(error),
        onRetry: onRetry,
      ),
      data: (result) {
        if (empty != null && _isEmpty(result)) {
          return empty!;
        }
        return RefreshIndicator(
          onRefresh: () async => onRetry(),
          child: data(result),
        );
      },
    );
  }

  bool _isEmpty(T result) => false;
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
