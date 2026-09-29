import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _fieldTextStyle = TextStyle(
  color: AppColors.textPrimary,
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

const _dropdownItemStyle = TextStyle(
  color: AppColors.textPrimary,
  fontSize: 14,
);

class BusinessFormSectionHeader extends StatelessWidget {
  const BusinessFormSectionHeader({
    required this.title,
    required this.icon,
    super.key,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class BusinessFormField extends StatelessWidget {
  const BusinessFormField({
    required this.icon,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLines = 1,
    this.serverError,
    this.readOnly = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? serverError;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: readOnly
          ? _fieldTextStyle.copyWith(color: AppColors.textSecondary)
          : _fieldTextStyle,
      validator: (value) => serverError ?? validator?.call(value),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: businessFormFieldDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }
}

class BusinessFormDropdown extends StatelessWidget {
  const BusinessFormDropdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.serverError,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final String? serverError;

  @override
  Widget build(BuildContext context) {
    final effectiveItems = _effectiveItems();

    return DropdownButtonFormField<String>(
      initialValue: value,
      style: _fieldTextStyle,
      dropdownColor: Colors.white,
      iconEnabledColor: AppColors.textSecondary,
      iconDisabledColor: AppColors.textSecondary.withValues(alpha: 0.5),
      validator: (v) => serverError ?? validator?.call(v),
      decoration: businessFormFieldDecoration(
        label: label,
        icon: icon,
      ),
      items: effectiveItems
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: _dropdownItemStyle),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => effectiveItems
          .map(
            (item) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                item,
                style: _fieldTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  List<String> _effectiveItems() {
    if (value == null || value!.isEmpty || items.contains(value)) {
      return items;
    }
    return [value!, ...items];
  }
}

InputDecoration businessFormFieldDecoration({
  required String label,
  required IconData icon,
  String? hint,
  String? errorText,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorText: errorText,
    labelStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 14,
    ),
    floatingLabelStyle: const TextStyle(
      color: AppColors.primary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(
      color: AppColors.textSecondary.withValues(alpha: 0.75),
      fontSize: 14,
    ),
    prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  );
}

/// Responsive two-column form row. Stacks vertically on narrow widths.
class BusinessFormRow extends StatelessWidget {
  const BusinessFormRow({
    required this.left,
    required this.right,
    this.spacing = AppSpacing.md,
    super.key,
  });

  final Widget left;
  final Widget right;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 480;
        if (!useTwoColumns) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              SizedBox(height: spacing),
              right,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: spacing),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class BusinessFormFullWidthField extends StatelessWidget {
  const BusinessFormFullWidthField({
    required this.child,
    this.spacing = AppSpacing.md,
    super.key,
  });

  final Widget child;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: spacing),
      child: child,
    );
  }
}

const _outlinedFieldBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(6)),
  borderSide: BorderSide(color: Color(0xFFCCCCCC)),
);

const _outlinedFieldErrorBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(6)),
  borderSide: BorderSide(color: AppColors.error),
);

InputDecoration businessOutlinedFieldDecoration({
  String? hint,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey),
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    border: _outlinedFieldBorder,
    enabledBorder: _outlinedFieldBorder,
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      borderSide: BorderSide(color: AppColors.primary),
    ),
    errorBorder: _outlinedFieldErrorBorder,
    focusedErrorBorder: _outlinedFieldErrorBorder,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm + 4,
      vertical: AppSpacing.sm + 4,
    ),
  );
}

class BusinessProfileSectionHeader extends StatelessWidget {
  const BusinessProfileSectionHeader({
    required this.title,
    this.icon,
    super.key,
  });

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );

    if (icon == null) return titleWidget;

    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        titleWidget,
      ],
    );
  }
}

class BusinessLabeledField extends StatelessWidget {
  const BusinessLabeledField({
    required this.label,
    required this.child,
    this.required = false,
    super.key,
  });

