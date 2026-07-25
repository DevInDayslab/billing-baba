import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportSearchField extends ConsumerStatefulWidget {
  const ReportSearchField({
    this.hintText = 'Search...',
    this.onChanged,
    super.key,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  ConsumerState<ReportSearchField> createState() => _ReportSearchFieldState();
}

class _ReportSearchFieldState extends ConsumerState<ReportSearchField> {
  late final TextEditingController _controller;
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(reportFiltersProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debouncer.run(() {
      if (!mounted) return;
      if (widget.onChanged != null) {
        widget.onChanged!(value);
      } else {
        ref.read(reportFiltersProvider.notifier).setSearchQuery(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reportFiltersProvider.select((s) => s.searchQuery), (
      _,
      next,
    ) {
      if (_controller.text != next) {
        _debouncer.cancel();
        _controller.text = next;
        _controller.selection = TextSelection.collapsed(offset: next.length);
      }
    });

    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: reportCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: reportCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: reportTeal),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}

class ReportEmptyTableState extends StatelessWidget {
  const ReportEmptyTableState({
    this.message = 'No data available',
    this.minHeight = 200,
    super.key,
  });

  final String message;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
