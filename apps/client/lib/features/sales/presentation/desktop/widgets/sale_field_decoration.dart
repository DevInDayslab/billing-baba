import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const saleFieldBorderColor = Color(0xFFE0E0E0);
const saleCompactFieldBorderColor = Color(0xFFBDBDBD);

/// Compact table-cell / header control height (qty, price, invoice header).
const saleCompactFieldHeight = 30.0;

/// Standard form control height — matches [FormSpacing.inputHeight] so TextField
/// and select/dropdown triggers stay aligned in party / sale / purchase dialogs.
const double saleFieldHeight = FormSpacing.inputHeight;

const _compactBorderRadius = 4.0;
const _standardBorderRadius = 6.0;
const saleFieldFocusColor = Color(0xFF42A5F5);
const saleFieldErrorColor = Color(0xFFD32F2F);
const saleFieldTextStyle = TextStyle(
  fontSize: 14,
  height: 1.2,
  color: AppColors.textPrimary,
);
const saleFieldLabelStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w500,
  color: AppColors.textSecondary,
);

double saleFieldControlHeight({required bool compact}) =>
    compact ? saleCompactFieldHeight : saleFieldHeight;

double saleFieldBorderRadius({required bool compact}) =>
    compact ? _compactBorderRadius : _standardBorderRadius;

Color saleFieldBorderSideColor({
  required bool hasError,
  required bool compact,
}) {
  if (hasError) return saleFieldErrorColor;
  return compact ? saleCompactFieldBorderColor : saleFieldBorderColor;
}

/// Shared outer shell so text inputs and selects paint the same box height.
class SaleFieldChrome extends StatelessWidget {
  const SaleFieldChrome({
    required this.child,
    this.hasError = false,
    this.compact = false,
    this.filled = false,
    this.onTap,
    this.height,
    super.key,
  });

  final Widget child;
  final bool hasError;
  final bool compact;
  final bool filled;
  final VoidCallback? onTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final height = this.height ?? saleFieldControlHeight(compact: compact);
    final radius = saleFieldBorderRadius(compact: compact);
    final borderColor = saleFieldBorderSideColor(
      hasError: hasError,
      compact: compact,
    );

    // No [alignment] — Align would loosen height and top-bias TextField text.
    // Child receives a tight height so inputs/selects can center content.
    final box = Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: compact || filled
            ? (filled && !compact ? const Color(0xFFF9F9F9) : Colors.white)
            : Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );

    if (onTap == null) return box;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: box,
    );
  }
}

/// Single-line text field that matches [SaleFieldTrigger] height exactly.
class SaleTextField extends StatelessWidget {
  const SaleTextField({
    required this.controller,
    this.hint,
    this.hasError = false,
    this.compact = false,
    this.filled = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.prefix,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.borderless = false,
    this.controlHeight,
    super.key,
  });

  final TextEditingController controller;
  final String? hint;
  final bool hasError;
  final bool compact;
  final bool filled;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final bool borderless;
  final double? controlHeight;

  @override
  Widget build(BuildContext context) {
    final fieldHeight =
        controlHeight ?? saleFieldControlHeight(compact: compact);
    final fontSize = compact ? 12.0 : 14.0;
    // Keep the editable line short, then center it in the chrome — stretching
    // the TextField makes desktop text sit at the top of the box.
    final lineBoxHeight = fontSize + 4;

    final textField = TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      readOnly: readOnly,
      enabled: enabled,
      textAlign: textAlign,
      textAlignVertical: TextAlignVertical.center,
      textCapitalization: textCapitalization,
      style: (style ?? saleFieldTextStyle).copyWith(
        fontSize: fontSize,
        height: 1,
      ),
      strutStyle: StrutStyle(
        fontSize: fontSize,
        height: 1,
        forceStrutHeight: true,
        leading: 0,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      buildCounter: maxLength == null
          ? null
          : (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
      cursorHeight: fontSize,
      scrollPadding: EdgeInsets.zero,
      decoration: InputDecoration(
        isDense: true,
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: fontSize,
          height: 1,
        ),
      ),
      onChanged: onChanged,
      onTap: onTap,
      onSubmitted: onSubmitted,
    );

    final content = Row(
      children: [
        if (prefix != null) ...[
          prefix!,
          const SizedBox(width: 4),
        ],
        Expanded(
          child: SizedBox(
            height: lineBoxHeight,
            child: textField,
          ),
        ),
        ?suffixIcon,
      ],
    );

    final centered = Align(
      alignment: _alignmentFor(textAlign),
      child: content,
    );

    if (borderless) {
      return SizedBox(
        height: fieldHeight,
        width: double.infinity,
        child: centered,
      );
    }

    return SaleFieldChrome(
      hasError: hasError,
      compact: compact,
      filled: filled,
      height: controlHeight,
      child: centered,
    );
  }

  static Alignment _alignmentFor(TextAlign align) {
    return switch (align) {
      TextAlign.center => Alignment.center,
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      _ => Alignment.centerLeft,
    };
  }
}

double _verticalPaddingForHeight(
  double fieldHeight, {
  required double fontSize,
}) {
  final textLine = fontSize * 1.2;
  return ((fieldHeight - textLine - 2) / 2).clamp(0.0, fieldHeight / 2);
}

