import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/validators.dart';
import 'package:billing_baba/core/widgets/text_input_dialog.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:billing_baba/features/parties/providers/party_groups_provider.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:billing_baba/features/parties/models/add_party_result.dart';

const _dialogMaxWidth = 900.0;
const _cardBorder = Color(0xFFE0E0E0);
const _gstLeftColumnWidth = 220.0;
const _defaultDecimal = '0.00';
const _defaultState = 'Andhra Pradesh';
const _successSnackBarColor = Color(0xFF2E7D32);

/// Shows the Add Party modal from sale forms and party pickers.
Future<AddPartyResult?> showAddPartyDialog(BuildContext context) {
  return showDialog<AddPartyResult>(
    context: context,
    builder: (context) => _buildPartyDialogShell(
      context: context,
      child: const AddPartyDialog(),
    ),
  );
}

/// Opens the same form pre-filled for editing an existing party.
Future<AddPartyResult?> showEditPartyDialog(
  BuildContext context, {
  required PartyModel party,
}) {
  return showDialog<AddPartyResult>(
    context: context,
    builder: (context) => _buildPartyDialogShell(
      context: context,
      child: AddPartyDialog(partyToEdit: party),
    ),
  );
}

/// Opens the add form prefilled from an existing party (new record on save).
Future<AddPartyResult?> showDuplicatePartyDialog(
  BuildContext context, {
  required PartyModel party,
}) {
  return showDialog<AddPartyResult>(
    context: context,
    builder: (context) => _buildPartyDialogShell(
      context: context,
      child: AddPartyDialog(duplicateFrom: party),
    ),
  );
}

Widget _buildPartyDialogShell({
  required BuildContext context,
  required Widget child,
}) {
  final size = MediaQuery.sizeOf(context);

  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: EdgeInsets.symmetric(
      horizontal: size.width < 640 ? AppSpacing.sm : AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: _dialogMaxWidth,
        maxHeight: size.height * FormSpacing.dialogMaxHeightFactor,
      ),
      child: child,
    ),
  );
}

class AddPartyDialog extends ConsumerStatefulWidget {
  const AddPartyDialog({
    this.partyToEdit,
    this.duplicateFrom,
    super.key,
  });

  final PartyModel? partyToEdit;
  final PartyModel? duplicateFrom;

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

  static const _partyTypes = ['customer', 'supplier', 'both'];
  static const _partyTypeLabels = {
    'customer': 'Customer',
    'supplier': 'Supplier',
    'both': 'Both',
  };

  late final TabController _tabController;
  final _partyNameController = TextEditingController();
  final _gstinController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _billingAddressLineController = TextEditingController();
  final _billingCityController = TextEditingController();
  final _billingPincodeController = TextEditingController();
  final _shippingAddressLineController = TextEditingController();
  final _shippingCityController = TextEditingController();
  final _shippingPincodeController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _loyaltyPointsOpeningBalanceController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _additionalField1Controller = TextEditingController();
  final _additionalField2Controller = TextEditingController();
  final _openingBalanceAsOfDatePickerKey =
      GlobalKey<SaleSingleDatePickerAnchorState>();

  DateTime _openingBalanceAsOfDate = DateTime.now();
  bool _useCustomCreditLimit = false;
  bool _additionalField1Enabled = false;
  bool _additionalField2Enabled = false;

  String _gstType = 'Unregistered/Consumer';
  String _state = _defaultState;
  String _billingDetailState = _defaultState;
  String _shippingDetailState = _defaultState;
  String _partyGroup = '';
  String _billingCountry = 'India';
  String _shippingCountry = 'India';
  bool _showShippingAddress = false;
  bool _showDetailedBillingAddress = false;
  bool _showDetailedShippingAddress = false;
  bool _partyNameError = false;
  String? _phoneError;
  String? _emailError;
  String? _gstinError;
  String? _openingBalanceError;
  String? _creditLimitError;
  String? _loyaltyBalanceError;
  String _partyType = 'customer';
  String _defaultPriceTier = PriceTier.retail;

  String _savedBillingAddressLine = '';
  String _savedBillingCity = '';
  String _savedBillingPincode = '';
  String _savedBillingState = _defaultState;
  String _savedBillingCountry = 'India';

  String _savedShippingAddressLine = '';
  String _savedShippingCity = '';
  String _savedShippingPincode = '';
  String _savedShippingState = _defaultState;
  String _savedShippingCountry = 'India';

