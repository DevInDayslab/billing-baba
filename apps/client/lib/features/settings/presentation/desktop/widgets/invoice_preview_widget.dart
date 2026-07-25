import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:billing_baba/features/pos/application/pos_sales_list_provider.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InvoicePreviewItem {
  const InvoicePreviewItem({
    required this.name,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  final String name;
  final num qty;
  final double rate;
  final double amount;
}

class InvoicePreviewData {
  const InvoicePreviewData({
    required this.businessName,
    required this.address,
    required this.phone,
    required this.gstin,
    required this.logoUrl,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.date,
    required this.invoiceNumber,
    required this.customerName,
  });

  final String businessName;
  final String? address;
  final String? phone;
  final String? gstin;
  final String? logoUrl;
  final List<InvoicePreviewItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime date;
  final String invoiceNumber;
  final String? customerName;

  static InvoicePreviewData dummy() {
    final today = DateTime.now();
    return InvoicePreviewData(
      businessName: 'Demo Business',
      address: '123 Main St, Delhi',
      phone: '+91 98765 43210',
      gstin: '29ABCDE1234F1Z5',
      logoUrl: null,
      items: const [
        InvoicePreviewItem(name: 'Product A', qty: 2, rate: 500, amount: 1000),
        InvoicePreviewItem(name: 'Product B', qty: 1, rate: 250, amount: 250),
      ],
      subtotal: 1250,
      tax: 225,
      total: 1475,
      date: today,
      invoiceNumber: 'INV-0001',
      customerName: 'Walk-in Customer',
    );
  }

  static InvoicePreviewData fromSources({
    BusinessProfileModel? profile,
    PosSale? sale,
  }) {
    if (profile == null && sale == null) return dummy();

    final resolvedSale = sale;
    if (resolvedSale == null) {
      final dummyData = dummy();
      return InvoicePreviewData(
        businessName: profile?.name ?? dummyData.businessName,
        address: profile?.address ?? dummyData.address,
        phone: profile?.phone ?? dummyData.phone,
        gstin: profile?.gstin ?? dummyData.gstin,
        logoUrl: profile?.logoUrl,
        items: dummyData.items,
        subtotal: dummyData.subtotal,
        tax: dummyData.tax,
        total: dummyData.total,
        date: dummyData.date,
        invoiceNumber: dummyData.invoiceNumber,
        customerName: dummyData.customerName,
      );
    }

    return InvoicePreviewData(
      businessName: profile?.name ?? 'My Business',
      address: profile?.address,
      phone: profile?.phone,
      gstin: profile?.gstin,
      logoUrl: profile?.logoUrl,
      items: resolvedSale.items
          .map(
            (item) => InvoicePreviewItem(
              name: item.name,
              qty: item.quantity,
              rate:
                  item.unitPrice ??
                  (item.quantity > 0 ? item.lineTotal / item.quantity : 0),
              amount: item.lineTotal,
            ),
          )
          .toList(),
      subtotal: resolvedSale.totalAmount,
      tax: resolvedSale.taxAmount,
      total: resolvedSale.finalAmount,
      date: resolvedSale.completedAt,
      invoiceNumber: resolvedSale.docNumber,
      customerName: resolvedSale.displayName,
    );
  }
}

class InvoicePreviewWidget extends ConsumerWidget {
  const InvoicePreviewWidget({required this.settings, super.key});

  final PrintSettings settings;

  static const _mmToLogicalPx = 3.78;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentBusinessProvider);
    final salesAsync = ref.watch(posSalesListProvider);
    final sale = salesAsync.asData?.value.isNotEmpty == true
        ? salesAsync.asData!.value.first
        : null;
    final data = InvoicePreviewData.fromSources(profile: profile, sale: sale);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: listPanelCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              'Live Preview',
              style: AppTypography.inter(
                fontSize: AppTypography.bodySmallSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: listPanelCardBorder,
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: Center(
                child: settings.printerType == PrinterType.thermal
                    ? _ThermalPreview(settings: settings, data: data)
                    : _RegularPreview(settings: settings, data: data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThermalPreview extends StatelessWidget {
  const _ThermalPreview({required this.settings, required this.data});

  final PrintSettings settings;
  final InvoicePreviewData data;

  double get _widthMm => switch (settings.thermalPageSize) {
    ThermalPageSize.twoInch => 62,
    ThermalPageSize.threeInch => 80,
    ThermalPageSize.fourInch => 92,
  };

  double get _baseFontSize {
    final scale = switch (settings.thermalPageSize) {
      ThermalPageSize.twoInch => 0.9,
      ThermalPageSize.threeInch => 1.0,
      ThermalPageSize.fourInch => 1.12,
    };
    return 9.5 * scale;
  }

  TextStyle _style({
    double scale = 1,
    bool emphasized = false,
  }) {
    final bold = settings.useTextStylingBold && emphasized;
    return AppTypography.inter(
      fontSize: _baseFontSize * scale,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.25,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs ',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final width = _widthMm * InvoicePreviewWidget._mmToLogicalPx;

    final content = Container(
      width: width,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (settings.printCompanyLogo)
            Center(
              child: BusinessAvatar(
                name: data.businessName,
                seed: data.businessName,
                diameter: 28,
                fontSize: 14,
                logoUrl: data.logoUrl,
              ),
            ),
          if (settings.printCompanyName) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              data.businessName,
              style: _style(scale: 1.15, emphasized: true),
              textAlign: TextAlign.center,
            ),
          ],
          if (settings.printAddress &&
              data.address != null &&
              data.address!.isNotEmpty)
            Text(
              data.address!,
              style: _style(),
              textAlign: TextAlign.center,
            ),
          if (settings.printGstin &&
              data.gstin != null &&
              data.gstin!.isNotEmpty)
            Text(
              'GSTIN: ${data.gstin}',
              style: _style(),
              textAlign: TextAlign.center,
            ),
          if (settings.printPhone &&
              data.phone != null &&
              data.phone!.isNotEmpty)
            Text(
              'Phone: ${data.phone!}',
              style: _style(),
              textAlign: TextAlign.center,
            ),
          const Divider(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'No: ${data.invoiceNumber}',
                  style: _style(emphasized: true),
                ),
              ),
              Text(
                dateFormat.format(data.date),
                style: _style(scale: 0.95),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          if (data.customerName != null && data.customerName!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('BILL TO:', style: _style(emphasized: true)),
            const SizedBox(height: AppSpacing.xs),
            Text(data.customerName!, style: _style()),
          ],
          const Divider(height: AppSpacing.md),
          _ThermalItemsTable(
            items: data.items,
            currency: currency,
            style: _style(),
            headerStyle: _style(emphasized: true),
          ),
          const Divider(height: AppSpacing.sm),
          _TotalLine(
            label: 'Sub Total',
            value: currency.format(data.subtotal),
            style: _style(),
          ),
          _TotalLine(
            label: 'Tax',
            value: currency.format(data.tax),
            style: _style(),
          ),
          const Divider(height: AppSpacing.sm),
          _TotalLine(
            label: 'Total Amount',
            value: currency.format(data.total),
            style: _style(emphasized: true),
          ),
          if (settings.printBankDetails) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bank: Sample Account\nIFSC: SAMPLE0001',
              style: _style(scale: 0.9),
            ),
          ],
          if (settings.printTermsAndConditions &&
              settings.termsAndConditions.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              settings.termsAndConditions.trim(),
              style: _style(scale: 0.9),
              textAlign: TextAlign.center,
            ),
          ],
          for (var i = 0; i < settings.extraLinesAtEnd; i++)
            const SizedBox(height: AppSpacing.md),
        ],
      ),
    );

    return FittedBox(
      child: content,
    );
  }
}

