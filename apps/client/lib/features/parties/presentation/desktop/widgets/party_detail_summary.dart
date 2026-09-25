import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_name_stack.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';

const _partyDetailEmDash = '—';
const _compactFieldCount = 4;

enum _PartyDetailFieldId {
  phone,
  gstin,
  creditLimit,
  areaCode,
  type,
  email,
  loyaltyPoints,
}

class _PartyDetailFieldData {
  const _PartyDetailFieldData({
    required this.id,
    required this.label,
    required this.value,
  });

  final _PartyDetailFieldId id;
  final String label;
  final String? value;

  bool get isFilled => value != null && value!.trim().isNotEmpty;

  String get displayValue =>
      isFilled ? value!.trim() : _partyDetailEmDash;
}

/// Primary party fields shown in the detail header (Vyapar-style grid).
class PartyDetailPrimaryFields extends StatefulWidget {
  const PartyDetailPrimaryFields({
    required this.party,
    required this.creditLimitLabel,
    super.key,
  });

  final PartyModel party;
  final String creditLimitLabel;

  @override
  State<PartyDetailPrimaryFields> createState() =>
      _PartyDetailPrimaryFieldsState();
}

class _PartyDetailPrimaryFieldsState extends State<PartyDetailPrimaryFields> {
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant PartyDetailPrimaryFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.party.id != widget.party.id) {
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allFields = _orderedPartyDetailFields(
      party: widget.party,
      creditLimitLabel: widget.creditLimitLabel,
    );
    final compactFields = _compactPartyDetailFields(allFields);
    final compactIds = compactFields.map((field) => field.id).toSet();
    final remainderFields = allFields
        .where((field) => !compactIds.contains(field.id))
        .toList();
    final visibleFields = _expanded
        ? [...compactFields, ...remainderFields]
        : compactFields;

    return _PartyDetailFieldsCard(
      visibleFields: visibleFields,
      expanded: _expanded,
      onToggleExpanded: () => setState(() => _expanded = !_expanded),
    );
  }
}

class _PartyDetailFieldsCard extends StatelessWidget {
  const _PartyDetailFieldsCard({
    required this.visibleFields,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final List<_PartyDetailFieldData> visibleFields;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  static const _borderColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    if (visibleFields.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                12,
                AppSpacing.md,
                0,
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _PartyDetailFieldRows(fields: visibleFields),
              ),
            ),
          ),
          _PartyDetailExpandToggle(
            expanded: expanded,
            onPressed: onToggleExpanded,
          ),
        ],
      ),
    );
  }
}

class _PartyDetailFieldRows extends StatelessWidget {
  const _PartyDetailFieldRows({required this.fields});

  final List<_PartyDetailFieldData> fields;

  @override
  Widget build(BuildContext context) {
    if (fields.length <= _compactFieldCount) {
      return _PartyDetailFieldRow(fields: fields);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PartyDetailFieldRow(
          fields: fields.take(_compactFieldCount).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        _PartyDetailFieldRow(
          fields: fields.skip(_compactFieldCount).toList(),
        ),
      ],
    );
  }
}

class _PartyDetailFieldRow extends StatelessWidget {
  const _PartyDetailFieldRow({required this.fields});

  final List<_PartyDetailFieldData> fields;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _PartyDetailMetaCell(
              label: fields[i].label,
              value: fields[i].displayValue,
            ),
          ),
        ],
      ],
    );
  }
}

class _PartyDetailExpandToggle extends StatelessWidget {
  const _PartyDetailExpandToggle({
    required this.expanded,
    required this.onPressed,
  });

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 2),
          child: Center(
            child: Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

List<_PartyDetailFieldData> _orderedPartyDetailFields({
  required PartyModel party,
  required String creditLimitLabel,
}) {
  final phones = _phonesLabel(party);
  final gstin = party.gstin.trim();
  final areaCode = party.areaCode.trim();
  final email = party.email.trim();
  final loyalty = party.loyaltyPointsOpeningBalance.trim();

  return [
    _PartyDetailFieldData(
      id: _PartyDetailFieldId.phone,
      label: 'Phone',
      value: phones,
    ),
    _PartyDetailFieldData(
      id: _PartyDetailFieldId.gstin,
      label: 'GSTIN',
      value: gstin.isEmpty ? null : gstin,
    ),
    _PartyDetailFieldData(
      id: _PartyDetailFieldId.creditLimit,
      label: 'Credit Limit',
      value: creditLimitLabel,
    ),
    _PartyDetailFieldData(
      id: _PartyDetailFieldId.areaCode,
      label: 'Area Code',
      value: areaCode.isEmpty ? null : areaCode,
    ),
    _PartyDetailFieldData(
      id: _PartyDetailFieldId.type,
      label: 'Type',
      value: party.partyTypeLabel,
    ),
    _PartyDetailFieldData(
      id: _PartyDetailFieldId.email,
      label: 'Email',
      value: email.isEmpty ? null : email,
    ),
    _PartyDetailFieldData(
      id: _PartyDetailFieldId.loyaltyPoints,
      label: 'Loyalty Points',
      value: loyalty.isEmpty ? null : loyalty,
    ),
  ];
}

List<_PartyDetailFieldData> _compactPartyDetailFields(
  List<_PartyDetailFieldData> ordered,
) {
  final filled = <_PartyDetailFieldData>[];
  for (final field in ordered) {
    if (!field.isFilled) continue;
    filled.add(field);
    if (filled.length == _compactFieldCount) return filled;
  }

  if (filled.length == _compactFieldCount) return filled;

  final usedIds = filled.map((field) => field.id).toSet();
  for (final field in ordered) {
    if (filled.length >= _compactFieldCount) break;
    if (usedIds.contains(field.id)) continue;
    filled.add(
      _PartyDetailFieldData(
        id: field.id,
        label: field.label,
        value: null,
      ),
    );
    usedIds.add(field.id);
  }

  return filled;
}

String? _phonesLabel(PartyModel party) {
  final phones = <String>[
    if (party.phone.trim().isNotEmpty) party.phone.trim(),
    ...party.additionalPhones.map((p) => p.trim()).where((p) => p.isNotEmpty),
  ];
  if (phones.isEmpty) return null;
  return phones.join(', ');
}

class _PartyDetailMetaCell extends StatelessWidget {
  const _PartyDetailMetaCell({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        AppEllipsisText(
          value,
          style: const TextStyle(
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class PartyDetailNameBlock extends StatelessWidget {
  const PartyDetailNameBlock({
    required this.party,
    required this.nameStyle,
    super.key,
  });

  final PartyModel party;
  final TextStyle nameStyle;

  @override
  Widget build(BuildContext context) {
    return PartyNameStack(party: party, nameStyle: nameStyle);
  }
}