/// Vyapar-style field decoration shared across sale/purchase/party forms.
///
/// Prefer [SaleTextField] for single-line inputs so height matches selects.
/// Set [fixedHeight] to false for multiline fields (e.g. billing address).
InputDecoration buildSaleFieldDecoration({
  String? hint,
  String? labelText,
  Widget? suffixIcon,
  Widget? suffix,
  bool hasError = false,
  bool filled = false,
  bool compact = false,
  bool borderless = false,
  bool fixedHeight = true,
  EdgeInsetsGeometry? contentPadding,
}) {
  final fieldHeight = saleFieldControlHeight(compact: compact);
  final fontSize = compact ? 12.0 : 14.0;
  final verticalPadding = !fixedHeight
      ? (compact ? 8.0 : 10.0)
      : compact
      ? (saleCompactFieldHeight - 12 - 2) / 2
      : _verticalPaddingForHeight(fieldHeight, fontSize: fontSize);

  if (borderless) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: fontSize,
        height: 1.2,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 12,
        vertical: compact ? 8 : verticalPadding,
      ),
      isDense: true,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      suffixIcon: suffixIcon,
      suffix: suffix,
      suffixIconConstraints: BoxConstraints(
        minWidth: fieldHeight - 8,
        minHeight: fieldHeight - 2,
        maxHeight: fieldHeight - 2,
      ),
    );
  }

  final borderColor = saleFieldBorderSideColor(
    hasError: hasError,
    compact: compact,
  );
  final focusedBorderColor = hasError
      ? saleFieldErrorColor
      : saleFieldFocusColor;
  final borderRadius = saleFieldBorderRadius(compact: compact);

  final useFloatingLabel = labelText != null && labelText.isNotEmpty;

  return InputDecoration(
    labelText: useFloatingLabel ? labelText : null,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    alignLabelWithHint: true,
    labelStyle: TextStyle(
      color: Colors.grey.shade500,
      fontSize: fontSize,
      height: 1.2,
    ),
    floatingLabelStyle: TextStyle(
      color: hasError ? saleFieldErrorColor : Colors.grey.shade600,
      fontSize: compact ? 10 : 11,
      height: 1.1,
    ),
    hintText: useFloatingLabel ? null : hint,
    hintStyle: TextStyle(
      color: Colors.grey.shade400,
      fontSize: fontSize,
      height: 1.2,
    ),
    contentPadding:
        contentPadding ??
        EdgeInsets.symmetric(
          horizontal: compact ? 6 : 12,
          vertical: useFloatingLabel ? (compact ? 10 : 12) : verticalPadding,
        ),
    isDense: !useFloatingLabel,
    constraints: fixedHeight
        ? BoxConstraints.tightFor(height: fieldHeight)
        : null,
    suffixIconConstraints: BoxConstraints(
      minWidth: fieldHeight - 8,
      minHeight: fieldHeight - 2,
      maxHeight: fieldHeight - 2,
    ),
    filled: compact || filled,
    fillColor: compact
        ? Colors.white
        : (filled ? const Color(0xFFF9F9F9) : null),
    suffixIcon: suffixIcon,
    suffix: suffix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: const BorderSide(color: saleFieldErrorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: const BorderSide(color: saleFieldErrorColor, width: 1.5),
    ),
  );
}

/// Fixed-height shell so compact text fields, dropdowns, and date triggers align.
class SaleCompactFieldBox extends StatelessWidget {
  const SaleCompactFieldBox({
    required this.child,
    this.width,
    this.height,
    this.bordered = false,
    super.key,
  });

  final Widget child;
  final double? width;
  final double? height;

  /// When true, paints the white bordered shell used in line-item grids.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final boxHeight = height ?? saleCompactFieldHeight;
    final Widget field;
    if (bordered) {
      field = SaleFieldChrome(
        compact: true,
        height: boxHeight,
        child: child,
      );
    } else {
      field = SizedBox(
        height: boxHeight,
        child: child,
      );
    }

    if (width != null) {
      return SizedBox(width: width, child: field);
    }
    return field;
  }
}

/// Fixed-height shell for standard (non-compact) text fields.
class SaleFieldBox extends StatelessWidget {
  const SaleFieldBox({
    required this.child,
    this.width,
    this.compact = false,
    super.key,
  });

  final Widget child;
  final double? width;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      height: saleFieldControlHeight(compact: compact),
      width: double.infinity,
      child: child,
    );

    if (width != null) {
      return SizedBox(width: width, child: field);
    }
    return field;
  }
}

/// Trigger shell for picker/dropdown fields that mirrors [SaleTextField].
class SaleFieldTrigger extends StatelessWidget {
  const SaleFieldTrigger({
    required this.child,
    required this.onTap,
    this.hasError = false,
    this.compact = false,
    this.borderless = false,
    this.height,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool hasError;
  final bool compact;
  final bool borderless;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final fieldHeight = height ?? saleFieldControlHeight(compact: compact);

    if (borderless) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: SizedBox(
            width: double.infinity,
            height: fieldHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        ),
      );
    }

    return SaleFieldChrome(
      onTap: onTap,
      hasError: hasError,
      compact: compact,
      height: height,
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }
}
