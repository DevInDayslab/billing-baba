import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mobile bottom sheet for creating or editing a godown.
Future<GodownModel?> showMobileAddGodownSheet(
  BuildContext context, {
  GodownModel? editGodown,
}) {
  return showModalBottomSheet<GodownModel>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: AppColors.surface,
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: _AddGodownSheetBody(
                sheetContext: sheetContext,
                editGodown: editGodown,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AddGodownSheetBody extends ConsumerStatefulWidget {
  const _AddGodownSheetBody({
    required this.sheetContext,
    this.editGodown,
  });

  final BuildContext sheetContext;
  final GodownModel? editGodown;

  @override
  ConsumerState<_AddGodownSheetBody> createState() =>
      _AddGodownSheetBodyState();
}

class _AddGodownSheetBodyState extends ConsumerState<_AddGodownSheetBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final FocusNode _nameFocusNode;
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isEditing => widget.editGodown != null;

  static const _fieldBorderColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editGodown?.name ?? '',
    );
    _addressController = TextEditingController(
      text: widget.editGodown?.address ?? '',
    );
    _nameFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.75),
        fontSize: 14,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(_fieldBorderColor),
      enabledBorder: border(_fieldBorderColor),
      focusedBorder: border(AppColors.primary, width: 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 1.5),
    );
  }

  Future<void> _save() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(inventoryGodownsProvider.notifier);
    final result = _isEditing
        ? await notifier.updateGodown(
            widget.editGodown!.id,
            _nameController.text,
            address: _addressController.text,
          )
        : await notifier.addGodown(
            _nameController.text,
            address: _addressController.text,
          );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.error);
      return;
    }

    Navigator.of(widget.sheetContext).pop(result.godown);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Godown' : 'Add Godown';
    final actionLabel = _isEditing ? 'Save' : 'Create';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(widget.sheetContext).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textSecondary,
                iconSize: 22,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: _fieldDecoration('Enter Godown Name'),
            onChanged: (_) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _addressController,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: _fieldDecoration('Address (optional)'),
            onSubmitted: (_) => _save(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: MobileHomeAddSaleFab.accentRed,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: _isLoading ? null : _save,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          actionLabel,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
