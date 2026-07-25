import 'dart:math';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/application/plans_provider.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// TODO(team): confirm exact bulk saver discount business rule with product team.
const bulkDiscountRate = 0.06;

/// Shows the buy additional licenses modal from Plans & Pricing.
Future<void> showBuyLicensesDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: BuyLicensesDialog(),
    ),
  );
}

enum _BuyLicensesStep {
  selectPlans,
  reviewOrder,
  paymentPending,
  paymentSuccess,
}

class BuyLicensesDialog extends StatefulWidget {
  const BuyLicensesDialog({super.key});

  @override
  State<BuyLicensesDialog> createState() => _BuyLicensesDialogState();
}

class _BuyLicensesDialogState extends State<BuyLicensesDialog> {
  static const _dialogWidth = 980.0;
  static const _dialogHeight = 620.0;
  static const _highlightBg = Color(0xFFFFF8E1);

  static final _priceFormat = NumberFormat('#,##0.##', 'en_IN');

  _BuyLicensesStep _step = _BuyLicensesStep.selectPlans;
  PlanPlatform _selectedPlatform = PlanPlatform.desktopMobile;
  PlanDuration _selectedDuration = PlanDuration.oneYear;
  final Map<String, int> _quantities = {};
  String? _transactionId;
  bool _paymentTimerStarted = false;

  List<AddonPlan> get _addonPlans => buildAddonPlans();

  String _formatPrice(double price) => '₹${_priceFormat.format(price)}';

  AddonPricing _pricingFor(AddonPlan plan) =>
      plan.pricingFor(_selectedPlatform, _selectedDuration);

  int get _totalQuantity => _quantities.values.fold(0, (sum, qty) => sum + qty);

  double get _subtotal {
    var total = 0.0;
    for (final plan in _addonPlans) {
      final qty = _quantities[plan.id];
      if (qty != null && qty > 0) {
        total += _pricingFor(plan).discountedPrice * qty;
      }
    }
    return total;
  }

  double get _bulkDiscount =>
      _totalQuantity >= 2 ? _subtotal * bulkDiscountRate : 0;

  double get _totalAmount => _subtotal - _bulkDiscount;

  double get _totalSaved {
    var originalTotal = 0.0;
    for (final plan in _addonPlans) {
      final qty = _quantities[plan.id];
      if (qty != null && qty > 0) {
        final pricing = _pricingFor(plan);
        originalTotal += pricing.originalPrice * qty;
      }
    }
    return originalTotal - _totalAmount;
  }

  bool get _hasSelection => _quantities.values.any((qty) => qty > 0);

  String get _platformDurationLabel =>
      '${_selectedPlatform.label} • ${_selectedDuration.label}';

  void _addPlan(String planId) {
    setState(() => _quantities[planId] = 1);
  }

  void _increment(String planId) {
    setState(() => _quantities[planId] = (_quantities[planId] ?? 0) + 1);
  }

  void _decrement(String planId) {
    final current = _quantities[planId] ?? 0;
    if (current <= 1) {
      setState(() => _quantities.remove(planId));
    } else {
      setState(() => _quantities[planId] = current - 1);
    }
  }

  void _goToReview() {
    if (!_hasSelection) return;
    setState(() => _step = _BuyLicensesStep.reviewOrder);
  }

  void _goBackToSelect() {
    setState(() => _step = _BuyLicensesStep.selectPlans);
  }