  bool get _isEditMode => widget.partyToEdit != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _openingBalanceController.text = _defaultDecimal;
    _loyaltyPointsOpeningBalanceController.text = _defaultDecimal;
    final party = widget.partyToEdit;
    final duplicateFrom = widget.duplicateFrom;
    if (party != null) {
      _populateFromParty(party);
    } else if (duplicateFrom != null) {
      _populateFromParty(duplicateFrom, duplicateNameSuffix: ' (Copy)');
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyCreateDefaults());
    }
  }

  void _applyCreateDefaults() {
    if (!mounted || _isEditMode || widget.duplicateFrom != null) return;

    final businessState =
        ref.read(businessProfileProvider).asData?.value.state?.trim();
    final resolvedState =
        businessState != null &&
            businessState.isNotEmpty &&
            SaleDropdownOptions.indianStates.contains(businessState)
        ? businessState
        : _defaultState;

    final groups = ref.read(partyGroupsProvider);
    final generalGroup = groups
        .where((group) => group.toLowerCase() == 'general')
        .firstOrNull;

    setState(() {
      _state = resolvedState;
      _billingDetailState = resolvedState;
      _shippingDetailState = resolvedState;
      _savedBillingState = resolvedState;
      _savedShippingState = resolvedState;
      if (generalGroup != null) _partyGroup = generalGroup;
    });
  }

  String _resolvedBusinessState() {
    final businessState =
        ref.read(businessProfileProvider).asData?.value.state?.trim();
    if (businessState != null &&
        businessState.isNotEmpty &&
        SaleDropdownOptions.indianStates.contains(businessState)) {
      return businessState;
    }
    return _defaultState;
  }

  void _populateFromParty(PartyModel party, {String? duplicateNameSuffix}) {
    _partyNameController.text = duplicateNameSuffix == null
        ? party.name
        : '${party.name}$duplicateNameSuffix';
    _partyType = party.partyType;
    _gstinController.text = party.gstin;
    if (party.phone != '+91 00000 00000') {
      _phoneController.text = party.phone;
    }
    _emailController.text = party.email;
    _billingAddressController.text = party.billingAddress;
    _shippingAddressController.text = party.shippingAddress;
    _gstType = party.gstType.isNotEmpty
        ? party.gstType
        : 'Unregistered/Consumer';
    _state = party.state.isNotEmpty ? party.state : _resolvedBusinessState();
    _partyGroup = party.partyGroup;

    final resolvedState = party.state.isNotEmpty
        ? party.state
        : _resolvedBusinessState();
    _savedBillingAddressLine = party.addressLine;
    _savedBillingCity = party.city;
    _savedBillingPincode = party.pincode;
    _savedBillingState = resolvedState;
    _savedBillingCountry = party.country.isNotEmpty ? party.country : 'India';
    _billingAddressLineController.text = party.addressLine;
    _billingCityController.text = party.city;
    _billingPincodeController.text = party.pincode;
    _billingDetailState = _savedBillingState;
    _billingCountry = _savedBillingCountry;

    _savedShippingAddressLine = party.shippingAddressLine;
    _savedShippingCity = party.shippingCity;
    _savedShippingPincode = party.shippingPincode;
    _savedShippingState = party.state.isNotEmpty
        ? party.state
        : _resolvedBusinessState();
    _savedShippingCountry = party.shippingCountry.isNotEmpty
        ? party.shippingCountry
        : 'India';
    _shippingAddressLineController.text = party.shippingAddressLine;
    _shippingCityController.text = party.shippingCity;
    _shippingPincodeController.text = party.shippingPincode;
    _shippingDetailState = _savedShippingState;
    _shippingCountry = _savedShippingCountry;

    _showShippingAddress =
        party.shippingAddress.isNotEmpty ||
        party.shippingAddressLine.isNotEmpty;

    _openingBalanceController.text = PartyModel.formatDecimalInput(
      party.openingBalance,
    );
    _openingBalanceAsOfDate =
        party.openingBalanceAsOfDate ?? DateTime.now();

    _loyaltyPointsOpeningBalanceController.text =
        party.loyaltyPointsOpeningBalance.trim().isEmpty
        ? _defaultDecimal
        : party.loyaltyPointsOpeningBalance.trim();

    _useCustomCreditLimit = party.hasCustomCreditLimit;
    _creditLimitController.text = party.hasCustomCreditLimit
        ? PartyModel.formatDecimalInput(
            double.tryParse(party.creditLimit.replaceAll(',', '')) ?? 0,
          )
        : '';

    _additionalField1Enabled = party.additionalField1.isNotEmpty;
    _additionalField1Controller.text = party.additionalField1;
    _additionalField2Enabled = party.additionalField2.isNotEmpty;
    _additionalField2Controller.text = party.additionalField2;
    _defaultPriceTier = party.defaultPriceTier;
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
    _billingAddressLineController.dispose();
    _billingCityController.dispose();
    _billingPincodeController.dispose();
    _shippingAddressLineController.dispose();
    _shippingCityController.dispose();
    _shippingPincodeController.dispose();
    _openingBalanceController.dispose();
    _loyaltyPointsOpeningBalanceController.dispose();
    _creditLimitController.dispose();
    _additionalField1Controller.dispose();
    _additionalField2Controller.dispose();
    super.dispose();
  }

  AddPartyResult _buildResult() {
    return AddPartyResult(
      partyName: _partyNameController.text.trim(),
      partyType: _partyType,
      gstin: _gstinController.text.trim(),
      phone: _phoneController.text.trim(),
      gstType: _gstType,
      state: _state,
      email: _emailController.text.trim(),
      billingAddress: _billingAddressController.text.trim(),
      shippingAddress: _showShippingAddress
          ? _shippingAddressController.text.trim()
          : '',
      partyGroup: _partyGroup,
      addressLine: _savedBillingAddressLine,
      city: _savedBillingCity,
      pincode: _savedBillingPincode,
      country: _savedBillingCountry,
      shippingAddressLine: _savedShippingAddressLine,
      shippingCity: _savedShippingCity,
      shippingPincode: _savedShippingPincode,
      shippingCountry: _savedShippingCountry,
      openingBalance: _normalizedDecimal(_openingBalanceController.text),
      openingBalanceAsOfDate: _openingBalanceAsOfDate,
      loyaltyPointsOpeningBalance: _normalizedDecimal(
        _loyaltyPointsOpeningBalanceController.text,
      ),
      loyaltyPointsAsOfDate: _openingBalanceAsOfDate,
      hasCustomCreditLimit: _useCustomCreditLimit,
      creditLimit: _useCustomCreditLimit
          ? _normalizedDecimal(_creditLimitController.text)
          : '',
      additionalField1Enabled: _additionalField1Enabled,
      additionalField1: _additionalField1Enabled
          ? _additionalField1Controller.text.trim()
          : '',
      additionalField2Enabled: _additionalField2Enabled,
      additionalField2: _additionalField2Enabled
          ? _additionalField2Controller.text.trim()
          : '',
      defaultPriceTier: _defaultPriceTier,
    );
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _normalizedDecimal(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? _defaultDecimal : trimmed;
  }

  String _composeAddress({
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
    required String country,
  }) {
    final lines = <String>[
      if (addressLine.isNotEmpty) addressLine,
      if (city.isNotEmpty || state.isNotEmpty || pincode.isNotEmpty)
        [
          city,
          if (state.isNotEmpty) state,
          if (pincode.isNotEmpty) pincode,
        ].where((part) => part.isNotEmpty).join(', '),
      if (country.isNotEmpty && country != 'India') country,
    ];
    return lines.join('\n');
  }

  void _restoreBillingDetailedDraft() {
    _billingAddressLineController.text = _savedBillingAddressLine;
    _billingCityController.text = _savedBillingCity;
    _billingPincodeController.text = _savedBillingPincode;
    _billingDetailState = _savedBillingState;
    _billingCountry = _savedBillingCountry;
  }

  void _restoreShippingDetailedDraft() {
    _shippingAddressLineController.text = _savedShippingAddressLine;
    _shippingCityController.text = _savedShippingCity;
    _shippingPincodeController.text = _savedShippingPincode;
    _shippingDetailState = _savedShippingState;
    _shippingCountry = _savedShippingCountry;
  }

  void _cancelDetailedBillingAddress() {
    setState(() {
      _restoreBillingDetailedDraft();
      _showDetailedBillingAddress = false;
    });
  }

  void _saveDetailedBillingAddress() {
    final addressLine = _billingAddressLineController.text.trim();
    final city = _billingCityController.text.trim();
    final pincode = _billingPincodeController.text.trim();

    setState(() {
      _savedBillingAddressLine = addressLine;
      _savedBillingCity = city;
      _savedBillingPincode = pincode;
      _savedBillingState = _billingDetailState;
      _savedBillingCountry = _billingCountry;
      _billingAddressController.text = _composeAddress(
        addressLine: addressLine,
        city: city,
        state: _billingDetailState,
        pincode: pincode,
        country: _billingCountry,
      );
      _showDetailedBillingAddress = false;
    });
  }

  void _cancelDetailedShippingAddress() {
    setState(() {
      _restoreShippingDetailedDraft();
      _showDetailedShippingAddress = false;
    });
  }

  void _saveDetailedShippingAddress() {
    final addressLine = _shippingAddressLineController.text.trim();
    final city = _shippingCityController.text.trim();
    final pincode = _shippingPincodeController.text.trim();

    setState(() {
      _savedShippingAddressLine = addressLine;
      _savedShippingCity = city;
      _savedShippingPincode = pincode;
      _savedShippingState = _shippingDetailState;
      _savedShippingCountry = _shippingCountry;
      _shippingAddressController.text = _composeAddress(
        addressLine: addressLine,
        city: city,
        state: _shippingDetailState,
        pincode: pincode,
        country: _shippingCountry,
      );
      _showDetailedShippingAddress = false;
    });
  }

  bool _validate() {
    final nameValid = _partyNameController.text.trim().isNotEmpty;
    final phoneError = Validators.phone(_phoneController.text);
    final emailError = Validators.email(_emailController.text);
    final gstinError = Validators.gstin(_gstinController.text);
    final openingBalanceError = Validators.nonNegativeDecimalAmount(
      _openingBalanceController.text,
    );
    final creditLimitError = _useCustomCreditLimit
        ? Validators.nonNegativeDecimalAmount(_creditLimitController.text)
        : null;
    final loyaltyBalanceError = Validators.nonNegativeDecimalAmount(
      _loyaltyPointsOpeningBalanceController.text,
    );

    final mobileDuplicateError = _checkDuplicateMobile();
    final gstinDuplicateError = _checkDuplicateGstin();

    setState(() {
      _partyNameError = !nameValid;
      _phoneError = phoneError ?? mobileDuplicateError;
      _emailError = emailError;
      _gstinError = gstinError ?? gstinDuplicateError;
      _openingBalanceError = openingBalanceError;
      _creditLimitError = creditLimitError;
      _loyaltyBalanceError = loyaltyBalanceError;
    });

    return nameValid &&
        _phoneError == null &&
        _emailError == null &&
        _gstinError == null &&
        _openingBalanceError == null &&
        _creditLimitError == null &&
        _loyaltyBalanceError == null;
  }

  String? _checkDuplicateMobile() {
    final normalized = PartyModel.normalizePhone(_phoneController.text);
    if (normalized.isEmpty) return null;

    final parties = ref.read(partiesListProvider);
    final currentId = widget.partyToEdit?.id;
    final conflict = parties.any((party) {
      if (party.id == currentId) return false;
      final partyMobile = PartyModel.normalizePhone(party.phone);
      return partyMobile.isNotEmpty && partyMobile == normalized;
    });

    return conflict
        ? 'This mobile number is already registered to another party'
        : null;
  }

  String? _checkDuplicateGstin() {
    final gstin = _gstinController.text.trim().toUpperCase();
    if (gstin.isEmpty) return null;

    final parties = ref.read(partiesListProvider);
    final currentId = widget.partyToEdit?.id;
    final conflict = parties.any((party) {
      if (party.id == currentId) return false;
      return party.gstin.trim().toUpperCase() == gstin;
    });

    return conflict ? 'This GSTIN is already registered to another party' : null;
  }

  void _applyApiValidationErrors(ApiValidationException exception) {
    setState(() {
      _phoneError =
          exception.fieldErrors['mobile'] ??
          (exception.fieldErrors.containsKey('mobile')
              ? exception.message
              : _phoneError);
      _gstinError = exception.fieldErrors['gstin'] ?? _gstinError;
      _emailError = exception.fieldErrors['email'] ?? _emailError;
      if (exception.fieldErrors['name'] != null) {
        _partyNameError = true;
      }
      _openingBalanceError =
          exception.fieldErrors['opening_balance'] ?? _openingBalanceError;
      _creditLimitError =
          exception.fieldErrors['credit_limit'] ?? _creditLimitError;
    });
  }

  void _showSaveSnackBar({
    required String message,
    required Color backgroundColor,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _save({required bool saveAndNew}) async {
    if (!_validate()) return;

    final result = _buildResult();

    if (_isEditMode) {
      Navigator.of(context).pop(result);
      return;
    }

    if (saveAndNew) {
      await _createParty(result, resetForm: true);
      return;
    }

    Navigator.of(context).pop(result);
  }

  Future<void> _createParty(
    AddPartyResult result, {
    required bool resetForm,
  }) async {
    try {
      await ref.read(partyListProvider.notifier).createParty(result);
      _showSaveSnackBar(
        message: 'Party "${result.partyName}" saved successfully',
        backgroundColor: _successSnackBarColor,
      );
      if (resetForm) {
        _resetFormAfterSave();
      } else if (mounted) {
        Navigator.of(context).pop(result);
      }
    } on PartyOfflineException {
      _showSaveSnackBar(
        message: 'Party saved offline. It will sync when you are back online.',
        backgroundColor: Colors.orange.shade800,
      );
      if (resetForm) {
        _resetFormAfterSave();
      } else if (mounted) {
        Navigator.of(context).pop(result);
      }
      ref.invalidate(partyListProvider);
    } on ApiValidationException catch (e) {
      _applyApiValidationErrors(e);
      _showSaveSnackBar(
        message: e.message,
        backgroundColor: AppColors.error,
      );
    } on Object catch (_) {
      _showSaveSnackBar(
        message: 'Failed to save party. Please try again.',
        backgroundColor: AppColors.error,
      );
    }
  }

  void _resetFormAfterSave() {
    _partyNameController.clear();
    _gstinController.clear();
    _phoneController.clear();
    _emailController.clear();
    _billingAddressController.clear();
    _shippingAddressController.clear();
    _billingAddressLineController.clear();
    _billingCityController.clear();
    _billingPincodeController.clear();
    _shippingAddressLineController.clear();
    _shippingCityController.clear();
    _shippingPincodeController.clear();
    _openingBalanceController.text = _defaultDecimal;
    _loyaltyPointsOpeningBalanceController.text = _defaultDecimal;
    _creditLimitController.clear();
    _additionalField1Controller.clear();
    _additionalField2Controller.clear();
    setState(() {
      final defaultState = _resolvedBusinessState();
      _gstType = 'Unregistered/Consumer';
      _state = defaultState;
      _billingDetailState = defaultState;
      _shippingDetailState = defaultState;
      _partyGroup = '';
      _billingCountry = 'India';
      _shippingCountry = 'India';
      _openingBalanceAsOfDate = DateTime.now();
      _useCustomCreditLimit = false;
      _additionalField1Enabled = false;
      _additionalField2Enabled = false;
      _showShippingAddress = false;
      _showDetailedBillingAddress = false;
      _showDetailedShippingAddress = false;
      _savedBillingAddressLine = '';
      _savedBillingCity = '';
      _savedBillingPincode = '';
      _savedBillingState = defaultState;
      _savedBillingCountry = 'India';
      _savedShippingAddressLine = '';
      _savedShippingCity = '';
      _savedShippingPincode = '';
      _savedShippingState = defaultState;
      _savedShippingCountry = 'India';
      _partyNameError = false;
      _phoneError = null;
      _emailError = null;
      _gstinError = null;
      _openingBalanceError = null;
      _creditLimitError = null;
      _loyaltyBalanceError = null;
      _partyType = 'customer';
      _tabController.index = 0;
    });
    _applyCreateDefaults();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.lgBorder,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const Divider(height: 1, color: _cardBorder),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    FormSpacing.page,
                    FormSpacing.section,
                    FormSpacing.page,
                    FormSpacing.section,
                  ),
                  child: _buildTopFields(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FormSpacing.page,
                  ),
                  child: _buildTabBar(),
                ),
                const Divider(height: 1, color: _cardBorder),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(FormSpacing.page),
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
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: FormSpacing.headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FormSpacing.page),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _isEditMode ? 'Edit Party' : 'Add Party',
                style: const TextStyle(
                  fontSize: 18,
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
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFields() {
    final partyNameField = _buildInlineTextField(
      controller: _partyNameController,
      hint: 'Party Name *',
      hasError: _partyNameError,
      errorText: 'Party name is required',
      autofocus: !_isEditMode,
      onChanged: (_) {
        if (_partyNameError) {
          setState(() => _partyNameError = false);
        }
      },
    );

    final gstinField = _buildInlineTextField(
      controller: _gstinController,
      hint: 'GSTIN',
      hasError: _gstinError != null,
      errorText: _gstinError,
      onChanged: (_) {
        if (_gstinError != null) setState(() => _gstinError = null);
      },
      suffixIcon: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.info_outline, size: 18),
        color: AppColors.textSecondary,
        tooltip: '15-character GST identification number',
      ),
    );

    final phoneField = _buildInlineTextField(
      controller: _phoneController,
      hint: 'Phone Number',
      keyboardType: TextInputType.phone,
      hasError: _phoneError != null,
      errorText: _phoneError,
      onChanged: (_) {
        if (_phoneError != null) setState(() => _phoneError = null);
      },
    );

    final billingNameField = _isEditMode
        ? InputDecorator(
            decoration: buildSaleFieldDecoration(hint: 'Billing Name'),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.partyToEdit!.name,
                style: saleFieldTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        : null;

    final rowOneCells = <FormGridCell>[
      FormGridCell(
        span: _isEditMode ? 4 : 6,
        child: partyNameField,
      ),
      if (billingNameField != null)
        FormGridCell(span: 4, child: billingNameField),
      FormGridCell(
        span: _isEditMode ? 4 : 6,
        child: gstinField,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormGrid(
          rowGap: FormSpacing.section,
          cells: [
            ...rowOneCells,
            FormGridCell(span: 4, child: phoneField),
            FormGridCell(span: 4, child: _buildPartyGroupControls()),
            FormGridCell(span: 4, child: _buildDefaultPriceTierField()),
          ],
        ),
        const SizedBox(height: 4),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _partyNameController,
          builder: (context, value, _) {
            final name = value.text.trim();
            final label = name.isEmpty ? '<Party Name>' : "'$name'";
            return Text(
              '$label will be printed on your invoice.',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDefaultPriceTierField() {
    return SaleGenericSelectDropdown(
      value: PriceTier.labelFor(_defaultPriceTier),
      options: PriceTier.dropdownOptions,
      hintText: 'Default Price Tier',
      onSelected: (label) => setState(
        () => _defaultPriceTier = PriceTier.keyFromLabel(label),
      ),
    );
  }

  Widget _buildPartyGroupControls() {
    final partyGroups = ref.watch(partyGroupsProvider);
    final dropdown = SaleGenericSelectDropdown(
      value: _partyGroup,
      options: partyGroups,
      hintText: 'Party Group',
      onSelected: (value) => setState(() => _partyGroup = value),
    );

    final addGroupButton = IconButton(
      onPressed: _showAddPartyGroupDialog,
      icon: const Icon(Icons.add_circle_outline, size: 22),
      color: AppColors.primary,
      tooltip: 'Add new group',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: dropdown),
            const SizedBox(width: AppSpacing.xs),
            addGroupButton,
          ],
        ),
        if (partyGroups.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 2),
            child: Text(
              'No groups yet. Tap + to create one.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }

  Future<void> _showAddPartyGroupDialog() async {
    final groupName = await showTextInputDialog(
      context,
      title: 'New Party Group',
      hint: 'Group name',
      confirmLabel: 'Add',
      textCapitalization: TextCapitalization.words,
      decoration: buildSaleFieldDecoration(hint: 'Group name'),
      textStyle: saleFieldTextStyle,
    );

    if (groupName == null || !mounted) return;

    final added = ref.read(partyGroupsProvider.notifier).addGroup(groupName);
    if (!added) return;

    setState(() => _partyGroup = groupName);
  }

  Widget _buildInlineTextField({
    required TextEditingController controller,
    required String hint,
    bool hasError = false,
    String? errorText,
    bool autofocus = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          autofocus: autofocus,
          style: saleFieldTextStyle,
          keyboardType: keyboardType,
          decoration: buildSaleFieldDecoration(
            hint: hint,
            hasError: hasError,
            suffixIcon: suffixIcon,
          ),
          onChanged: onChanged,
        ),
        if (hasError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 11, color: saleFieldErrorColor),
            ),
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      onTap: (_) => setState(() {}),
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
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
              label: 'Party Type',
              child: SaleGenericSelectDropdown(
                value: _partyTypeLabels[_partyType] ?? 'Customer',
                options: _partyTypes
                    .map((type) => _partyTypeLabels[type]!)
                    .toList(),
                hintText: 'Party Type',
                onSelected: (label) {
                  final type = _partyTypeLabels.entries
                      .where((entry) => entry.value == label)
                      .map((entry) => entry.key)
                      .firstOrNull;
                  if (type != null) setState(() => _partyType = type);
                },
              ),
            ),
            const SizedBox(height: FormSpacing.section),
            _LabeledField(
              label: 'GST Type',
              child: SaleGenericSelectDropdown(
                value: _gstType,
                options: _gstTypes,
                onSelected: (value) => setState(() => _gstType = value),
              ),
            ),
            const SizedBox(height: FormSpacing.section),
            _LabeledField(
              label: 'State',
              child: SaleGenericSelectDropdown(
                value: _state,
                options: SaleDropdownOptions.indianStates,
                onSelected: (value) => setState(() => _state = value),
              ),
            ),
            const SizedBox(height: FormSpacing.section),
            _LabeledField(
              label: 'Email ID',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _emailController,
                    style: saleFieldTextStyle,
                    decoration: buildSaleFieldDecoration(
                      hasError: _emailError != null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 2),
                      child: Text(
                        _emailError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

        final billingSection = _buildAddressSection(
          label: 'Billing Address',
          addressController: _billingAddressController,
          showDetailed: _showDetailedBillingAddress,
          onToggleDetailed: () {
            setState(() {
              if (_showDetailedBillingAddress) {
                _showDetailedBillingAddress = false;
              } else {
                _restoreBillingDetailedDraft();
                _showDetailedBillingAddress = true;
              }
            });
          },
          detailedFields: _buildDetailedAddressFields(
            addressLineController: _billingAddressLineController,
            cityController: _billingCityController,
            pincodeController: _billingPincodeController,
            detailState: _billingDetailState,
            onStateChanged: (value) =>
                setState(() => _billingDetailState = value),
            country: _billingCountry,
            onCountryChanged: (value) =>
                setState(() => _billingCountry = value),
            onCancel: _cancelDetailedBillingAddress,
            onSave: _saveDetailedBillingAddress,
          ),
        );

        final shippingSection = _showShippingAddress
            ? _buildAddressSection(
                label: 'Shipping Address',
                addressController: _shippingAddressController,
                showDetailed: _showDetailedShippingAddress,
                onToggleDetailed: () {
                  setState(() {
                    if (_showDetailedShippingAddress) {
                      _showDetailedShippingAddress = false;
                    } else {
                      _restoreShippingDetailedDraft();
                      _showDetailedShippingAddress = true;
                    }
                  });
                },
                detailedFields: _buildDetailedAddressFields(
                  addressLineController: _shippingAddressLineController,
                  cityController: _shippingCityController,
                  pincodeController: _shippingPincodeController,
                  detailState: _shippingDetailState,
                  onStateChanged: (value) =>
                      setState(() => _shippingDetailState = value),
                  country: _shippingCountry,
                  onCountryChanged: (value) =>
                      setState(() => _shippingCountry = value),
                  onCancel: _cancelDetailedShippingAddress,
                  onSave: _saveDetailedShippingAddress,
                ),
              )
            : _buildEnableShippingAddressButton();

        final addressRow = isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  billingSection,
                  const SizedBox(height: FormSpacing.section),
                  shippingSection,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: billingSection),
                  const SizedBox(width: FormSpacing.gutter),
                  Expanded(child: shippingSection),
                ],
              );

        final rightColumn = addressRow;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              leftColumn,
              const Padding(
                padding: EdgeInsets.symmetric(vertical: FormSpacing.section),
                child: Divider(height: 1, thickness: 1, color: _cardBorder),
              ),
              rightColumn,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: _gstLeftColumnWidth, child: leftColumn),
            const SizedBox(width: FormSpacing.gutter),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: _cardBorder),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: FormSpacing.gutter),
                  child: rightColumn,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnableShippingAddressButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: TextButton(
        onPressed: () => setState(() => _showShippingAddress = true),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          '+ Enable Shipping Address',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAddressSection({
    required String label,
    required TextEditingController addressController,
    required bool showDetailed,
    required VoidCallback onToggleDetailed,
    required Widget detailedFields,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabeledField(
          label: label,
          child: TextField(
            controller: addressController,
            style: saleFieldTextStyle,
            decoration: buildSaleFieldDecoration(),
            minLines: 4,
            maxLines: 4,
          ),
        ),
        _buildDetailedAddressToggle(
          showDetailed: showDetailed,
          onPressed: onToggleDetailed,
        ),
        if (showDetailed) ...[
          const SizedBox(height: AppSpacing.md),
          detailedFields,
        ],
      ],
    );
  }

  Widget _buildDetailedAddressToggle({
    required bool showDetailed,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 4),
        ),
        icon: Icon(
          showDetailed
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 18,
        ),
        label: Text(
          showDetailed ? 'Hide detailed address' : 'Show detailed address',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDetailedAddressFields({
    required TextEditingController addressLineController,
    required TextEditingController cityController,
    required TextEditingController pincodeController,
    required String detailState,
    required ValueChanged<String> onStateChanged,
    required String country,
    required ValueChanged<String> onCountryChanged,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;

        final addressLineField = _LabeledField(
          label: 'Address',
          child: TextField(
            controller: addressLineController,
            style: saleFieldTextStyle,
            decoration: buildSaleFieldDecoration(
              hint: 'Street, building, area',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        );

        final cityField = _LabeledField(
          label: 'City',
          child: TextField(
            controller: cityController,
            style: saleFieldTextStyle,
            decoration: buildSaleFieldDecoration(hint: 'City'),
            textCapitalization: TextCapitalization.words,
          ),
        );

        final stateField = _LabeledField(
          label: 'State',
          child: SaleGenericSelectDropdown(
            value: detailState,
            options: SaleDropdownOptions.indianStates,
            onSelected: onStateChanged,
          ),
        );

        final pincodeField = _LabeledField(
          label: 'Pincode',
          child: TextField(
            controller: pincodeController,
            style: saleFieldTextStyle,
            decoration: buildSaleFieldDecoration(hint: 'Pincode'),
            keyboardType: TextInputType.number,
            maxLength: 6,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
          ),
        );

        final countryField = _LabeledField(
          label: 'Country',
          child: SaleGenericSelectDropdown(
            value: country,
            options: SaleDropdownOptions.countries,
            onSelected: onCountryChanged,
          ),
        );

        final locationFields = isNarrow
            ? Column(
                children: [
                  cityField,
                  const SizedBox(height: AppSpacing.md),
                  stateField,
                  const SizedBox(height: AppSpacing.md),
                  pincodeField,
                  const SizedBox(height: AppSpacing.md),
                  countryField,
                ],
              )
            : Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cityField),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: stateField),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: pincodeField),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: countryField),
                    ],
                  ),
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            addressLineField,
            const SizedBox(height: AppSpacing.md),
            locationFields,
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: _cardBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
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
          ],
        );
      },
    );
  }

  Widget _buildCreditBalanceTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBalanceWithDateRow(
          amountLabel: 'Opening Balance',
          amountController: _openingBalanceController,
          amountError: _openingBalanceError,
          onAmountChanged: () {
            if (_openingBalanceError != null) {
              setState(() => _openingBalanceError = null);
            }
          },
          selectedDate: _openingBalanceAsOfDate,
          datePickerKey: _openingBalanceAsOfDatePickerKey,
          onDateSelected: (date) =>
              setState(() => _openingBalanceAsOfDate = _dateOnly(date)),
        ),
        const SizedBox(height: FormSpacing.section),
        _LabeledField(
          label: 'Loyalty Points Opening Balance',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _loyaltyPointsOpeningBalanceController,
                style: saleFieldTextStyle,
                decoration: buildSaleFieldDecoration(
                  hint: _defaultDecimal,
                  hasError: _loyaltyBalanceError != null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  if (_loyaltyBalanceError != null) {
                    setState(() => _loyaltyBalanceError = null);
                  }
                },
              ),
              if (_loyaltyBalanceError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2),
                  child: Text(
                    _loyaltyBalanceError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: FormSpacing.section),
        _buildCreditLimitSection(),
      ],
    );
  }

  Widget _buildBalanceWithDateRow({
    required String amountLabel,
    required TextEditingController amountController,
    required DateTime selectedDate,
    required GlobalKey<SaleSingleDatePickerAnchorState> datePickerKey,
    required ValueChanged<DateTime> onDateSelected,
    String? amountError,
    VoidCallback? onAmountChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;

        final asOfDateField = _LabeledField(
          label: 'As of Date',
          child: SaleSingleDatePickerAnchor(
            key: datePickerKey,
            selectedDate: selectedDate,
            onDateSelected: onDateSelected,
            child: SaleFieldTrigger(
              onTap: () => datePickerKey.currentState?.toggle(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      formatSaleSingleDate(selectedDate),
                      style: saleFieldTextStyle,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        );

        final amountField = _LabeledField(
          label: amountLabel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: amountController,
                style: saleFieldTextStyle,
                decoration: buildSaleFieldDecoration(
                  hint: _defaultDecimal,
                  hasError: amountError != null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => onAmountChanged?.call(),
              ),
              if (amountError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2),
                  child: Text(
                    amountError,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              asOfDateField,
              const SizedBox(height: AppSpacing.md),
              amountField,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: asOfDateField),
            const SizedBox(width: AppSpacing.lg),
            Expanded(flex: 3, child: amountField),
          ],
        );
      },
    );
  }

  Widget _buildCreditLimitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Credit Limit', style: saleFieldLabelStyle),
        const SizedBox(height: AppSpacing.sm),
        _buildCreditLimitToggleBar(),
        if (_useCustomCreditLimit) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _creditLimitController,
                  style: saleFieldTextStyle,
                  decoration: buildSaleFieldDecoration(
                    hint: _defaultDecimal,
                    hasError: _creditLimitError != null,
                  ).copyWith(prefixText: '₹ '),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {
                    if (_creditLimitError != null) {
                      setState(() => _creditLimitError = null);
                    }
                  },
                ),
                if (_creditLimitError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 2),
                    child: Text(
                      _creditLimitError!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCreditLimitToggleBar() {
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCreditLimitToggleSegment(
            label: 'No limit',
            isSelected: !_useCustomCreditLimit,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(4),
            ),
            onTap: () => setState(() => _useCustomCreditLimit = false),
          ),
          _buildCreditLimitToggleSegment(
            label: 'Custom limit',
            isSelected: _useCustomCreditLimit,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(4),
            ),
            onTap: () => setState(() {
              _useCustomCreditLimit = true;
              if (_creditLimitController.text.trim().isEmpty) {
                _creditLimitController.text = _defaultDecimal;
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditLimitToggleSegment({
    required String label,
    required bool isSelected,
    required BorderRadius borderRadius,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: borderRadius,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalFieldsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAdditionalFieldRow(
          label: 'Additional Field 1',
          enabled: _additionalField1Enabled,
          controller: _additionalField1Controller,
          onEnabledChanged: (value) =>
              setState(() => _additionalField1Enabled = value),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildAdditionalFieldRow(
          label: 'Additional Field 2',
          enabled: _additionalField2Enabled,
          controller: _additionalField2Controller,
          onEnabledChanged: (value) =>
              setState(() => _additionalField2Enabled = value),
        ),
      ],
    );
  }

  Widget _buildAdditionalFieldRow({
    required String label,
    required bool enabled,
    required TextEditingController controller,
    required ValueChanged<bool> onEnabledChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: enabled,
          onChanged: (value) => onEnabledChanged(value ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          activeColor: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            style: saleFieldTextStyle,
            decoration: buildSaleFieldDecoration(hint: label),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return SizedBox(
      height: FormSpacing.footerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FormSpacing.page),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 480;

            final saveButton = FilledButton(
              onPressed: () => _save(saveAndNew: false),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                minimumSize: const Size(0, FormSpacing.inputHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                _isEditMode ? 'Update' : 'Save',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );

            final saveAndNewButton = OutlinedButton(
              onPressed: () => _save(saveAndNew: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                minimumSize: const Size(0, FormSpacing.inputHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Save & New',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            );

            final deleteButton = OutlinedButton(
              onPressed: _confirmAndDeleteParty,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                minimumSize: const Size(0, FormSpacing.inputHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            );

            if (_isEditMode) {
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    deleteButton,
                    const SizedBox(height: AppSpacing.sm),
                    saveButton,
                  ],
                );
              }

              return Row(
                children: [
                  deleteButton,
                  const Spacer(),
                  saveButton,
                ],
              );
            }

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  saveAndNewButton,
                  const SizedBox(height: AppSpacing.sm),
                  saveButton,
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                saveAndNewButton,
                const SizedBox(width: AppSpacing.sm),
                saveButton,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmAndDeleteParty() async {
    final party = widget.partyToEdit;
    if (party == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete party?'),
        content: Text(
          'Are you sure you want to delete "${party.name}"?\n\n'
          'If this party is linked to invoices or purchases, it will be '
          'deactivated instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(partyListProvider.notifier).deleteParty(party.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      _showSaveSnackBar(
        message: 'Party "${party.name}" deleted',
        backgroundColor: _successSnackBarColor,
      );
    } on PartyHasDependenciesException {
      if (!mounted) return;
      await _offerDeactivateParty(party);
    } on PartyOfflineException {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showSaveSnackBar(
        message:
            'Delete queued offline. It will sync when you are back online.',
        backgroundColor: Colors.orange.shade800,
      );
    } on PartyException catch (e) {
      if (!mounted) return;
      _showSaveSnackBar(
        message: e.message,
        backgroundColor: AppColors.error,
      );
    } on Object catch (_) {
      if (!mounted) return;
      _showSaveSnackBar(
        message: 'Failed to delete party. Please try again.',
        backgroundColor: AppColors.error,
      );
    }
  }

  Future<void> _offerDeactivateParty(PartyModel party) async {
    final deactivate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate party instead?'),
        content: Text(
          '"${party.name}" is linked to invoices or other documents and '
          'cannot be permanently deleted.\n\n'
          'Deactivate it to hide it from active lists. You can view inactive '
          'parties using the list filter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (deactivate != true || !mounted) return;

    try {
      await ref.read(partyListProvider.notifier).deactivateParty(party.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      _showSaveSnackBar(
        message: 'Party "${party.name}" deactivated',
        backgroundColor: _successSnackBarColor,
      );
    } on PartyOfflineException {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showSaveSnackBar(
        message:
            'Deactivation saved offline. It will sync when you are back online.',
        backgroundColor: Colors.orange.shade800,
      );
    } on PartyException catch (e) {
      if (!mounted) return;
      _showSaveSnackBar(
        message: e.message,
        backgroundColor: AppColors.error,
      );
    } on Object catch (_) {
      if (!mounted) return;
      _showSaveSnackBar(
        message: 'Failed to deactivate party. Please try again.',
        backgroundColor: AppColors.error,
      );
    }
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: saleFieldLabelStyle),
        const SizedBox(height: FormSpacing.label),
        child,
      ],
    );
  }
}
