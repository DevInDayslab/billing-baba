import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _cardGap = 12.0;
  static const _cardPadding = 16.0;
  static const _cardBorder = Color(0xFFE0E0E0);
  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _ReceivableCard()),
                SizedBox(width: _cardGap),
                Expanded(child: _PayableCard()),
              ],
            ),
            SizedBox(height: _cardGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 65, child: _TotalSaleCard()),
                SizedBox(width: _cardGap),
                Expanded(flex: 35, child: _RightColumnStack()),
              ],
            ),
            SizedBox(height: _cardGap),
            _MostUsedReportsSection(),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: HomePage._cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HomePage._cardPadding),
        child: child,
      ),
    );
  }
}

class _ReceivableCard extends StatelessWidget {
  const _ReceivableCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Total Receivable',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_downward,
                color: Colors.green.shade600,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            '₹ 0',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            "You don't have any receivables as of now.",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayableCard extends StatelessWidget {
  const _PayableCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total Payable',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_upward,
                color: AppColors.error,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '₹ 233',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'From 1 Party',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalSaleCard extends StatelessWidget {
  const _TotalSaleCard();

  static const _xLabels = [
    '1 Jun',
    '4 Jun',
    '7 Jun',
    '10 Jun',
    '13 Jun',
    '16 Jun',
    '19 Jun',
    '22 Jun',
    '25 Jun',
    '28 Jun',
  ];

  static const _yLabels = ['1', '0.8', '0.6', '0.4', '0.2', '0'];

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Total Sale',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              _PeriodDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            '₹ 0',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _yLabels
                      .map(
                        (label) => Text(
                          label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: _FlatLineChartPainter(
                            borderColor: HomePage._cardBorder,
                            lineColor: AppColors.primary,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _xLabels
                            .map(
                              (label) => Expanded(
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlatLineChartPainter extends CustomPainter {
  _FlatLineChartPainter({
    required this.borderColor,
    required this.lineColor,
  });

  final Color borderColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 0.5;

    const gridLines = 5;
    for (var i = 0; i <= gridLines; i++) {
      final y = size.height * i / gridLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final y = size.height;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant _FlatLineChartPainter oldDelegate) => false;
}

class _RightColumnStack extends StatelessWidget {
  const _RightColumnStack();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _PurchasesWidget(),
        SizedBox(height: HomePage._cardGap),
        _LowStocksWidget(),
      ],
    );
  }
}

class _PurchasesWidget extends StatelessWidget {
  const _PurchasesWidget();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Purchases',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              Text(
                'This Month',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '₹ 0',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: HomePage._cardBorder),
        ],
      ),
    );
  }
}

class _LowStocksWidget extends StatelessWidget {
  const _LowStocksWidget();

  static const _items = [
    ('bike servcing', -1),
    ('Elbow', 0),
    ('gnrn', 0),
  ];

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Low Stocks Items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              Text(
                'As of Now',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${item.$2}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: item.$2 < 0 ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See More ↓',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MostUsedReportsSection extends StatelessWidget {
  const _MostUsedReportsSection();

  static const _reports = [
    'Sale Report',
    'All Transactions',
    'Daybook Report',
    'Party Statement',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Most Used Reports',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View All',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < _reports.length; i++) ...[
              if (i > 0) const SizedBox(width: HomePage._cardGap),
              Expanded(child: _ReportCard(title: _reports[i])),
            ],
          ],
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: HomePage._cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: AppColors.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: HomePage._cardBorder),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