  void _startMockPayment() {
    final txnId =
        'TXN-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999).toString().padLeft(4, '0')}';
    setState(() {
      _transactionId = txnId;
      _step = _BuyLicensesStep.paymentPending;
      _paymentTimerStarted = false;
    });
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_step != _BuyLicensesStep.paymentPending) return;
      setState(() => _step = _BuyLicensesStep.paymentSuccess);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: _dialogWidth,
        minWidth: 720,
        maxHeight: _dialogHeight,
        minHeight: _dialogHeight,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: switch (_step) {
          _BuyLicensesStep.selectPlans => _buildSelectPlansStep(),
          _BuyLicensesStep.reviewOrder => _buildReviewOrderStep(),
          _BuyLicensesStep.paymentPending => _buildPaymentPendingStep(),
          _BuyLicensesStep.paymentSuccess => _buildPaymentSuccessStep(),
        },
      ),
    );
  }

  Widget _buildSelectPlansStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DialogHeader(
          title: 'Buy Additional Licenses',
          onClose: () => Navigator.of(context).pop(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: _FilterDropdowns(
            selectedPlatform: _selectedPlatform,
            selectedDuration: _selectedDuration,
            onPlatformChanged: (platform) =>
                setState(() => _selectedPlatform = platform),
            onDurationChanged: (duration) =>
                setState(() => _selectedDuration = duration),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: _PlanListPanel(
                    plans: _addonPlans,
                    quantities: _quantities,
                    platform: _selectedPlatform,
                    duration: _selectedDuration,
                    platformDurationLabel: _platformDurationLabel,
                    highlightBg: _highlightBg,
                    formatPrice: _formatPrice,
                    onAdd: _addPlan,
                    onIncrement: _increment,
                    onDecrement: _decrement,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: _SelectedPlansPanel(
                    plans: _addonPlans,
                    quantities: _quantities,
                    platform: _selectedPlatform,
                    duration: _selectedDuration,
                    platformDurationLabel: _platformDurationLabel,
                    subtotal: _subtotal,
                    bulkDiscount: _bulkDiscount,
                    totalAmount: _totalAmount,
                    totalSaved: _totalSaved,
                    formatPrice: _formatPrice,
                  ),
                ),
              ],
            ),
          ),
        ),
        _BottomBar(
          hasSelection: _hasSelection,
          bulkDiscount: _bulkDiscount,
          totalQuantity: _totalQuantity,
          formatPrice: _formatPrice,
          primaryLabel: 'Buy Now',
          onPrimary: _hasSelection ? _goToReview : null,
        ),
      ],
    );
  }

  Widget _buildReviewOrderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DialogHeader(
          title: 'Review Order',
          onClose: () => Navigator.of(context).pop(),
          leading: IconButton(
            onPressed: _goBackToSelect,
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SelectedPlansPanel(
                  plans: _addonPlans,
                  quantities: _quantities,
                  platform: _selectedPlatform,
                  duration: _selectedDuration,
                  platformDurationLabel: _platformDurationLabel,
                  subtotal: _subtotal,
                  bulkDiscount: _bulkDiscount,
                  totalAmount: _totalAmount,
                  totalSaved: _totalSaved,
                  formatPrice: _formatPrice,
                  expanded: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.mdBorder,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.radio_button_checked,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          'UPI / Net Banking (Mock)',
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          'Simulated payment — no real charge',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _BottomBar(
          hasSelection: true,
          bulkDiscount: _bulkDiscount,
          totalQuantity: _totalQuantity,
          formatPrice: _formatPrice,
          primaryLabel: 'Pay ${_formatPrice(_totalAmount)}',
          onPrimary: _startMockPayment,
          showPromoMessage: false,
        ),
      ],
    );
  }

  Widget _buildPaymentPendingStep() {
    if (!_paymentTimerStarted) {
      _paymentTimerStarted = true;
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Payment Pending',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Please wait while we confirm your payment…',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Transaction ID: $_transactionId',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSuccessStep() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Payment Successful',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Your licenses will be activated shortly.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Transaction ID: $_transactionId',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm + 4,
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.title,
    required this.onClose,
    this.leading,
  });

  final String title;
  final VoidCallback onClose;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdowns extends StatelessWidget {
  const _FilterDropdowns({
    required this.selectedPlatform,
    required this.selectedDuration,
    required this.onPlatformChanged,
    required this.onDurationChanged,
  });

  final PlanPlatform selectedPlatform;
  final PlanDuration selectedDuration;
  final ValueChanged<PlanPlatform> onPlatformChanged;
  final ValueChanged<PlanDuration> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _PillDropdown<PlanPlatform>(
          value: selectedPlatform,
          label: selectedPlatform.label,
          items: const [
            PlanPlatform.desktopMobile,
            PlanPlatform.desktop,
            PlanPlatform.mobile,
          ],
          labelBuilder: (p) => p.label,
          onSelected: onPlatformChanged,
          isSelected: (p) => p == selectedPlatform,
        ),
        _PillDropdown<PlanDuration>(
          value: selectedDuration,
          label: selectedDuration.label,
          items: const [PlanDuration.oneYear, PlanDuration.threeYears],
          labelBuilder: (d) => d.label,
          onSelected: onDurationChanged,
          isSelected: (d) => d == selectedDuration,
        ),
      ],
    );
  }
}

