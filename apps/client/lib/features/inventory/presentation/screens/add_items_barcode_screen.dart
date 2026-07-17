import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/providers/barcode_import_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/barcode_items_grid.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/barcode_save_error_dialog.dart';
import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _statusGreen = Color(0xFF2E7D32);
const _statusGreenBackground = Color(0xFFE8F5E9);
const _statusGreenBorder = Color(0xFFA5D6A7);
const _statusRed = Color(0xFFC62828);
const _statusRedBackground = Color(0xFFFFEBEE);
const _statusRedBorder = Color(0xFFEF9A9A);

/// Bulk-adding inventory items via hardware keyboard barcode scanner.
class AddItemsBarcodeScreen extends ConsumerStatefulWidget {
  const AddItemsBarcodeScreen({super.key});

  @override
  ConsumerState<AddItemsBarcodeScreen> createState() =>
      _AddItemsBarcodeScreenState();
}

class _AddItemsBarcodeScreenState extends ConsumerState<AddItemsBarcodeScreen> {
  final StringBuffer _barcodeBuffer = StringBuffer();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _onHardwareKey(KeyEvent event) {
    if (event is KeyDownEvent &&
        HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyS) {
      unawaited(_handleSave(andNew: false));
      return true;
    }
    if (event is KeyDownEvent &&
        HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyN) {
      unawaited(_handleSave(andNew: true));
      return true;
    }
    if (event is KeyDownEvent &&
        HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyF) {
      _searchFocusNode.requestFocus();
      return true;
    }
    if (event is KeyDownEvent &&
        HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyV) {
      unawaited(_handlePaste());
      return true;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    return _continueKeyEvent(event);
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final pasted = data?.text?.trim() ?? '';
    if (pasted.isEmpty || pasted.length < 3) return;
    final nextIndex =
        ref.read(barcodeImportProvider.notifier).nextEmptyRowIndex;
    ref.read(barcodeImportProvider.notifier).updateLiveInput(nextIndex, '');
    ref.read(barcodeImportProvider.notifier).startLookup(nextIndex, pasted);
  }

  bool _isTextInputFocused() {
    if (_searchFocusNode.hasFocus) return true;

    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null || !primaryFocus.hasFocus) return false;

    final focusContext = primaryFocus.context;
    if (focusContext == null) return false;

    return focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _continueKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    final isModifierHeld = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isAltPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    if (isModifierHeld) return false;

    final skipKeys = {
      LogicalKeyboardKey.tab,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.f1,
      LogicalKeyboardKey.f2,
      LogicalKeyboardKey.f3,
      LogicalKeyboardKey.f4,
      LogicalKeyboardKey.f5,
      LogicalKeyboardKey.f6,
      LogicalKeyboardKey.f7,
      LogicalKeyboardKey.f8,
      LogicalKeyboardKey.f9,
      LogicalKeyboardKey.f10,
      LogicalKeyboardKey.f11,
      LogicalKeyboardKey.f12,
    };
    if (skipKeys.contains(event.logicalKey)) return false;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isTextInputFocused()) return false;
      _barcodeBuffer.clear();
      _searchFocusNode.unfocus();
      final notifier = ref.read(barcodeImportProvider.notifier);
      notifier.updateLiveInput(notifier.nextEmptyRowIndex, '');
      return true;
    }

    if (_isTextInputFocused()) return false;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_barcodeBuffer.isNotEmpty) {
          final current = _barcodeBuffer.toString();
          _barcodeBuffer.clear();
          _barcodeBuffer.write(current.substring(0, current.length - 1));
          final notifier = ref.read(barcodeImportProvider.notifier);
          notifier.updateLiveInput(
            notifier.nextEmptyRowIndex,
            _barcodeBuffer.toString(),
          );
        }
        return true;
      }
    }

    if (event is! KeyDownEvent) return false;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final barcode = _barcodeBuffer.toString().trim();
      _barcodeBuffer.clear();

      final notifier = ref.read(barcodeImportProvider.notifier);
      final rowIndex = notifier.nextEmptyRowIndex;
      if (barcode.isEmpty || barcode.length < 3) {
        notifier.updateLiveInput(rowIndex, '');
        return true;
      }

      notifier.updateLiveInput(rowIndex, '');
      notifier.startLookup(rowIndex, barcode);

      return true;
    }

    final character = event.character;
    if (character != null &&
        character.isNotEmpty &&
        character != '\n' &&
        character != '\r') {
      _barcodeBuffer.write(character);
      final notifier = ref.read(barcodeImportProvider.notifier);
      notifier.updateLiveInput(
        notifier.nextEmptyRowIndex,
        _barcodeBuffer.toString(),
      );
      return true;
    }

    return false;
  }

  Future<void> _handleSave({required bool andNew}) async {
    if (_isSaving) return;
    _isSaving = true;
    try {
      final notifier = ref.read(barcodeImportProvider.notifier);
      final errorRows = notifier.getRowsWithErrors();

      if (errorRows.isNotEmpty) {
        final ignore = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => BarcodeSaveErrorDialog(errorRows: errorRows),
        );
        if (ignore != true) return;
      }

      final categories = ref.read(categoriesProvider);
      final units = ref.read(unitsProvider);

      final saveError = await notifier.saveItems(
        ignoreErrors: errorRows.isNotEmpty,
        categories: categories,
        units: units,
      );

      if (!mounted) return;

      if (saveError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Items Added — items successfully added'),
          ),
        );
        if (andNew) {
          ref.invalidate(barcodeImportProvider);
        } else {
          context.pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save items: $saveError'),
          ),
        );
      }
    } finally {
      _isSaving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(barcodeImportProvider);
    final emptyIndex = rows.indexWhere(
      (row) => row.status == BarcodeRowStatus.empty,
    );
    final activeRowIndex = emptyIndex == -1 ? rows.length : emptyIndex;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: GestureDetector(
        onTap: () => _searchFocusNode.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            Expanded(
              child: BarcodeItemsGrid(
                rows: rows,
                activeRowIndex: activeRowIndex,
                onFieldChanged: (rowIndex, field, value) {
                  ref
                      .read(barcodeImportProvider.notifier)
                      .updateField(rowIndex, field, value);
                },
                onSetManualEntry: (rowIndex) {
                  ref
                      .read(barcodeImportProvider.notifier)
                      .setManualEntry(rowIndex);
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Text(
            'Add Items',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.titleLargeSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          _buildStatusChip(),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final rows = ref.watch(barcodeImportProvider);
    final hasError = ref.watch(barcodeImportLookupErrorProvider);
    final isLoading = rows.any(
      (row) => row.status == BarcodeRowStatus.loading,
    );

    final label = hasError
        ? '● ERROR'
        : isLoading
        ? '● ONLINE: FETCHING FROM LIBRARY'
        : '● ONLINE';
    final textColor = hasError ? _statusRed : _statusGreen;
    final backgroundColor = hasError ? _statusRedBackground : _statusGreenBackground;
    final borderColor = hasError ? _statusRedBorder : _statusGreenBorder;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: SizedBox(
        height: FormSpacing.inputHeight,
        child: TextField(
          autofocus: false,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search in sheet',
            hintStyle: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.bodyMediumSize,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: Colors.grey.shade500,
            ),
            suffix: const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Text(
                '[Ctrl+F]',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.captionSize,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            filled: true,
            fillColor: AppColors.background,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: _cardBorder),
        ),
      ),
      child: SizedBox(
        height: FormSpacing.footerHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              const Spacer(),
              OutlinedButton(
                onPressed: () => _handleSave(andNew: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: _cardBorder),
                  minimumSize: const Size(0, FormSpacing.inputHeight),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Save & New [Ctrl+N]',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton(
                onPressed: () => _handleSave(andNew: false),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(0, FormSpacing.inputHeight),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Save [Ctrl+S]',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
