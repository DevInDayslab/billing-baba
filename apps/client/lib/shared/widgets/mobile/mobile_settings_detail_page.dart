import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';

/// Reusable mobile scaffold for a single global settings detail screen.
///
/// Wrap any settings form or read-only content in [body]. Use [onSave] with
/// [saveLabel] for a sticky bottom action, or pass [actions] for app-bar actions.
class MobileSettingsDetailPage extends StatelessWidget {
  const MobileSettingsDetailPage({
    required this.title,
    required this.body,
    super.key,
    this.subtitle,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.saveLabel,
    this.onSave,
    this.isSaving = false,
    this.saveEnabled = true,
    this.actions,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? saveLabel;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool saveEnabled;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final showSaveBar = saveLabel != null && onSave != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: title,
        showBackButton: true,
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
        actions: actions,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              Expanded(
                child: _buildBody(context),
              ),
              if (showSaveBar)
                _SaveBar(
                  label: saveLabel!,
                  onPressed: saveEnabled && !isSaving ? onSave : null,
                  isSaving: isSaving,
                ),
            ],
          ),
          if (isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66FFFFFF),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding:
          padding ??
          EdgeInsets.fromLTRB(
            AppSpacing.lg,
            subtitle != null ? AppSpacing.md : AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
      child: body,
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.label,
    required this.onPressed,
    required this.isSaving,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onPressed,
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}
