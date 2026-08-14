import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';

/// Mobile transaction form shell with scroll body and sticky save actions.
class MobileFormScaffold extends StatelessWidget {
  const MobileFormScaffold({
    required this.title,
    required this.body,
    super.key,
    this.onBack,
    this.isLoading = false,
    this.isSaving = false,
    this.loadingLabel,
    this.primaryActionLabel = 'Save',
    this.secondaryActionLabel,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.topBanner,
    this.readOnly = false,
  });

  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final bool isLoading;
  final bool isSaving;
  final String? loadingLabel;
  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final Widget? topBanner;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final busy = isLoading || isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: title,
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
        showBackButton: true,
        onBack: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (topBanner != null) topBanner!,
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    120,
                  ),
                  child: body,
                ),
              ),
            ],
          ),
          if (!readOnly)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                elevation: 4,
                color: AppColors.surface,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        if (secondaryActionLabel != null &&
                            onSecondaryAction != null) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: busy ? null : onSecondaryAction,
                              child: Text(secondaryActionLabel!),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(
                          flex: secondaryActionLabel != null ? 1 : 2,
                          child: FilledButton(
                            onPressed: busy ? null : onPrimaryAction,
                            child: Text(primaryActionLabel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (busy)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            loadingLabel ??
                                (isSaving ? 'Saving…' : 'Loading…'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
