import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/application/commerce_settings_provider.dart';
import 'package:billing_baba/features/parties/application/gstin_verification_service.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_groups_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/gstin_verification_response.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_additional_phones_field.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_profile_image_editor.dart';
import 'package:billing_baba/features/parties/presentation/widgets/gstin_verification_dialogs.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/pricing/presentation/desktop/widgets/edit_pricing_tier_labels_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/shared/utils/gstin_validator.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:billing_baba/shared/widgets/text_input_dialog.dart';
import 'package:billing_baba/shared/widgets/transaction_success_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:billing_baba/features/parties/models/add_party_result.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _gstLeftColumnWidth = 220.0;
const _defaultDecimal = '0.00';
const _defaultState = 'Andhra Pradesh';
const _saveBlue = Color(0xFF42A5F5);

/// Shows the Add Party modal from sale forms and party pickers.
Future<AddPartyResult?> showAddPartyDialog(BuildContext context) {
  if (AppPlatform.current.isMobile) {
    return _showPartyFormMobileRoute(
      context,
      child: const AddPartyDialog(),
    );
  }
  return showFormDialog<AddPartyResult>(
    context: context,
    child: const AddPartyDialog(),
  );
}

/// Opens the same form pre-filled for editing an existing party.
Future<AddPartyResult?> showEditPartyDialog(
  BuildContext context, {
  required PartyModel party,
}) {
  if (AppPlatform.current.isMobile) {
    return _showPartyFormMobileRoute(
      context,
      child: AddPartyDialog(partyToEdit: party),
    );
  }
  return showFormDialog<AddPartyResult>(
    context: context,
    child: AddPartyDialog(partyToEdit: party),
  );
}

/// Opens the add form prefilled from an existing party (new record on save).
Future<AddPartyResult?> showDuplicatePartyDialog(
  BuildContext context, {
  required PartyModel party,
}) {
  if (AppPlatform.current.isMobile) {
    return _showPartyFormMobileRoute(
      context,
      child: AddPartyDialog(duplicateFrom: party),
    );
  }
  return showFormDialog<AddPartyResult>(
    context: context,
    child: AddPartyDialog(duplicateFrom: party),
  );
}

