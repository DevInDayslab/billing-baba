import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/providers/parties_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dialogMaxWidth = 900.0;
const _cardBorder = Color(0xFFE0E0E0);

/// Result returned when a party is saved from the Add Party dialog.
class AddPartyResult {
  const AddPartyResult({
    required this.partyName,
    this.gstin = '',
    this.phone = '',
    this.gstType = 'Unregistered/Consumer',
    this.state = 'Andhra Pradesh',
    this.email = '',
    this.billingAddress = '',
    this.shippingAddress = '',
  });

  final String partyName;
  final String gstin;
  final String phone;
  final String gstType;
  final String state;
  final String email;
  final String billingAddress;
  final String shippingAddress;
}

/// Shows the Add Party modal from sale forms and party pickers.
Future<AddPartyResult?> showAddPartyDialog(BuildContext context) {
  return showDialog<AddPartyResult>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AddPartyDialog(),
    ),
  );
}

class AddPartyDialog extends ConsumerStatefulWidget {
  const AddPartyDialog({super.key});

  @override
  ConsumerState<AddPartyDialog> createState() => _AddPartyDialogState();
}

class _AddPartyDialogState extends ConsumerState<AddPartyDialog>
    with SingleTickerProviderStateMixin {
  static const _gstTypes = [
    'Unregistered/Consumer',
    'Registered Business - Regular',
    'Registered Business - Composition',
    'SEZ',
    'Overseas',
  ];

  late final TabController _tabController;
  final _partyNameController = TextEditingController();
  final _gstinController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _creditLimitController = TextEditingController();

  String _gstType = 'Unregistered/Consumer';
  String _state = 'Andhra Pradesh';
  bool _showShippingAddress = false;
  bool _partyNameError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _partyNameController.dispose();
    _gstinController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _openingBalanceController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  AddPartyResult _buildResult() {
    return AddPartyResult(
      partyName: _partyNameController.text.trim(),
      gstin: _gstinController.text.trim(),
      phone: _phoneController.text.trim(),
      gstType: _gstType,
      state: _state,
      email: _emailController.text.trim(),
      billingAddress: _billingAddressController.text.trim(),
      shippingAddress: _showShippingAddress
          ? _shippingAddressController.text.trim()
          : '',
    );
  }

  bool _validate() {
    final isValid = _partyNameController.text.trim().isNotEmpty;
    setState(() => _partyNameError = !isValid);
    return isValid;
  }

  void _save({required bool saveAndNew}) {
    if (!_validate()) return;

    final result = _buildResult();
    ref.read(partiesProvider.notifier).addParty(result.partyName);

    if (saveAndNew) {
      _partyNameController.clear();
      _gstinController.clear();
      _phoneController.clear();
      _emailController.clear();
      _billingAddressController.clear();
      _shippingAddressController.clear();
      _openingBalanceController.clear();
      _creditLimitController.clear();
      setState(() {
        _gstType = 'Unregistered/Consumer';
        _state = 'Andhra Pradesh';
        _showShippingAddress = false;
        _partyNameError = false;
        _tabController.index = 0;
      });
      return;
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: _buildTopFields(),
            ),
            _buildTabBar(),
            const Divider(height: 1, color: _cardBorder),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 340),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return switch (_tabController.index) {
                      0 => _buildGstAddressTab(),
                      1 => _buildCreditBalanceTab(),
                      _ => _buildAdditionalFieldsTab(),
                    };
                  },
                ),
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Add Party',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Party settings coming soon')),
              );
            },
            icon: const Icon(Icons.settings_outlined, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTopFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;
        if (isNarrow) {
          return Column(
            children: [
              _LabeledField(
                label: 'Party Name *',
                hasError: _partyNameError,
                errorText: 'Party name is required',
                child: TextField(
                  controller: _partyNameController,
                  style: saleFieldTextStyle,
                  decoration: buildSaleFieldDecoration(
                    hasError: _partyNameError,
                  ),
                  onChanged: (_) {
                    if (_partyNameError) {
                      setState(() => _partyNameError = false);
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _LabeledField(
                label: 'GSTIN',
                child: TextField(
                  controller: _gstinController,
                  style: saleFieldTextStyle,
                  decoration: buildSaleFieldDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.info_outline, size: 18),
                      color: AppColors.textSecondary,
                      tooltip: '15-character GST identification number',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _LabeledField(
                label: 'Phone Number',
                child: TextField(
                  controller: _phoneController,
                  style: saleFieldTextStyle,
                  decoration: buildSaleFieldDecoration(),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LabeledField(
                label: 'Party Name *',
                hasError: _partyNameError,
                errorText: 'Party name is required',
                child: TextField(
                  controller: _partyNameController,
                  autofocus: true,
                  style: saleFieldTextStyle,
                  decoration: buildSaleFieldDecoration(
                    hasError: _partyNameError,
                  ),
                  onChanged: (_) {
                    if (_partyNameError) {
                      setState(() => _partyNameError = false);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _LabeledField(
                label: 'GSTIN',
                child: TextField(
                  controller: _gstinController,
                  style: saleFieldTextStyle,
                  decoration: buildSaleFieldDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.info_outline, size: 18),
                      color: AppColors.textSecondary,
                      tooltip: '15-character GST identification number',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _LabeledField(
                label: 'Phone Number',
                child: TextField(
                  controller: _phoneController,
                  style: saleFieldTextStyle,
                  decoration: buildSaleFieldDecoration(),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      onTap: (_) => setState(() {}),
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorWeight: 2,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        const Tab(text: 'GST & Address'),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Credit & Balance'),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Tab(text: 'Additional Fields'),
      ],
    );
  }

  Widget _buildGstAddressTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final leftColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LabeledField(
              label: 'GST Type',
              child: SaleGenericSelectDropdown(
                value: _gstType,
                options: _gstTypes,
                onSelected: (value) => setState(() => _gstType = value),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _LabeledField(
              label: 'State',
              child: SaleGenericSelectDropdown(
                value: _state,
                options: SaleDropdownOptions.indianStates,
                onSelected: (value) => setState(() => _state = value),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _LabeledField(
              label: 'Email ID',
              child: TextField(
                controller: _emailController,
                style: saleFieldTextStyle,
                decoration: buildSaleFieldDecoration(),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        );

        final rightColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LabeledField(
              label: 'Billing Address',
              child: TextField(
                controller: _billingAddressController,
                style: saleFieldTextStyle,
                decoration: buildSaleFieldDecoration(),
                minLines: 4,
                maxLines: 4,
              ),
            ),
            if (!_showShippingAddress)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _showShippingAddress = true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                  ),
                  child: const Text(
                    '+ Enable Shipping Address',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            else ...[
              const SizedBox(height: AppSpacing.md),
              _LabeledField(
                label: 'Shipping Address',
                child: TextField(
                  controller: _shippingAddressController,
                  style: saleFieldTextStyle,
                  decoration: buildSaleFieldDecoration(),
                  minLines: 4,
                  maxLines: 4,
                ),
              ),
            ],
          ],
        );

        if (isNarrow) {
          return Column(
            children: [
              leftColumn,
              const SizedBox(height: AppSpacing.lg),
              rightColumn,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: leftColumn),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: rightColumn),
          ],
        );
      },
    );
  }

  Widget _buildCreditBalanceTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final fields = [
          _LabeledField(
            label: 'Opening Balance',
            child: TextField(
              controller: _openingBalanceController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: '0.00'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          _LabeledField(
            label: 'Credit Limit',
            child: TextField(
              controller: _creditLimitController,
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(hint: '0.00'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ];

        if (isNarrow) {
          return Column(
            children: [
              fields[0],
              const SizedBox(height: AppSpacing.md),
              fields[1],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: fields[0]),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: fields[1]),
          ],
        );
      },
    );
  }

  Widget _buildAdditionalFieldsTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Text(
          'No additional fields configured',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => _save(saveAndNew: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Save & New',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () => _save(saveAndNew: false),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.hasError = false,
    this.errorText,
  });

  final String label;
  final Widget child;
  final bool hasError;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: saleFieldLabelStyle),
        const SizedBox(height: 6),
        child,
        if (hasError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              errorText!,
              style: const TextStyle(fontSize: 11, color: saleFieldErrorColor),
            ),
          ),
      ],
    );
  }
}