class _RegularPreview extends StatelessWidget {
  const _RegularPreview({required this.settings, required this.data});

  final PrintSettings settings;
  final InvoicePreviewData data;

  static const _sqrt2 = 1.41421356237;

  double _invoiceFontSize() => switch (settings.invoiceTextSize) {
    PrintTextSize.small => 8,
    PrintTextSize.medium => 10,
    PrintTextSize.large => 12,
  };

  double _companyFontSize() => switch (settings.companyTextSize) {
    PrintTextSize.small => 8,
    PrintTextSize.medium => 10,
    PrintTextSize.large => 12,
  };

  TextStyle _body({bool emphasized = false}) {
    return AppTypography.inter(
      fontSize: _invoiceFontSize(),
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.3,
    );
  }

  TextStyle _company({bool emphasized = false}) {
    return AppTypography.inter(
      fontSize: _companyFontSize(),
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy');
    final isLandscape = settings.orientation == RegularOrientation.landscape;
    final aspectRatio = isLandscape ? _sqrt2 : 1 / _sqrt2;

    final page = AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (settings.printCompanyLogo)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  child: Text(
                                    data.businessName.isNotEmpty
                                        ? data.businessName[0].toUpperCase()
                                        : 'B',
                                    style: _company(emphasized: true),
                                  ),
                                ),
                              if (settings.printCompanyName) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  data.businessName,
                                  style: _company(emphasized: true),
                                ),
                              ],
                              if (settings.printAddress &&
                                  data.address != null &&
                                  data.address!.isNotEmpty)
                                Text(data.address!, style: _company()),
                              if (settings.printPhone &&
                                  data.phone != null &&
                                  data.phone!.isNotEmpty)
                                Text(
                                  'Phone: ${data.phone}',
                                  style: _company(),
                                ),
                              if (settings.printGstin &&
                                  data.gstin != null &&
                                  data.gstin!.isNotEmpty)
                                Text(
                                  'GSTIN: ${data.gstin}',
                                  style: _company(),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TAX INVOICE',
                              style: _company(emphasized: true),
                            ),
                            Text(
                              'No: ${data.invoiceNumber}',
                              style: _body(),
                            ),
                            Text(
                              'Date: ${dateFormat.format(data.date)}',
                              style: _body(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Bill To', style: _body(emphasized: true)),
                    Text(
                      data.customerName ?? 'Walk-in Customer',
                      style: _body(emphasized: true),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _RegularItemsTable(
                      items: data.items,
                      currency: currency,
                      style: _body(),
                      headerStyle: _body(emphasized: true),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 160,
                        child: Column(
                          children: [
                            _TotalLine(
                              label: 'Subtotal',
                              value: currency.format(data.subtotal),
                              style: _body(),
                            ),
                            _TotalLine(
                              label: 'Tax',
                              value: currency.format(data.tax),
                              style: _body(),
                            ),
                            _TotalLine(
                              label: 'Grand Total',
                              value: currency.format(data.total),
                              style: _body(emphasized: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (settings.printBankDetails) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Bank: Sample Account | IFSC: SAMPLE0001',
                        style: _body(),
                      ),
                    ],
                    if (settings.printTermsAndConditions &&
                        settings.termsAndConditions.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        settings.termsAndConditions.trim(),
                        style: _body(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    return FittedBox(
      child: SizedBox(
        width: isLandscape ? 360 : 260,
        child: page,
      ),
    );
  }
}

class _ThermalItemsTable extends StatelessWidget {
  const _ThermalItemsTable({
    required this.items,
    required this.currency,
    required this.style,
    required this.headerStyle,
  });

  final List<InvoicePreviewItem> items;
  final NumberFormat currency;
  final TextStyle style;
  final TextStyle headerStyle;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            Text('Item', style: headerStyle),
            Text('Qty', style: headerStyle, textAlign: TextAlign.center),
            Text('Rate', style: headerStyle, textAlign: TextAlign.right),
            Text('Total', style: headerStyle, textAlign: TextAlign.right),
          ],
        ),
        for (final item in items)
          TableRow(
            children: [
              Text(item.name, style: style, maxLines: 2),
              Text('${item.qty}', style: style, textAlign: TextAlign.center),
              Text(
                currency.format(item.rate),
                style: style,
                textAlign: TextAlign.right,
              ),
              Text(
                currency.format(item.amount),
                style: style,
                textAlign: TextAlign.right,
              ),
            ],
          ),
      ],
    );
  }
}

class _RegularItemsTable extends StatelessWidget {
  const _RegularItemsTable({
    required this.items,
    required this.currency,
    required this.style,
    required this.headerStyle,
  });

  final List<InvoicePreviewItem> items;
  final NumberFormat currency;
  final TextStyle style;
  final TextStyle headerStyle;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: AppColors.textSecondary.withValues(alpha: 0.25),
      ),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: AppColors.background,
          ),
          children: [
            Text('Description', style: headerStyle),
            Text('Qty', style: headerStyle, textAlign: TextAlign.center),
            Text('Rate', style: headerStyle, textAlign: TextAlign.right),
            Text('Amount', style: headerStyle, textAlign: TextAlign.right),
          ],
        ),
        for (final item in items)
          TableRow(
            children: [
              Text(item.name, style: style, maxLines: 2),
              Text('${item.qty}', style: style, textAlign: TextAlign.center),
              Text(
                currency.format(item.rate),
                style: style,
                textAlign: TextAlign.right,
              ),
              Text(
                currency.format(item.amount),
                style: style,
                textAlign: TextAlign.right,
              ),
            ],
          ),
      ],
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style, textAlign: TextAlign.right),
        ],
      ),
    );
  }
}