Future<AddPartyResult?> _showPartyFormMobileRoute(
  BuildContext context, {
  required Widget child,
}) {
  return Navigator.of(context).push<AddPartyResult>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => child,
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
  final _legalNameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _areaCodeController = TextEditingController();
  final _gstinController = TextEditingController();
  final _gstinFocusNode = FocusNode();
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
  final List<TextEditingController> _additionalPhoneControllers = [];
  final List<String?> _additionalPhoneErrors = [];
  final _openingBalanceAsOfDatePickerKey =
      GlobalKey<SaleSingleDatePickerAnchorState>();

  DateTime _openingBalanceAsOfDate = DateTime.now();
  bool _useCustomCreditLimit = false;
  bool _additionalField1Enabled = false;
  bool _additionalField2Enabled = false;

  final _profileImageEditorKey = GlobalKey<PartyProfileImageEditorState>();
  String? _profileImageUrl;
  String? _profileMediaAssetId;

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
  String? _partyNameError;
  String? _phoneError;
  String? _emailError;
  String? _gstinError;
  String? _partyGroupError;
  String? _openingBalanceError;
  String? _creditLimitError;
  String? _loyaltyBalanceError;
  String _partyType = 'customer';
  String _defaultPriceTier = PriceTier.retail;
  bool _isSaving = false;
  bool _isVerifyingGstin = false;
  String? _verifiedGstin;
  GstinVerificationResponse? _lastVerificationResponse;

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

  bool get _requiresGstin =>
      _gstType == 'Registered Business - Regular' ||
      _gstType == 'Registered Business - Composition' ||
      _gstType == 'SEZ';

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
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _applyCreateDefaults(),
      );
    }
  }

  void _applyCreateDefaults() {
    if (!mounted || _isEditMode || widget.duplicateFrom != null) return;

    final businessState = ref
        .read(businessProfileProvider)
        .asData
        ?.value
        .state
        ?.trim();
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
    final businessState = ref
        .read(businessProfileProvider)
        .asData
        ?.value
        .state
        ?.trim();
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
    _legalNameController.text = party.legalName;
    _aliasController.text = party.alias;
    _areaCodeController.text = party.areaCode;
    _partyType = party.partyType;
    _gstinController.text = party.gstin;
    if (party.phone != '+91 00000 00000') {
      final normalizedPhone = PartyModel.normalizePhone(party.phone);
      if (normalizedPhone.isNotEmpty) {
        _phoneController.text = normalizedPhone;
      }
    }
    _setAdditionalPhones(
      party.additionalPhones
          .map(PartyModel.normalizePhone)
          .where((phone) => phone.isNotEmpty)
          .toList(),
    );
    _emailController.text = party.email;
    _billingAddressController.text = party.billingAddress;
    _shippingAddressController.text = party.shippingAddress;
    _gstType = party.gstType.isNotEmpty
        ? party.gstType
        : 'Unregistered/Consumer';
    _state = party.state.isNotEmpty ? party.state : _resolvedBusinessState();
    _partyGroup = party.partyGroup;
    if (duplicateNameSuffix == null) {
      _profileImageUrl = party.profileImageUrl;
      _profileMediaAssetId = party.profileMediaAssetId;
    }

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
    _openingBalanceAsOfDate = party.openingBalanceAsOfDate ?? DateTime.now();

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

  void _setAdditionalPhones(List<String> phones) {
    for (final controller in _additionalPhoneControllers) {
      controller.dispose();
    }
    _additionalPhoneControllers.clear();
    _additionalPhoneErrors.clear();
    for (final phone in phones.take(kMaxPartyAdditionalPhones)) {
      _additionalPhoneControllers.add(TextEditingController(text: phone));
      _additionalPhoneErrors.add(null);
    }
  }

  void _addAdditionalPhoneField() {
    if (_additionalPhoneControllers.length >= kMaxPartyAdditionalPhones) {
      return;
    }
    setState(() {
      _additionalPhoneControllers.add(TextEditingController());
      _additionalPhoneErrors.add(null);
    });
  }

  void _removeAdditionalPhoneField(int index) {
    setState(() {
      _additionalPhoneControllers[index].dispose();
      _additionalPhoneControllers.removeAt(index);
      if (index < _additionalPhoneErrors.length) {
        _additionalPhoneErrors.removeAt(index);
      }
    });
  }

  List<String> _collectAdditionalPhones() {
    return _additionalPhoneControllers
        .map((controller) => controller.text.trim())
        .where((phone) => phone.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _partyNameController.dispose();
    _legalNameController.dispose();
    _aliasController.dispose();
    _areaCodeController.dispose();
    _gstinController.dispose();
    _gstinFocusNode.dispose();
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
    for (final controller in _additionalPhoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  AddPartyResult _buildResult() {
    return AddPartyResult(
      partyName: _partyNameController.text.trim(),
      legalName: _legalNameController.text.trim(),
      alias: _aliasController.text.trim(),
      partyType: _partyType,
      gstin: _gstinController.text.trim(),
      phone: _phoneController.text.trim(),
      additionalPhones: _collectAdditionalPhones(),
      gstType: _gstType,
      state: _state,
      email: _emailController.text.trim(),
      billingAddress: _billingAddressController.text.trim(),
      shippingAddress: _showShippingAddress
          ? _shippingAddressController.text.trim()
          : '',
      partyGroup: _partyGroup,
      areaCode: _areaCodeController.text.trim(),
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

  String? _validateGstinField() {
    final value = _gstinController.text.trim();
    if (_requiresGstin && value.isEmpty) {
      return 'GSTIN is required for registered businesses';
    }
    return Validators.gstin(value);
  }

  Future<void> _verifyGstin() async {
    if (_isVerifyingGstin) return;

    final gstin = GstinValidator.normalize(_gstinController.text);
    if (!GstinValidator.isValid(gstin)) {
      setState(() => _gstinError = 'Please enter a valid GSTIN.');
      _gstinFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isVerifyingGstin = true;
      _gstinError = null;
    });
    showGstinVerificationLoadingDialog(context);
    try {
      final service = await ref.read(gstinVerificationServiceProvider.future);
      final response = await service.verify(gstin);
      await hideGstinVerificationLoadingDialog();
      if (!mounted) return;

      setState(() {
        _verifiedGstin = gstin;
        _lastVerificationResponse = response;
      });

      final useDetails = await showGstinVerificationConfirmationDialog(
        context,
        response.data,
      );
      if (useDetails == true) {
        _applyGstinVerification(response.data);
      }
    } on DioException catch (error) {
      await hideGstinVerificationLoadingDialog();
      if (!mounted) return;
      final message = ApiErrorParser.isOffline(error)
          ? OfflineUiMessages.workingOffline
          : ApiErrorParser.userFacingMessage(error);
      await showGstinVerificationErrorDialog(context, message: message);
    } catch (_) {
      await hideGstinVerificationLoadingDialog();
      if (!mounted) return;
      await showGstinVerificationErrorDialog(
        context,
        message: 'Unable to verify GSTIN. Please try again later.',
      );
    } finally {
      await hideGstinVerificationLoadingDialog();
      if (mounted) {
        setState(() => _isVerifyingGstin = false);
      }
    }
  }

  Future<void> _showStoredGstinVerificationDetails() async {
    final response = _lastVerificationResponse;
    if (response == null) return;

    final useDetails = await showGstinVerificationConfirmationDialog(
      context,
      response.data,
    );
    if (useDetails == true) {
      _applyGstinVerification(response.data);
    }
  }

  void _handleGstinChanged(String value) {
    final normalized = GstinValidator.normalize(value);
    final shouldClearVerified =
        _verifiedGstin != null && normalized != _verifiedGstin;
    if (_gstinError != null || shouldClearVerified) {
      setState(() {
        if (_gstinError != null) _gstinError = null;
        if (shouldClearVerified) {
          _verifiedGstin = null;
          _lastVerificationResponse = null;
        }
      });
    }
  }

  Widget _buildGstinSuffixIcon() {
    const verifiedColor = Color(0xFF2E7D32);
    final normalized = GstinValidator.normalize(_gstinController.text);
    final isVerified =
        _verifiedGstin != null &&
        normalized.isNotEmpty &&
        normalized == _verifiedGstin;

    if (isVerified) {
      return IconButton(
        onPressed: _isVerifyingGstin ? null : _showStoredGstinVerificationDetails,
        icon: const Icon(Icons.check_circle, size: 18, color: verifiedColor),
        color: verifiedColor,
        tooltip: 'View GST details',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: saleFieldHeight - 8,
          height: saleFieldHeight - 2,
        ),
        visualDensity: VisualDensity.compact,
      );
    }

    return IconButton(
      onPressed: _isVerifyingGstin ? null : _verifyGstin,
      icon: const Icon(Icons.search, size: 18),
      color: AppColors.textSecondary,
      tooltip: 'Verify GSTIN',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: saleFieldHeight - 8,
        height: saleFieldHeight - 2,
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  void _applyGstinVerification(GstinDetails data) {
    final gstinWasEmpty = _gstinController.text.trim().isEmpty;
    final billingWasEmpty = _billingAddressController.text.trim().isEmpty;
    final partyName = data.tradeName.trim().isNotEmpty
        ? data.tradeName.trim()
        : data.legalName.trim();
    _setControllerIfEmpty(_partyNameController, partyName);
    _setControllerIfEmpty(_legalNameController, data.legalName);
    _setControllerIfEmpty(_gstinController, data.gstin);
    _setControllerIfEmpty(_billingAddressController, data.address);

    if (billingWasEmpty &&
        data.state.trim().isNotEmpty &&
        SaleDropdownOptions.indianStates.contains(data.state)) {
      setState(() {
        _state = data.state;
        _billingDetailState = data.state;
        _savedBillingState = data.state;
      });
    }

    if (gstinWasEmpty) {
      setState(() {
        _gstType = _mapTaxpayerTypeToGstType(data.taxpayerType);
      });
    }
  }

  void _setControllerIfEmpty(TextEditingController controller, String value) {
    if (controller.text.trim().isEmpty && value.trim().isNotEmpty) {
      controller.text = value.trim();
    }
  }

  String _mapTaxpayerTypeToGstType(String taxpayerType) {
    final normalized = taxpayerType.trim().toLowerCase();
    if (normalized == 'composition') {
      return 'Registered Business - Composition';
    }
    if (normalized == 'regular') {
      return 'Registered Business - Regular';
    }
    return 'Registered Business - Regular';
  }

  bool _validate() {
    final partyNameError = Validators.partyName(_partyNameController.text);
    final phoneError = Validators.requiredPhone(_phoneController.text);
    final emailError = Validators.email(_emailController.text);
    final gstinError = _validateGstinField();
    final partyGroupError = Validators.requiredSelection(
      _partyGroup,
      fieldName: 'Party group',
    );
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
    final additionalPhoneErrors = _validateAdditionalPhones();

    setState(() {
      _partyNameError = partyNameError;
      _phoneError = phoneError ?? mobileDuplicateError;
      _emailError = emailError;
      _gstinError = gstinError ?? gstinDuplicateError;
      _partyGroupError = partyGroupError;
      _openingBalanceError = openingBalanceError;
      _creditLimitError = creditLimitError;
      _loyaltyBalanceError = loyaltyBalanceError;
      _additionalPhoneErrors
        ..clear()
        ..addAll(additionalPhoneErrors);
    });

    final additionalPhonesValid = additionalPhoneErrors.every(
      (error) => error == null,
    );

    final isValid =
        partyNameError == null &&
        _phoneError == null &&
        additionalPhonesValid &&
        _emailError == null &&
        _gstinError == null &&
        partyGroupError == null &&
        _openingBalanceError == null &&
        _creditLimitError == null &&
        _loyaltyBalanceError == null;

    if (!isValid) {
      _showValidationFeedback();
      if (_tabController.index != 0 &&
          (partyGroupError != null ||
              _emailError != null ||
              gstinError != null ||
              gstinDuplicateError != null)) {
        _tabController.index = 0;
      } else if (_tabController.index != 1 &&
          (_openingBalanceError != null ||
              _creditLimitError != null ||
              _loyaltyBalanceError != null)) {
        _tabController.index = 1;
      }
    }

    return isValid;
  }

  void _showValidationFeedback() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill in all required fields correctly'),
      ),
    );
  }

  List<String?> _validateAdditionalPhones() {
    final seen = <String>{
      PartyModel.normalizePhone(_phoneController.text),
    };
    final errors = <String?>[];

    for (final controller in _additionalPhoneControllers) {
      final value = controller.text.trim();
      if (value.isEmpty) {
        errors.add('Enter a phone number or remove this field');
        continue;
      }

      final formatError = Validators.phone(value);
      if (formatError != null) {
        errors.add(formatError);
        continue;
      }

      final normalized = PartyModel.normalizePhone(value);
      if (seen.contains(normalized)) {
        errors.add('Duplicate phone number');
        continue;
      }

      final duplicateError = _checkDuplicatePhoneNumber(normalized);
      if (duplicateError != null) {
        errors.add(duplicateError);
        continue;
      }

      seen.add(normalized);
      errors.add(null);
    }

    return errors;
  }

  String? _checkDuplicatePhoneNumber(String normalized) {
    if (normalized.isEmpty) return null;

    final parties = ref.read(partiesListProvider);
    final currentId = widget.partyToEdit?.id;
    final conflict = parties.any((party) {
      if (party.id == currentId) return false;
      final allPhones = [
        PartyModel.normalizePhone(party.phone),
        ...party.additionalPhones.map(PartyModel.normalizePhone),
      ];
      return allPhones.any(
        (phone) => phone.isNotEmpty && phone == normalized,
      );
    });

    return conflict
        ? 'This mobile number is already registered to another party'
        : null;
  }

  String? _checkDuplicateMobile() {
    final normalized = PartyModel.normalizePhone(_phoneController.text);
    return _checkDuplicatePhoneNumber(normalized);
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

    return conflict
        ? 'This GSTIN is already registered to another party'
        : null;
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
        _partyNameError = exception.fieldErrors['name'];
      }
      _openingBalanceError =
          exception.fieldErrors['opening_balance'] ?? _openingBalanceError;
      _creditLimitError =
          exception.fieldErrors['credit_limit'] ?? _creditLimitError;
    });
  }

  void _showSaveFeedback({
    required String message,
    required bool isError,
  }) {
    if (!mounted) return;
    if (isError) {
      showTransactionErrorToast(context, message: message);
      return;
    }
    showTransactionSuccessToast(context, message: message);
  }

  Future<void> _save({required bool saveAndNew}) async {
    if (_isSaving) return;
    if (!_validate()) return;

    final result = _buildResult();

    if (_isEditMode) {
      await _updateParty(result);
      return;
    }

    await _createParty(
      result,
      resetForm: saveAndNew,
      selectCreated: !saveAndNew,
    );
  }

  Future<void> _updateParty(AddPartyResult result) async {
    final party = widget.partyToEdit;
    if (party == null) return;

    setState(() => _isSaving = true);

    try {
      // Finish any in-flight photo upload before PATCHing / closing the dialog.
      // Otherwise Update overwrites list/detail with a party that still has no
      // profile image, and a disposed editor never patches the final URL.
      final editor = _profileImageEditorKey.currentState;
      if (editor != null) {
        await editor.waitForIdle();
        _profileImageUrl = editor.imageUrl ?? _profileImageUrl;
        _profileMediaAssetId = editor.mediaAssetId ?? _profileMediaAssetId;
      }

      final updated = await ref
          .read(partyListProvider.notifier)
          .updateParty(
            party.id,
            result,
            isActive: party.isActive,
          );

      // If Update raced ahead of bind on the server, keep the uploaded image.
      final imageUrl = _profileImageUrl ?? updated.profileImageUrl;
      final mediaId = _profileMediaAssetId ?? updated.profileMediaAssetId;
      if (imageUrl != updated.profileImageUrl ||
          mediaId != updated.profileMediaAssetId) {
        ref
            .read(partyListProvider.notifier)
            .patchProfileImage(
              party.id,
              profileImageUrl: imageUrl,
              profileMediaAssetId: mediaId,
              clear: imageUrl == null && mediaId == null,
            );
      }

      if (!mounted) return;

      _showSaveFeedback(
        message: 'Party "${result.partyName}" updated successfully',
        isError: false,
      );
      Navigator.of(context).pop(result);
    } on PartyOfflineException {
      if (!mounted) return;
      _showSaveFeedback(
        message: 'Update saved offline. It will sync when you are back online.',
        isError: false,
      );
      Navigator.of(context).pop(result);
      ref.invalidate(partyListProvider);
    } on ApiValidationException catch (e) {
      if (!mounted) return;
      _applyApiValidationErrors(e);
      _showSaveFeedback(message: e.message, isError: true);
    } on PartyException catch (e) {
      if (!mounted) return;
      _showSaveFeedback(message: e.message, isError: true);
    } on PartyBusinessNotSelectedException {
      if (!mounted) return;
      _showSaveFeedback(
        message: 'Business not selected. Please select a business first.',
        isError: true,
      );
    } on Object catch (_) {
      if (!mounted) return;
      _showSaveFeedback(
        message: 'Failed to update party. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _createParty(
    AddPartyResult result, {
    required bool resetForm,
    required bool selectCreated,
  }) async {
    setState(() => _isSaving = true);

    try {
      final created = await ref
          .read(partyListProvider.notifier)
          .createParty(
            result,
            selectCreated: selectCreated,
          );
      if (!mounted) return;

      final editor = _profileImageEditorKey.currentState;
      if (editor != null && editor.hasPendingUpload) {
        try {
          await editor.flushPendingUpload(created.id);
          ref
              .read(partyListProvider.notifier)
              .patchProfileImage(
                created.id,
                profileImageUrl: _profileImageUrl,
                profileMediaAssetId: _profileMediaAssetId,
              );
        } on Object {
          if (mounted) {
            _showSaveFeedback(
              message:
                  'Party saved, but profile photo upload failed. You can retry from Edit.',
              isError: true,
            );
          }
        }
      }

      _showSaveFeedback(
        message: 'Party "${result.partyName}" saved successfully',
        isError: false,
      );

      if (resetForm) {
        _resetFormAfterSave();
      } else {
        Navigator.of(context).pop(result);
      }
    } on PartyOfflineException {
      if (!mounted) return;
      _showSaveFeedback(
        message: 'Party saved offline. It will sync when you are back online.',
        isError: false,
      );
      if (resetForm) {
        _resetFormAfterSave();
      } else {
        Navigator.of(context).pop(result);
      }
      ref.invalidate(partyListProvider);
    } on ApiValidationException catch (e) {
      if (!mounted) return;
      _applyApiValidationErrors(e);
      _showSaveFeedback(message: e.message, isError: true);
    } on PartyException catch (e) {
      if (!mounted) return;
      _showSaveFeedback(message: e.message, isError: true);
    } on PartyBusinessNotSelectedException {
      if (!mounted) return;
      _showSaveFeedback(
        message: 'Business not selected. Please select a business first.',
        isError: true,
      );
    } on Object catch (_) {
      if (!mounted) return;
      _showSaveFeedback(
        message: 'Failed to save party. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _resetFormAfterSave() {
    _partyNameController.clear();
    _legalNameController.clear();
    _aliasController.clear();
    _areaCodeController.clear();
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
    _setAdditionalPhones(const []);
    final defaultState = _resolvedBusinessState();
    setState(() {
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
      _partyNameError = null;
      _profileImageUrl = null;
      _profileMediaAssetId = null;
      _phoneError = null;
      _emailError = null;
      _gstinError = null;
      _partyGroupError = null;
      _openingBalanceError = null;
      _creditLimitError = null;
      _loyaltyBalanceError = null;
      _partyType = 'customer';
      _defaultPriceTier = PriceTier.retail;
      _verifiedGstin = null;
      _lastVerificationResponse = null;
      _isVerifyingGstin = false;
    });
    // Must not change TabController.index inside setState — AnimatedBuilder
    // listens to the controller and would rebuild during this frame.
    if (_tabController.index != 0) {
      _tabController.index = 0;
    }
    _applyCreateDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppPlatform.current.isMobile;
    final content = _buildDialogContent(showHeader: !isMobile, rounded: !isMobile);

    if (isMobile) {
      final title = _isEditMode ? 'Edit Party' : 'Add Party';
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_isEditMode)
              IconButton(
                tooltip: 'Delete party',
                onPressed: _isSaving ? null : _confirmAndDeleteParty,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        body: SafeArea(top: false, child: content),
      );
    }

    return content;
  }

  Widget _buildDialogContent({required bool showHeader, required bool rounded}) {
    return Material(
      color: AppColors.surface,
      borderRadius: rounded ? AppRadius.lgBorder : BorderRadius.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHeader) ...[
                _buildHeader(),
                const Divider(height: 1, color: _cardBorder),
              ],
              Expanded(
                child: SingleChildScrollView(
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
                      Padding(
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
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: _cardBorder),
              _buildFooter(),
            ],
          ),
          if (_isSaving)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.08),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
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
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
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
      hasError: _partyNameError != null,
      errorText: _partyNameError,
      autofocus: !_isEditMode,
      maxLength: Validators.partyNameMaxLength,
      inputFormatters: [
        LengthLimitingTextInputFormatter(Validators.partyNameMaxLength),
        FilteringTextInputFormatter.allow(Validators.businessNameInputPattern),
      ],
      onChanged: (_) {
        if (_partyNameError != null) {
          setState(() => _partyNameError = null);
        }
      },
    );

    final legalNameField = _buildInlineTextField(
      controller: _legalNameController,
      hint: 'Legal Name',
    );

    final aliasField = _buildInlineTextField(
      controller: _aliasController,
      hint: 'Alias',
    );

    final areaCodeField = _buildInlineTextField(
      controller: _areaCodeController,
      hint: 'Area Code',
    );

    final gstinField = _buildInlineTextField(
      controller: _gstinController,
      focusNode: _gstinFocusNode,
      hint: _requiresGstin ? 'GSTIN *' : 'GSTIN',
      hasError: _gstinError != null,
      errorText: _gstinError,
      onChanged: _handleGstinChanged,
      suffixIcon: _buildGstinSuffixIcon(),
    );

    final phoneField = _buildInlineTextField(
      controller: _phoneController,
      hint: 'Mobile Number *',
      keyboardType: TextInputType.number,
      maxLength: 10,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      hasError: _phoneError != null,
      errorText: _phoneError,
      onChanged: (_) {
        if (_phoneError != null) setState(() => _phoneError = null);
      },
    );

    final rowOneCells = <FormGridCell>[
      FormGridCell(span: 4, child: partyNameField),
      FormGridCell(span: 4, child: legalNameField),
      FormGridCell(span: 4, child: aliasField),
      FormGridCell(span: 4, child: gstinField),
      FormGridCell(span: 4, child: phoneField),
      FormGridCell(span: 4, child: _buildPartyGroupControls()),
      FormGridCell(span: 4, child: areaCodeField),
      FormGridCell(span: 4, child: _buildDefaultPriceTierField()),
    ];

    final seed =
        widget.partyToEdit?.id ??
        widget.duplicateFrom?.id ??
        _partyNameController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: PartyProfileImageEditor(
            key: _profileImageEditorKey,
            partyId: widget.partyToEdit?.id,
            partyName: _partyNameController.text,
            seed: seed.isEmpty ? 'party' : seed,
            initialImageUrl: _profileImageUrl,
            initialMediaAssetId: _profileMediaAssetId,
            onChanged: ({required imageUrl, required mediaAssetId}) {
              _profileImageUrl = imageUrl;
              _profileMediaAssetId = mediaAssetId;
              final partyId = widget.partyToEdit?.id;
              if (partyId != null) {
                ref
                    .read(partyListProvider.notifier)
                    .patchProfileImage(
                      partyId,
                      profileImageUrl: imageUrl,
                      profileMediaAssetId: mediaAssetId,
                      clear: imageUrl == null && mediaAssetId == null,
                    );
              }
            },
          ),
        ),
        const SizedBox(height: FormSpacing.section),
        FormGrid(
          rowGap: FormSpacing.section,
          cells: rowOneCells,
        ),
        if (_additionalPhoneControllers.isNotEmpty) ...[
          const SizedBox(height: FormSpacing.section),
          PartyAdditionalPhonesField(
            controllers: _additionalPhoneControllers,
            errors:
                _additionalPhoneErrors.length ==
                    _additionalPhoneControllers.length
                ? _additionalPhoneErrors
                : List<String?>.filled(
                    _additionalPhoneControllers.length,
                    null,
                  ),
            onAdd: _addAdditionalPhoneField,
            onRemove: _removeAdditionalPhoneField,
            onChanged: (_) => setState(() {}),
            fieldBuilder: buildAdditionalPhoneInput,
          ),
        ] else ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addAdditionalPhoneField,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add another number'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
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
    final tierLabels = ref.watch(pricingTierLabelsProvider);
    return SaleGenericSelectDropdown(
      value: PriceTier.labelFor(
        _defaultPriceTier,
        apiTierLabels: tierLabels,
      ),
      options: PriceTier.dropdownOptionsFor(apiTierLabels: tierLabels),
      hintText: 'Default Price Tier',
      footerActionLabel: 'Customize tier names',
      onFooterAction: _showCustomizeTierNamesDialog,
      onSelected: (label) => setState(
        () => _defaultPriceTier = PriceTier.keyFromLabel(
          label,
          apiTierLabels: tierLabels,
        ),
      ),
    );
  }

  Future<void> _showCustomizeTierNamesDialog() async {
    await showEditPricingTierLabelsDialog(context);
    if (mounted) setState(() {});
  }

  Widget _buildPartyGroupControls() {
    final partyGroups = ref.watch(partyGroupsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SaleGenericSelectDropdown(
          value: _partyGroup,
          options: partyGroups,
          hintText: 'Party Group *',
          hasError: _partyGroupError != null,
          footerActionLabel: 'Add new group',
          onFooterAction: _showAddPartyGroupDialog,
          onSelected: (value) => setState(() {
            _partyGroup = value;
            _partyGroupError = null;
          }),
        ),
        if (_partyGroupError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              _partyGroupError!,
              style: const TextStyle(fontSize: 11, color: saleFieldErrorColor),
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
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SaleTextField(
          controller: controller,
          hint: hint,
          hasError: hasError,
          autofocus: autofocus,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          suffixIcon: suffixIcon,
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
                onSelected: (value) => setState(() {
                  _gstType = value;
                  if (!_requiresGstin && _gstinError != null) {
                    _gstinError = null;
                  }
                }),
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
                  SaleTextField(
                    controller: _emailController,
                    hasError: _emailError != null,
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
            decoration: buildSaleFieldDecoration(fixedHeight: false),
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
          child: SaleTextField(
            controller: addressLineController,
            hint: 'Street, building, area',
            textCapitalization: TextCapitalization.sentences,
          ),
        );

        final cityField = _LabeledField(
          label: 'City',
          child: SaleTextField(
            controller: cityController,
            hint: 'City',
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
          child: SaleTextField(
            controller: pincodeController,
            hint: 'Pincode',
            keyboardType: TextInputType.number,
            maxLength: 6,
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
              SaleTextField(
                controller: _loyaltyPointsOpeningBalanceController,
                hint: _defaultDecimal,
                hasError: _loyaltyBalanceError != null,
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
              SaleTextField(
                controller: amountController,
                hint: _defaultDecimal,
                hasError: amountError != null,
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
                SaleTextField(
                  controller: _creditLimitController,
                  hint: _defaultDecimal,
                  hasError: _creditLimitError != null,
                  prefix: const Text('₹ ', style: saleFieldTextStyle),
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
          child: SaleTextField(
            controller: controller,
            enabled: enabled,
            hint: label,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final isMobile = AppPlatform.current.isMobile;
    if (isMobile && !_isEditMode) {
      return _buildMobileCreateFooter();
    }
    if (isMobile && _isEditMode) {
      return _buildMobileEditFooter();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FormSpacing.page,
          AppSpacing.sm,
          FormSpacing.page,
          AppSpacing.sm,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 480;

            final saveButton = FilledButton(
              onPressed: _isSaving ? null : () => _save(saveAndNew: false),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
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
              onPressed: _isSaving ? null : () => _save(saveAndNew: true),
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
              onPressed: _isSaving ? null : _confirmAndDeleteParty,
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
                  mainAxisSize: MainAxisSize.min,
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
                mainAxisSize: MainAxisSize.min,
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

  Widget _buildMobileCreateFooter() {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isSaving ? null : () => _save(saveAndNew: true),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
                ),
                child: Text(
                  'Save & New',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving ? null : () => _save(saveAndNew: false),
                style: FilledButton.styleFrom(
                  backgroundColor: _saveBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileEditFooter() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: _isSaving ? null : () => _save(saveAndNew: false),
          style: FilledButton.styleFrom(
            backgroundColor: _saveBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Update'),
        ),
      ),
    );
  }

  Future<void> _confirmAndDeleteParty() async {
    final party = widget.partyToEdit;
    if (party == null) return;

    await PartyActions.delete(
      context,
      ref,
      party,
      onSuccess: () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
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
