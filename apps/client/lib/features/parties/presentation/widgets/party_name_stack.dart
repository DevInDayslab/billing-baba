import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_highlighted_text.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:flutter/material.dart';

/// Party display name on the first line; legal name below when it differs.
class PartyNameStack extends StatelessWidget {
  const PartyNameStack({
    required this.party,
    required this.nameStyle,
    this.searchQuery = '',
    super.key,
  });

  final PartyModel party;
  final TextStyle nameStyle;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final displayName = Validators.capitalizeFirstLetter(party.name);
    final legalName = party.legalName.trim().isEmpty
        ? ''
        : Validators.capitalizeFirstLetter(party.legalName);
    final title = displayName.isNotEmpty ? displayName : legalName;
    final legalStyle = nameStyle.copyWith(
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.15,
    );
    final compactNameStyle = nameStyle.copyWith(height: 1.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _NameLine(
          text: title,
          style: compactNameStyle,
          searchQuery: searchQuery,
        ),
        if (PartyModel.hasDistinctLegalName(party)) ...[
          const SizedBox(height: 1),
          _NameLine(
            text: legalName,
            style: legalStyle,
            searchQuery: searchQuery,
          ),
        ],
      ],
    );
  }
}

class _NameLine extends StatelessWidget {
  const _NameLine({
    required this.text,
    required this.style,
    required this.searchQuery,
  });

  final String text;
  final TextStyle style;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isEmpty) {
      return AppEllipsisText(text, style: style);
    }
    return InventoryHighlightedText(
      text: text,
      query: searchQuery,
      style: style,
    );
  }
}
