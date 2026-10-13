import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/settings/models/general_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GeneralSettingsSectionCard extends StatelessWidget {
  const GeneralSettingsSectionCard({
    required this.title,
    required this.children,
    this.titleTrailing,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: listPanelCardBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: ListPanelStyles.listHeaderStyle,
                ),
              ),
              if (titleTrailing != null) titleTrailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class GeneralSettingsDivider extends StatelessWidget {
  const GeneralSettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: listPanelCardBorder,
    );
  }
}

class GeneralSettingsCheckboxRow extends StatelessWidget {
  const GeneralSettingsCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.infoKey,
    this.indent = 0,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final GeneralSettingsInfoKey? infoKey;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: indent,
        top: AppSpacing.xs + 2,
        bottom: AppSpacing.xs + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged == null ? null : onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Text(
              label,
              style: AppTypography.inter(
                fontSize: AppTypography.bodyMediumSize,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (infoKey != null)
            SettingsInfoIconButton(heading: label, infoKey: infoKey!),
        ],
      ),
    );
  }
}

class GeneralSettingsLabeledField extends StatelessWidget {
  const GeneralSettingsLabeledField({
    required this.label,
    required this.infoKey,
    required this.child,
    super.key,
  });

  final String label;
  final GeneralSettingsInfoKey infoKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodyMediumSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SettingsInfoIconButton(heading: label, infoKey: infoKey),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

class GeneralSettingsDecimalField extends StatefulWidget {
  const GeneralSettingsDecimalField({
    required this.value,
    required this.onSubmitted,
    super.key,
  });

  final int value;
  final ValueChanged<int> onSubmitted;

  @override
  State<GeneralSettingsDecimalField> createState() =>
      _GeneralSettingsDecimalFieldState();
}

class _GeneralSettingsDecimalFieldState extends State<GeneralSettingsDecimalField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(GeneralSettingsDecimalField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = '${widget.value}';
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commit();
    }
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null) {
      _controller.text = '${widget.value}';
      return;
    }
    final clamped = parsed.clamp(0, 4);
    if (clamped != parsed) {
      _controller.text = '$clamped';
    }
    widget.onSubmitted(clamped);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        isDense: true,
        hintText: 'e.g. 0',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: listPanelCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: listPanelCardBorder),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
      onFieldSubmitted: (_) => _commit(),
      onEditingComplete: _commit,
      onTapOutside: (_) => _focusNode.unfocus(),
    );
  }
}
