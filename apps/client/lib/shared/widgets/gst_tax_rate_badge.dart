import 'package:billing_baba/features/inventory/utils/gst_tax_rate_catalog.dart';
import 'package:flutter/material.dart';

class GstTaxRateBadge extends StatelessWidget {
  const GstTaxRateBadge({
    required this.option,
    this.size = 28,
    super.key,
  });

  final GstTaxRateOption option;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (option.percent == null ||
        option.badgeBackground == null ||
        option.badgeForeground == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: option.badgeBackground,
        shape: BoxShape.circle,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            option.badgeLabel(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
              color: option.badgeForeground,
            ),
          ),
        ),
      ),
    );
  }
}