class _PillDropdown<T> extends StatelessWidget {
  const _PillDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.labelBuilder,
    required this.onSelected,
    required this.isSelected,
  });

  final T value;
  final String label;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;
  final bool Function(T) isSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      initialValue: value,
      onSelected: onSelected,
      color: Colors.white,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem(
              value: item,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    labelBuilder(item),
                    style: const TextStyle(color: Colors.black87),
                  ),
                  if (isSelected(item))
                    const Icon(Icons.check, color: Colors.blue, size: 18),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanListPanel extends StatelessWidget {
  const _PlanListPanel({
    required this.plans,
    required this.quantities,
    required this.platform,
    required this.duration,
    required this.platformDurationLabel,
    required this.highlightBg,
    required this.formatPrice,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final List<AddonPlan> plans;
  final Map<String, int> quantities;
  final PlanPlatform platform;
  final PlanDuration duration;
  final String platformDurationLabel;
  final Color highlightBg;
  final String Function(double) formatPrice;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        itemCount: plans.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final plan = plans[index];
          final qty = quantities[plan.id];
          final pricing = plan.pricingFor(platform, duration);
          return _PlanRow(
            plan: plan,
            pricing: pricing,
            quantity: qty,
            platformDurationLabel: platformDurationLabel,
            highlightBg: highlightBg,
            formatPrice: formatPrice,
            onAdd: () => onAdd(plan.id),
            onIncrement: () => onIncrement(plan.id),
            onDecrement: () => onDecrement(plan.id),
          );
        },
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.plan,
    required this.pricing,
    required this.quantity,
    required this.platformDurationLabel,
    required this.highlightBg,
    required this.formatPrice,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final AddonPlan plan;
  final AddonPricing pricing;
  final int? quantity;
  final String platformDurationLabel;
  final Color highlightBg;
  final String Function(double) formatPrice;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final isAdded = quantity != null && quantity! > 0;

    return Container(
      color: plan.isHighlighted ? highlightBg : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: plan.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(plan.icon, color: plan.iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  platformDurationLabel,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatPrice(pricing.originalPrice),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    formatPrice(pricing.discountedPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (isAdded)
            _QuantityStepper(
              quantity: quantity!,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            )
          else
            OutlinedButton(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Add'),
            ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.smBorder,
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove, onPressed: onDecrement),
          Container(
            width: 36,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: AppColors.error),
              ),
            ),
            child: Text(
              quantity.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add, onPressed: onIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs + 2,
        ),
        child: Icon(icon, size: 16, color: AppColors.error),
      ),
    );
  }
}

class _SelectedPlansPanel extends StatelessWidget {
  const _SelectedPlansPanel({
    required this.plans,
    required this.quantities,
    required this.platform,
    required this.duration,
    required this.platformDurationLabel,
    required this.subtotal,
    required this.bulkDiscount,
    required this.totalAmount,
    required this.totalSaved,
    required this.formatPrice,
    this.expanded = false,
  });

  final List<AddonPlan> plans;
  final Map<String, int> quantities;
  final PlanPlatform platform;
  final PlanDuration duration;
  final String platformDurationLabel;
  final double subtotal;
  final double bulkDiscount;
  final double totalAmount;
  final double totalSaved;
  final String Function(double) formatPrice;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final selectedEntries = plans
        .where((p) => (quantities[p.id] ?? 0) > 0)
        .map((p) => (plan: p, qty: quantities[p.id]!))
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: Colors.grey.shade200),
        color: expanded ? AppColors.surface : Colors.grey.shade50,
      ),
      child: selectedEntries.isEmpty
          ? const Center(
              child: Text(
                'View Selected Plans Here',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Selected Plans',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...selectedEntries.map((entry) {
                  final pricing = entry.plan.pricingFor(platform, duration);
                  final lineTotal = pricing.discountedPrice * entry.qty;
                  final qtyLabel = entry.qty > 1 ? ' x ${entry.qty}' : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${entry.plan.name} ($platformDurationLabel$qtyLabel)',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          formatPrice(lineTotal),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (bulkDiscount > 0) ...[
                  const Divider(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Bulk Saver Discount',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '- ${formatPrice(bulkDiscount)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                const Divider(height: AppSpacing.lg),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (totalSaved > 0)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: AppRadius.smBorder,
                          ),
                          child: Text(
                            'You saved ${formatPrice(totalSaved)}! 🎉',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ),
                    Text(
                      formatPrice(totalAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.hasSelection,
    required this.bulkDiscount,
    required this.totalQuantity,
    required this.formatPrice,
    required this.primaryLabel,
    required this.onPrimary,
    this.showPromoMessage = true,
  });

  final bool hasSelection;
  final double bulkDiscount;
  final int totalQuantity;
  final String Function(double) formatPrice;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool showPromoMessage;

  @override
  Widget build(BuildContext context) {
    final message = !hasSelection
        ? '🎉 Buy 1 or more licenses & unlock Bulk Saver Discount!'
        : bulkDiscount > 0
        ? '🎉 ${formatPrice(bulkDiscount)} Bulk Saver Discount Applied!'
        : '🎉 Buy 1 or more licenses & unlock Bulk Saver Discount!';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          if (showPromoMessage)
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            )
          else
            const Spacer(),
          FilledButton(
            onPressed: onPrimary,
            style: FilledButton.styleFrom(
              backgroundColor: onPrimary != null
                  ? AppColors.error
                  : Colors.grey.shade400,
              disabledBackgroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm + 4,
              ),
            ),
            child: Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}
