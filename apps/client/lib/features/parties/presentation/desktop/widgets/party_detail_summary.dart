import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_detail_header.dart';
import 'package:billing_baba/features/loyalty/models/loyalty_dto.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Primary party fields shown in the detail header (non-empty values only).
class PartyDetailPrimaryFields extends ConsumerWidget {
  const PartyDetailPrimaryFields({
    required this.party,
    required this.billingAddress,
    required this.creditLimitLabel,
    required this.showLoyalty,
    this.loyaltyAsync,
    this.loyaltyCache,
    super.key,
  });

  final PartyModel party;
  final String billingAddress;
  final String? creditLimitLabel;
  final bool showLoyalty;
  final AsyncValue<PartyLoyaltyBalanceDto>? loyaltyAsync;
  final PartyLoyaltyBalanceDto? loyaltyCache;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = <_SummaryLine>[
      if (_phonesLabel(party) case final phones?)
        _SummaryLine('Phone', phones),
      if (creditLimitLabel != null)
        _SummaryLine('Credit Limit', creditLimitLabel!),
      if (party.gstin.trim().isNotEmpty)
        _SummaryLine('GSTIN', party.gstin.trim()),
      if (billingAddress.trim().isNotEmpty)
        _SummaryLine('Address', billingAddress.trim()),
      if (party.email.trim().isNotEmpty)
        _SummaryLine('Email', party.email.trim()),
      if (showLoyalty && loyaltyAsync != null)
        _SummaryLine(
          'Loyalty Points',
          _loyaltyDisplayValue(loyaltyAsync!, cached: loyaltyCache),
        ),
    ];

    if (lines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in lines)
          InventoryDetailMetaLine(label: line.label, value: line.value),
      ],
    );
  }

  static String? _phonesLabel(PartyModel party) {
    final phones = <String>[
      if (party.phone.trim().isNotEmpty) party.phone.trim(),
      ...party.additionalPhones.map((p) => p.trim()).where((p) => p.isNotEmpty),
    ];
    if (phones.isEmpty) return null;
    return phones.join(', ');
  }
}

class PartyDetailNameBlock extends StatelessWidget {
  const PartyDetailNameBlock({
    required this.party,
    required this.nameStyle,
    this.legalNameStyle,
    super.key,
  });

  final PartyModel party;
  final TextStyle nameStyle;
  final TextStyle? legalNameStyle;

  static bool shouldShowLegalName(PartyModel party) {
    final legal = party.legalName.trim();
    if (legal.isEmpty) return false;
    return legal.toLowerCase() != party.name.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final showLegal = shouldShowLegalName(party);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTruncatedText(party.name, style: nameStyle),
        if (showLegal) ...[
          const SizedBox(height: 2),
          AppTruncatedText(
            party.legalName.trim(),
            style:
                legalNameStyle ??
                nameStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ],
    );
  }
}

class _SummaryLine {
  const _SummaryLine(this.label, this.value);

  final String label;
  final String value;
}

String _formatLoyaltyPoints(double value) {
  return value == value.roundToDouble()
      ? '${value.toInt()}'
      : value.toStringAsFixed(0);
}

const _loyaltyZeroLabel = '0 earned';

String _loyaltyBalanceSummary(PartyLoyaltyBalanceDto balance) {
  final earnedLabel = _formatLoyaltyPoints(balance.earnedPointsValue);
  final availableLabel = _formatLoyaltyPoints(balance.availablePoints);
  if (balance.availablePoints != balance.earnedPointsValue) {
    return '$earnedLabel earned · $availableLabel available';
  }
  return '$earnedLabel earned';
}

String _loyaltyDisplayValue(
  AsyncValue<PartyLoyaltyBalanceDto> balanceAsync, {
  PartyLoyaltyBalanceDto? cached,
}) {
  return balanceAsync.maybeWhen(
    data: _loyaltyBalanceSummary,
    orElse: () =>
        cached != null ? _loyaltyBalanceSummary(cached) : _loyaltyZeroLabel,
  );
}
