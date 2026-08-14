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
      if (_loyaltyLine(
            party,
            showLoyalty: showLoyalty,
            loyaltyAsync: loyaltyAsync,
            loyaltyCache: loyaltyCache,
          )
          case final loyalty?)
        _SummaryLine('Loyalty Points', loyalty),
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

  /// Prefer the locally saved opening balance so edits appear immediately.
  /// Hide zero/empty values instead of showing a fake "0 earned" default.
  static String? _loyaltyLine(
    PartyModel party, {
    required bool showLoyalty,
    AsyncValue<PartyLoyaltyBalanceDto>? loyaltyAsync,
    PartyLoyaltyBalanceDto? loyaltyCache,
  }) {
    final opening = double.tryParse(
          party.loyaltyPointsOpeningBalance.replaceAll(',', ''),
        ) ??
        0;
    if (opening != 0) {
      return _formatLoyaltyPoints(opening);
    }
    if (!showLoyalty || loyaltyAsync == null) return null;
    return loyaltyAsync.maybeWhen(
      data: (balance) {
        if (balance.earnedPointsValue == 0 && balance.availablePoints == 0) {
          return null;
        }
        return _loyaltyBalanceSummary(balance);
      },
      orElse: () {
        if (loyaltyCache == null) return null;
        if (loyaltyCache.earnedPointsValue == 0 &&
            loyaltyCache.availablePoints == 0) {
          return null;
        }
        return _loyaltyBalanceSummary(loyaltyCache);
      },
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
    return AppEllipsisText(
      PartyModel.displayNameWithLegal(party),
      style: nameStyle,
      maxLines: 1,
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

String _loyaltyBalanceSummary(PartyLoyaltyBalanceDto balance) {
  final earnedLabel = _formatLoyaltyPoints(balance.earnedPointsValue);
  final availableLabel = _formatLoyaltyPoints(balance.availablePoints);
  if (balance.availablePoints != balance.earnedPointsValue) {
    return '$earnedLabel earned · $availableLabel available';
  }
  return '$earnedLabel earned';
}