  final String label;
  final Widget child;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class BusinessOutlinedField extends StatelessWidget {
  const BusinessOutlinedField({
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.minLines = 1,
    this.maxLines = 1,
    this.serverError,
    this.suffixIcon,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int minLines;
  final int maxLines;
  final String? serverError;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      validator: (value) => serverError ?? validator?.call(value),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      decoration: businessOutlinedFieldDecoration(
        hint: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class BusinessOutlinedDropdown extends StatelessWidget {
  const BusinessOutlinedDropdown({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.serverError,
    super.key,
  });

  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final String? serverError;

  @override
  Widget build(BuildContext context) {
    final effectiveItems = _effectiveItems();

    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(
        'Select $hintText',
        style: const TextStyle(color: Colors.grey),
      ),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black87),
      decoration: businessOutlinedFieldDecoration(),
      isExpanded: true,
      validator: (v) => serverError ?? validator?.call(v),
      items: effectiveItems
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  List<String> _effectiveItems() {
    if (value == null || value!.isEmpty || items.contains(value)) {
      return items;
    }
    return [value!, ...items];
  }
}

/// Outlined dropdown with a type-to-filter overlay.
class BusinessSearchableDropdown extends StatelessWidget {
  const BusinessSearchableDropdown({
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.serverError,
    this.itemLabel,
    super.key,
  });

  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final String? serverError;
  final String Function(String value)? itemLabel;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: (v) => serverError ?? validator?.call(v),
      builder: (field) {
        return _BusinessSearchableDropdownControl(
          hintText: hintText,
          items: items,
          value: field.value,
          hasError: field.hasError,
          errorText: field.errorText,
          itemLabel: itemLabel,
          onChanged: (selected) {
            field.didChange(selected);
            onChanged(selected);
          },
        );
      },
    );
  }
}

class _BusinessSearchableDropdownControl extends StatefulWidget {
  const _BusinessSearchableDropdownControl({
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
    this.hasError = false,
    this.errorText,
    this.itemLabel,
  });

  final String hintText;
  final List<String> items;
  final String? value;
  final bool hasError;
  final String? errorText;
  final String Function(String value)? itemLabel;
  final ValueChanged<String?> onChanged;

  @override
  State<_BusinessSearchableDropdownControl> createState() =>
      _BusinessSearchableDropdownControlState();
}

class _BusinessSearchableDropdownControlState
    extends State<_BusinessSearchableDropdownControl> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  final FocusNode _searchFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';

  List<String> get _effectiveItems {
    final value = widget.value;
    if (value == null || value.isEmpty || widget.items.contains(value)) {
      return widget.items;
    }
    return [value, ...widget.items];
  }

  String _labelFor(String value) => widget.itemLabel?.call(value) ?? value;

  @override
  void dispose() {
    _removeOverlay();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  List<String> _filteredOptions(String query) {
    if (query.isEmpty) return _effectiveItems;
    final normalized = query.toLowerCase();
    return _effectiveItems
        .where((option) {
          return option.toLowerCase().contains(normalized) ||
              _labelFor(option).toLowerCase().contains(normalized);
        })
        .toList();
  }

  void _selectOption(String option) {
    _removeOverlay();
    widget.onChanged(option);
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _searchQuery = '';
    FocusManager.instance.primaryFocus?.unfocus();
    _showOverlay();
  }

  void _showOverlay() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final menuWidth = renderBox.size.width;
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return StatefulBuilder(
          builder: (context, setOverlayState) {
            final filtered = _filteredOptions(_searchQuery);
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _removeOverlay,
                  ),
                ),
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  targetAnchor: Alignment.bottomLeft,
                  offset: const Offset(0, 4),
                  child: Material(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    color: AppColors.surface,
                    borderRadius: AppRadius.smBorder,
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: menuWidth,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.sm,
                                AppSpacing.sm,
                                AppSpacing.sm,
                                AppSpacing.xs,
                              ),
                              child: TextField(
                                focusNode: _searchFocusNode,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Search ${widget.hintText}',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.sm,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.smBorder,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 18,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 13),
                                onChanged: (value) {
                                  setOverlayState(() => _searchQuery = value);
                                },
                              ),
                            ),
                            if (filtered.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Text(
                                  'No matches',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            else
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final option = filtered[index];
                                    final selected = option == widget.value;
                                    return InkWell(
                                      onTap: () => _selectOption(option),
                                      child: Container(
                                        color: selected
                                            ? const Color(0xFFF5F5F5)
                                            : null,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm + 2,
                                        ),
                                        child: Text(
                                          _labelFor(option),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    overlay.insert(_overlayEntry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _overlayEntry == null) return;
      _searchFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null && widget.value!.isNotEmpty;
    final border = widget.hasError
        ? _outlinedFieldErrorBorder
        : _outlinedFieldBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: Material(
            key: _triggerKey,
            color: Colors.white,
            child: InkWell(
              onTap: _toggleOverlay,
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              child: InputDecorator(
                decoration: businessOutlinedFieldDecoration().copyWith(
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border,
                  errorBorder: border,
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ),
                child: Text(
                  hasValue
                      ? _labelFor(widget.value!)
                      : 'Select ${widget.hintText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasValue ? Colors.black87 : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.hasError && widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
