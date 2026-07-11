import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const purchaseTransactionTableCardBorder = Color(0xFFE0E0E0);
const purchaseTransactionTableHeaderBg = Color(0xFFF8FAFC);
const purchaseTransactionTableColumnDivider = Color(0xFFE5E7EB);
const purchaseTransactionTableRowBorder = Color(0xFFE5E7EB);
const purchaseTransactionTableRowHoverColor = Color(0xFFF1F5F9);
const purchaseTransactionTableHeaderTextColor = Color(0xFF1E293B);

const purchaseTransactionTableRowHeight = 54.0;
const purchaseTransactionTableHeaderHeight = 48.0;
const purchaseTransactionTableCellPadding = EdgeInsets.symmetric(horizontal: 12);

/// Long-content columns (fixed width).
const purchaseTransactionDateColWidth = 174.0;
const purchaseTransactionDateOnlyColWidth = 110.0;
const purchaseTransactionInvoiceColWidth = 136.0;
const purchaseTransactionRefColWidth = 136.0;

/// Party Name — flex column; minimum for horizontal scroll.
const purchaseTransactionPartyColMinWidth = 97.0;
const purchaseTransactionPartyColFlex = 1;

/// @deprecated Use [purchaseTransactionPartyColMinWidth] or flex layout.
const purchaseTransactionPartyColWidth = purchaseTransactionPartyColMinWidth;

/// Short-content columns (fixed, compact).
const purchaseTransactionPaymentColWidth = 123.0;
const purchaseTransactionAmountColWidth = 111.0;
const purchaseTransactionBalanceColWidth = 111.0;
const purchaseTransactionDueDateColWidth = 111.0;
const purchaseTransactionStatusColWidth = 101.0;
const purchaseTransactionActionsColWidth3 = 145.0;
const purchaseTransactionActionsColWidth2 = 97.0;

/// Expenses split-panel layout — compact fixed columns so Party Name gets room.
const expenseTransactionDateColWidth = 150.0;
const expenseTransactionInvoiceColWidth = 115.0;
const expenseTransactionPartyColMinWidth = 160.0;
const expenseTransactionPartyColFlex = 2;
const expenseTransactionPaymentColWidth = 105.0;
const expenseTransactionAmountColWidth = 92.0;
const expenseTransactionBalanceColWidth = 92.0;
const expenseTransactionDueDateColWidth = 95.0;
const expenseTransactionStatusColWidth = 88.0;

const expenseTransactionStandardMinTableWidth =
    expenseTransactionDateColWidth +
    expenseTransactionInvoiceColWidth +
    expenseTransactionPartyColMinWidth +
    expenseTransactionPaymentColWidth +
    expenseTransactionAmountColWidth +
    expenseTransactionBalanceColWidth +
    expenseTransactionDueDateColWidth +
    expenseTransactionStatusColWidth;

const expenseTransactionLoyaltyMinTableWidth =
    expenseTransactionDateColWidth +
    expenseTransactionInvoiceColWidth +
    expenseTransactionPartyColMinWidth +
    expenseTransactionAmountColWidth +
    expenseTransactionAmountColWidth;

const purchaseTransactionTableHeaderStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: purchaseTransactionTableHeaderTextColor,
);

const purchaseTransactionTableDataStyle = TextStyle(
  fontSize: 13,
  color: AppColors.textPrimary,
);

const purchaseTransactionAmountTextStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w500,
  color: AppColors.textPrimary,
  fontFeatures: [FontFeature.tabularFigures()],
);

/// Keeps expense transaction headers and rows aligned when the split panel is narrow.
class ExpenseTransactionTableViewport extends StatelessWidget {
  const ExpenseTransactionTableViewport({
    required this.minWidth,
    required this.child,
    super.key,
  });

  final double minWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth.clamp(
          minWidth,
          double.infinity,
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: child,
          ),
        );
      },
    );
  }
}

class PurchaseTransactionTableHeader extends StatelessWidget {
  const PurchaseTransactionTableHeader({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: purchaseTransactionTableHeaderHeight,
      decoration: const BoxDecoration(
        color: purchaseTransactionTableHeaderBg,
        border: Border(bottom: BorderSide(color: purchaseTransactionTableRowBorder)),
      ),
      child: child,
    );
  }
}

class PurchaseTransactionTableHeaderRow extends StatelessWidget {
  const PurchaseTransactionTableHeaderRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return PurchaseTransactionTableHeader(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class PurchaseTransactionTableCell extends StatelessWidget {
  const PurchaseTransactionTableCell({
    required this.child,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.showDivider = true,
    super.key,
  });

  final Widget child;
  final double? width;
  final Alignment alignment;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final cell = Container(
      height: double.infinity,
      width: width == null ? double.infinity : null,
      padding: purchaseTransactionTableCellPadding,
      alignment: alignment,
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: purchaseTransactionTableColumnDivider,
                  width: 1,
                ),
              ),
            )
          : null,
      child: child,
    );

    if (width != null) {
      return SizedBox(width: width, child: cell);
    }

    return cell;
  }
}

class PurchaseTransactionTableDataRow extends StatefulWidget {
  const PurchaseTransactionTableDataRow({
    required this.children,
    this.onTap,
    super.key,
  });

  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  State<PurchaseTransactionTableDataRow> createState() =>
      _PurchaseTransactionTableDataRowState();
}

class _PurchaseTransactionTableDataRowState
    extends State<PurchaseTransactionTableDataRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final row = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: DefaultTextStyle(
        style: purchaseTransactionTableDataStyle,
        child: Container(
          height: purchaseTransactionTableRowHeight,
          decoration: BoxDecoration(
            color: _hovered
                ? purchaseTransactionTableRowHoverColor
                : AppColors.surface,
            border: const Border(
              bottom: BorderSide(color: purchaseTransactionTableRowBorder),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.children,
          ),
        ),
      ),
    );

    if (widget.onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        splashColor: AppColors.textSecondary.withValues(alpha: 0.08),
        child: row,
      ),
    );
  }
}
