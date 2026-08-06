import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_document_visibility.dart';
import 'package:flutter/material.dart';

/// Shared mobile document create scaffold matching Add Sale visual language.
class MobileDocumentFormScaffold extends StatefulWidget {
  const MobileDocumentFormScaffold({
    required this.title,
    required this.body,
    required this.visibility,
    required this.onClose,
    required this.onSave,
    super.key,
    this.onSaveAndNew,
    this.onMore,
    this.appBarActions = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.readOnly = false,
    this.leadingToggle,
  });

  final String title;
  final Widget body;
  final MobileDocumentVisibility visibility;

  /// Called when the user tries to leave. Return `true` to pop the route.
  final Future<bool> Function() onClose;
  final VoidCallback? onSave;
  final VoidCallback? onSaveAndNew;
  final VoidCallback? onMore;
  final List<Widget> appBarActions;
  final bool isLoading;
  final bool isSaving;
  final bool readOnly;
  final Widget? leadingToggle;

  @override
  State<MobileDocumentFormScaffold> createState() =>
      _MobileDocumentFormScaffoldState();
}

class _MobileDocumentFormScaffoldState
    extends State<MobileDocumentFormScaffold> {
  var _allowPop = false;
  var _closing = false;

  Future<void> _requestClose() async {
    if (_closing || _allowPop) return;
    _closing = true;
    try {
      final shouldClose = await widget.onClose();
      if (!mounted || !shouldClose) return;
      setState(() => _allowPop = true);
      // Explicit pop — do not use maybePop while PopScope.canPop was false.
      Navigator.of(context).pop();
    } finally {
      _closing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _requestClose();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _requestClose,
          ),
          title: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (widget.leadingToggle != null) ...[
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: widget.leadingToggle,
              ),
            ],
            ...widget.appBarActions,
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: IgnorePointer(
                  ignoring: widget.readOnly,
                  child: Opacity(
                    opacity: widget.readOnly ? 0.85 : 1,
                    child: widget.body,
                  ),
                ),
              ),
            ),
            if (!widget.readOnly)
              MobileSaleBottomBar(
                isSaving: widget.isSaving,
                onSave: widget.onSave,
                onSaveAndNew: widget.visibility.showSaveAndNew
                    ? widget.onSaveAndNew
                    : null,
                onMore: widget.onMore ?? () {},
              ),
          ],
        ),
      ),
    );
  }
}
