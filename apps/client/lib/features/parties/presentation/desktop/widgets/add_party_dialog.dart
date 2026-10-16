import 'dart:async';
import 'dart:math' as math;

import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/application/commerce_settings_provider.dart';
import 'package:billing_baba/features/parties/application/device_contact_import_service.dart';
import 'package:billing_baba/features/parties/application/gstin_verification_service.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_groups_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/gstin_verification_response.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_additional_phone_detail.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_additional_phone_dialog.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_actions.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_profile_image_editor.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_settings_side_panel.dart';
import 'package:billing_baba/features/parties/presentation/mobile/party_contact_import_session_page.dart';
import 'package:billing_baba/features/parties/presentation/mobile/widgets/device_contact_picker_sheet.dart';
import 'package:billing_baba/features/parties/presentation/widgets/gstin_verification_dialogs.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:billing_baba/features/settings/application/party_settings_provider.dart';
import 'package:billing_baba/features/settings/models/party_settings.dart';
import 'package:billing_baba/features/pricing/presentation/desktop/widgets/edit_pricing_tier_labels_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_single_date_picker.dart';
import 'package:billing_baba/shared/utils/clear_zero_decimal_on_focus.dart';
import 'package:billing_baba/shared/utils/gstin_validator.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/shared/widgets/close_form_dialog.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:billing_baba/shared/widgets/text_input_dialog.dart';
import 'package:billing_baba/shared/widgets/transaction_success_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

export 'package:billing_baba/features/parties/models/add_party_result.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _partySectionPanelFill = Color(0xFFF7F8FA);
const _partySectionPanelBorder = Color(0xFFE8EAED);
const _gstLeftColumnWidth = 220.0;
const _defaultDecimal = '0.00';
const _defaultState = 'Andhra Pradesh';
const _saveBlue = Color(0xFF42A5F5);
const _vyaparReceiveRadioColor = Color(0xFF00897B);
const _creditBalanceFieldMaxWidth = 280.0;
const _partyAdditionalRowMinHeight = 40.0;

enum _PartyDialogDensityTier { comfortable, compact, tight }

/// Responsive spacing and control sizes so the party dialog fits with less scrolling.
class _PartyDialogDensity {
  const _PartyDialogDensity({
    required this.tier,
    required this.pagePaddingH,
    required this.pagePaddingTop,
    required this.pagePaddingBottom,
    required this.sectionGap,
    required this.gridRowGap,
    required this.profileImageSize,
    required this.addressMinLines,
    required this.showHeaderSubtitle,
    required this.headerTitleSize,
    required this.gstTwoColumnMinWidth,
    required this.gstLeftColumnWidth,
    required this.tabIconSize,
    required this.footerVerticalPadding,
    required this.controlHeight,
    required this.fieldFontSize,
  });

  final _PartyDialogDensityTier tier;
  final double pagePaddingH;
  final double pagePaddingTop;
  final double pagePaddingBottom;
  final double sectionGap;
  final double gridRowGap;
  final double profileImageSize;
  final int addressMinLines;
  final bool showHeaderSubtitle;
  final double headerTitleSize;
  final double gstTwoColumnMinWidth;
  final double gstLeftColumnWidth;
  final double tabIconSize;
  final double footerVerticalPadding;
  final double controlHeight;
  final double fieldFontSize;

  bool get useCompactFields => tier != _PartyDialogDensityTier.comfortable;
  bool get isTight => tier == _PartyDialogDensityTier.tight;

  _PartyDialogDensity copyWith({
    double? controlHeight,
    double? fieldFontSize,
  }) {
    return _PartyDialogDensity(
      tier: tier,
      pagePaddingH: pagePaddingH,
      pagePaddingTop: pagePaddingTop,
      pagePaddingBottom: pagePaddingBottom,
      sectionGap: sectionGap,
      gridRowGap: gridRowGap,
      profileImageSize: profileImageSize,
      addressMinLines: addressMinLines,
      showHeaderSubtitle: showHeaderSubtitle,
      headerTitleSize: headerTitleSize,
      gstTwoColumnMinWidth: gstTwoColumnMinWidth,
      gstLeftColumnWidth: gstLeftColumnWidth,
      tabIconSize: tabIconSize,
      footerVerticalPadding: footerVerticalPadding,
      controlHeight: controlHeight ?? this.controlHeight,
      fieldFontSize: fieldFontSize ?? this.fieldFontSize,
    );
  }

  static const comfortable = _PartyDialogDensity(
    tier: _PartyDialogDensityTier.comfortable,
    pagePaddingH: FormSpacing.page,
    pagePaddingTop: FormSpacing.section + 4,
    pagePaddingBottom: FormSpacing.section + 8,
    sectionGap: FormSpacing.section,
    gridRowGap: 20,
    profileImageSize: 108,
    addressMinLines: 3,
    showHeaderSubtitle: true,
    headerTitleSize: 18,
    gstTwoColumnMinWidth: 720,
    gstLeftColumnWidth: _gstLeftColumnWidth,
    tabIconSize: 16,
    footerVerticalPadding: AppSpacing.sm,
    controlHeight: saleFieldHeight,
    fieldFontSize: 14,
  );

  static const compact = _PartyDialogDensity(
    tier: _PartyDialogDensityTier.compact,
    pagePaddingH: 14,
    pagePaddingTop: 8,
    pagePaddingBottom: 8,
    sectionGap: 6,
    gridRowGap: 10,
    profileImageSize: 80,
    addressMinLines: 2,
    showHeaderSubtitle: true,
    headerTitleSize: 16,
    gstTwoColumnMinWidth: 920,
    gstLeftColumnWidth: 188,
    tabIconSize: 14,
    footerVerticalPadding: 5,
    controlHeight: 36,
    fieldFontSize: 13,
  );

  static const tight = _PartyDialogDensity(
    tier: _PartyDialogDensityTier.tight,
    pagePaddingH: 10,
    pagePaddingTop: 6,
    pagePaddingBottom: 6,
    sectionGap: 4,
    gridRowGap: 6,
    profileImageSize: 64,
    addressMinLines: 1,
    showHeaderSubtitle: false,
    headerTitleSize: 15,
    gstTwoColumnMinWidth: 10000,
    gstLeftColumnWidth: 180,
    tabIconSize: 13,
    footerVerticalPadding: 3,
    controlHeight: saleCompactFieldHeight,
    fieldFontSize: 12,
  );

  static _PartyDialogDensity from(BoxConstraints constraints) {
    final height = constraints.maxHeight;
    final width = constraints.maxWidth;
    if (!height.isFinite || height <= 0) return comfortable;

    final minSide = math.min(height, width);
    final _PartyDialogDensity base;
    if (minSide < 660 || height < 680 || width < 860) {
      base = tight;
    } else if (minSide < 820 || height < 820 || width < 1000) {
      base = compact;
    } else {
      base = comfortable;
    }

    // Scale single-line control height and text with viewport height.
    final h = height.clamp(560.0, 1040.0);
    final t = (h - 560) / (1040 - 560);
    final controlHeight =
        saleCompactFieldHeight + t * (saleFieldHeight - saleCompactFieldHeight);
    final fieldFontSize = 12.0 + t * 2.0;

    return base.copyWith(
      controlHeight: controlHeight,
      fieldFontSize: fieldFontSize,
    );
  }
}

class _PartyDialogDensityScope extends InheritedWidget {
  const _PartyDialogDensityScope({
    required this.density,
    required super.child,
  });

  final _PartyDialogDensity density;

  static _PartyDialogDensity of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_PartyDialogDensityScope>()
            ?.density ??
        _PartyDialogDensity.comfortable;
  }

  @override
  bool updateShouldNotify(_PartyDialogDensityScope oldWidget) {
    return density != oldWidget.density;
  }
}

/// Wider/taller than default ERP modals — party form has tabs and address blocks.
const _addPartyDialogWidth = 1280.0;
const _addPartyDialogMaxWidth = 1320.0;
const _addPartyDialogMaxHeightFactor = 0.93;

Future<AddPartyResult?> _showPartyDesktopDialog(
  BuildContext context, {
  required Widget child,
}) {
  return showFormDialog<AddPartyResult>(
    context: context,
    maxWidth: _addPartyDialogMaxWidth,
    maxHeightFactor: _addPartyDialogMaxHeightFactor,
    child: child,
  );
}

/// Shows the Add Party modal from sale forms and party pickers.
Future<AddPartyResult?> showAddPartyDialog(BuildContext context) {
  if (AppPlatform.current.isMobile) {
    return _showPartyFormMobileRoute(
      context,
      child: const AddPartyDialog(),
    );
  }
  return _showPartyDesktopDialog(
    context,
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
  return _showPartyDesktopDialog(
    context,
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
  return _showPartyDesktopDialog(
    context,
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

/// Entry point for adding a party — on mobile offers manual entry or contact import.
Future<AddPartyResult?> showAddPartyEntry(
  BuildContext context,
  WidgetRef ref,
) async {
  if (!AppPlatform.current.isMobile) {
    return showAddPartyDialog(context);
  }

  await showMobileAddOptionsSheet(
    context: context,
    title: 'Add Party',
    options: [
      MobileAddOption(
        label: 'Add manually',
        subtitle: 'Enter party details yourself',
        icon: Icons.person_add_outlined,
        onTap: () => showAddPartyDialog(context),
      ),
      MobileAddOption(
        label: 'Import from contacts',
        subtitle: 'Pick a contact from your phone',
        icon: Icons.contacts_outlined,
        iconColor: AppColors.primary,
        onTap: () => _openAddPartyFromContactImport(context, ref),
      ),
      MobileAddOption(
        label: 'Import multiple from contacts',
        subtitle: 'Create several parties at once',
        icon: Icons.contact_page_outlined,
        iconColor: AppColors.primary,
        onTap: () => openMobileBulkContactImport(context, ref),
      ),
    ],
  );
  return null;
}

Future<AddPartyResult?> _openAddPartyFromContactImport(
  BuildContext context,
  WidgetRef ref,
) async {
  final service = ref.read(deviceContactImportServiceProvider);
  if (!service.isSupported) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact import is only available on mobile devices.'),
        ),
      );
    }
    return showAddPartyDialog(context);
  }

  final permission = await service.requestAccess();
  if (!context.mounted) return null;

  switch (permission) {
    case DeviceContactPermissionResult.denied:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contacts permission denied. You can still add the party manually.',
          ),
        ),
      );
      return showAddPartyDialog(context);
    case DeviceContactPermissionResult.permanentlyDenied:
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Contacts permission required'),
          content: const Text(
            'Enable contacts access in system settings to import party details '
            'from your phone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                unawaited(openAppSettings());
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return showAddPartyDialog(context);
    case DeviceContactPermissionResult.unavailable:
      return showAddPartyDialog(context);
    case DeviceContactPermissionResult.granted:
      break;
  }

  final selected = await showDeviceContactPickerSheet(context);
  if (!context.mounted) return null;
  if (selected == null) return null;

  return _showPartyFormMobileRoute(
    context,
    child: AddPartyDialog(contactPrefill: selected.toPrefill()),
  );
}

class AddPartyDialog extends ConsumerStatefulWidget {
  const AddPartyDialog({
    this.partyToEdit,
    this.duplicateFrom,
    this.contactPrefill,
    super.key,
  });

  final PartyModel? partyToEdit;
  final PartyModel? duplicateFrom;
  final DeviceContactPrefill? contactPrefill;

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
  final _openingBalanceFocusNode = FocusNode();
  final _loyaltyPointsFocusNode = FocusNode();
  final _creditLimitFocusNode = FocusNode();
  final _additionalField1Controller = TextEditingController();
  final _additionalField2Controller = TextEditingController();
  final _additionalField3Controller = TextEditingController();
  final _additionalField4DatePickerKey =
      GlobalKey<SaleSingleDatePickerAnchorState>();
  final List<PartyAdditionalPhoneDetail> _additionalPhoneEntries = [];
  final List<String?> _additionalPhoneErrors = [];
  final _openingBalanceAsOfDatePickerKey =
      GlobalKey<SaleSingleDatePickerAnchorState>();

  DateTime _openingBalanceAsOfDate = DateTime.now();
  OpeningBalanceDirection _openingBalanceDirection =
      OpeningBalanceDirection.toReceive;
  bool _creditLimitEnabled = false;
  bool _useCustomCreditLimit = false;
  bool _additionalField1Enabled = false;
  bool _additionalField2Enabled = false;
  bool _additionalField3Enabled = false;
  bool _additionalField4Enabled = false;
  DateTime _additionalField4Date = DateTime.now();

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
  bool _allowPop = false;
  bool _isClosing = false;
  AddPartyResult? _initialPartySnapshot;
  String? _initialProfileImageUrl;
  String? _verifiedGstin;
  GstinVerificationResponse? _lastVerificationResponse;

  String get _closeFormTitle =>
      _isEditMode ? 'Close Edit Party' : 'Close Add Party';

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

    ClearZeroDecimalOnFocus.bind(
      controller: _openingBalanceController,
      focusNode: _openingBalanceFocusNode,
    );
    ClearZeroDecimalOnFocus.bind(
      controller: _loyaltyPointsOpeningBalanceController,
      focusNode: _loyaltyPointsFocusNode,
    );
    ClearZeroDecimalOnFocus.bind(
      controller: _creditLimitController,
      focusNode: _creditLimitFocusNode,
    );

    final prefill = widget.contactPrefill;
    if (prefill != null) {
      _applyContactPrefill(prefill);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _capturePartyFormSnapshot();
    });
  }

  void _capturePartyFormSnapshot() {
    _initialPartySnapshot = _buildResult();
    _initialProfileImageUrl = _profileImageUrl;
  }

  bool _hasUnsavedPartyChanges() {
    final initial = _initialPartySnapshot;
    if (initial == null) return false;
    if (!_partyResultsEqual(initial, _buildResult())) return true;
    if (_profileImageUrl != _initialProfileImageUrl) return true;
    final editor = _profileImageEditorKey.currentState;
    if (editor != null && editor.hasPendingUpload) return true;
    return false;
  }

  bool _partyResultsEqual(AddPartyResult a, AddPartyResult b) {
    bool sameDate(DateTime? x, DateTime? y) {
      if (x == null && y == null) return true;
      if (x == null || y == null) return false;
      return _dateOnly(x) == _dateOnly(y);
    }

    bool samePhoneDetails(
      List<PartyAdditionalPhoneDetail> left,
      List<PartyAdditionalPhoneDetail> right,
    ) {
      if (left.length != right.length) return false;
      for (var i = 0; i < left.length; i++) {
        if (left[i].phone != right[i].phone ||
            left[i].label != right[i].label) {
          return false;
        }
      }
      return true;
    }

    return a.partyName == b.partyName &&
        a.legalName == b.legalName &&
        a.alias == b.alias &&
        a.partyType == b.partyType &&
        a.gstin == b.gstin &&
        a.phone == b.phone &&
        a.gstType == b.gstType &&
        a.state == b.state &&
        a.email == b.email &&
        a.billingAddress == b.billingAddress &&
        a.shippingAddress == b.shippingAddress &&
        a.partyGroup == b.partyGroup &&
        a.areaCode == b.areaCode &&
        a.addressLine == b.addressLine &&
        a.city == b.city &&
        a.pincode == b.pincode &&
        a.country == b.country &&
        a.shippingAddressLine == b.shippingAddressLine &&
        a.shippingCity == b.shippingCity &&
        a.shippingPincode == b.shippingPincode &&
        a.shippingCountry == b.shippingCountry &&
        a.openingBalance == b.openingBalance &&
        sameDate(a.openingBalanceAsOfDate, b.openingBalanceAsOfDate) &&
        a.loyaltyPointsOpeningBalance == b.loyaltyPointsOpeningBalance &&
        sameDate(a.loyaltyPointsAsOfDate, b.loyaltyPointsAsOfDate) &&
        a.hasCustomCreditLimit == b.hasCustomCreditLimit &&
        a.creditLimit == b.creditLimit &&
        a.additionalField1Enabled == b.additionalField1Enabled &&
        a.additionalField1 == b.additionalField1 &&
        a.additionalField2Enabled == b.additionalField2Enabled &&
        a.additionalField2 == b.additionalField2 &&
        a.additionalField3Enabled == b.additionalField3Enabled &&
        a.additionalField3 == b.additionalField3 &&
        a.additionalField4Enabled == b.additionalField4Enabled &&
        a.additionalField4 == b.additionalField4 &&
        a.defaultPriceTier == b.defaultPriceTier &&
        _listEquals(a.additionalPhones, b.additionalPhones) &&
        samePhoneDetails(a.additionalPhoneDetails, b.additionalPhoneDetails);
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _requestClose() async {
    if (_isClosing || _allowPop || _isSaving) return;
    _isClosing = true;
    try {
      if (_hasUnsavedPartyChanges()) {
        final confirmed = await showCloseFormDialog(
          context,
          title: _closeFormTitle,
        );
        if (!confirmed || !mounted) return;
      }
      setState(() => _allowPop = true);
      Navigator.of(context).pop();
    } finally {
      _isClosing = false;
    }
  }

  void _popDialog([AddPartyResult? result]) {
    _allowPop = true;
    Navigator.of(context).pop(result);
  }

  Widget _wrapWithCloseGuard(Widget child) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _requestClose();
      },
      child: child,
    );
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

  void _applyContactPrefill(DeviceContactPrefill prefill) {
    if (prefill.displayName.trim().isNotEmpty) {
      _partyNameController.text = prefill.displayName.trim();
    }
    if (prefill.phones.isNotEmpty) {
      _phoneController.text = prefill.phones.first;
      if (prefill.phones.length > 1) {
        _setAdditionalPhoneEntries(
          prefill.phones
              .sublist(1)
              .map((phone) => PartyAdditionalPhoneDetail(phone: phone))
              .toList(),
        );
      }
    }
    final email = prefill.email?.trim();
    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
    }
    final address = prefill.address?.trim();
    if (address != null && address.isNotEmpty) {
      _billingAddressController.text = address;
    }
  }

  Future<void> _importContactIntoForm() async {
    final service = ref.read(deviceContactImportServiceProvider);
    if (!service.isSupported) return;

    final permission = await service.requestAccess();
    if (!mounted) return;

    switch (permission) {
      case DeviceContactPermissionResult.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Contacts permission denied. Enter details manually.',
            ),
          ),
        );
        return;
      case DeviceContactPermissionResult.permanentlyDenied:
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Contacts permission required'),
            content: const Text(
              'Enable contacts access in system settings to import details.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  unawaited(openAppSettings());
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      case DeviceContactPermissionResult.unavailable:
        return;
      case DeviceContactPermissionResult.granted:
        break;
    }

    final selected = await showDeviceContactPickerSheet(context);
    if (!mounted || selected == null) return;
    setState(() => _applyContactPrefill(selected.toPrefill()));
  }

  void _setAdditionalPhoneEntries(List<PartyAdditionalPhoneDetail> entries) {
    _additionalPhoneEntries
      ..clear()
      ..addAll(entries.take(kMaxPartyAdditionalPhones));
    _additionalPhoneErrors.clear();
  }

  Future<void> _promptAdditionalPhone({int? editIndex}) async {
    if (editIndex == null &&
        _additionalPhoneEntries.length >= kMaxPartyAdditionalPhones) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can add up to $kMaxPartyAdditionalPhones numbers'),
        ),
      );
      return;
    }

    final initial = editIndex != null
        ? _additionalPhoneEntries[editIndex]
        : null;
    final entry = await showAddPartyAdditionalPhoneDialog(
      context,
      initial: initial,
    );
    if (!mounted || entry == null) return;

    final normalized = PartyModel.normalizePhone(entry.phone);
    if (normalized.isEmpty) return;

    final primary = PartyModel.normalizePhone(_phoneController.text);
    if (normalized == primary && editIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This number matches the primary mobile')),
      );
      return;
    }

    for (var i = 0; i < _additionalPhoneEntries.length; i++) {
      if (editIndex != null && i == editIndex) continue;
      if (PartyModel.normalizePhone(_additionalPhoneEntries[i].phone) ==
          normalized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This number is already added')),
        );
        return;
      }
    }

    final duplicateError = _checkDuplicatePhoneNumber(normalized);
    if (duplicateError != null &&
        (editIndex == null ||
            PartyModel.normalizePhone(
                  _additionalPhoneEntries[editIndex].phone,
                ) !=
                normalized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(duplicateError)),
      );
      return;
    }

    setState(() {
      if (editIndex != null) {
        _additionalPhoneEntries[editIndex] = entry;
      } else {
        _additionalPhoneEntries.add(entry);
      }
    });
  }

  void _removeAdditionalPhoneEntry(int index) {
    setState(() {
      _additionalPhoneEntries.removeAt(index);
      if (index < _additionalPhoneErrors.length) {
        _additionalPhoneErrors.removeAt(index);
      }
    });
  }

  void _promoteAdditionalPhoneToPrimary(int index) {
    if (index < 0 || index >= _additionalPhoneEntries.length) return;
    setState(() {
      final selected = _additionalPhoneEntries[index];
      final formerPrimary = PartyModel.normalizePhone(_phoneController.text);
      _phoneController.text = PartyModel.normalizePhone(selected.phone);
      _additionalPhoneEntries[index] = PartyAdditionalPhoneDetail(
        phone: formerPrimary,
        label: selected.label,
      );
      if (index < _additionalPhoneErrors.length) {
        _additionalPhoneErrors[index] = null;
      }
      _phoneError = null;
    });
  }

  String _phoneWithRoleSuffix(String phone, {required bool isPrimary}) {
    final digits = phone.trim();
    if (digits.isEmpty) return '';
    return '$digits ${isPrimary ? 'P' : 'S'}';
  }

  void _populateFromParty(PartyModel party, {String? duplicateNameSuffix}) {
    _partyNameController.text = Validators.capitalizeFirstLetter(
      duplicateNameSuffix == null
          ? party.name
          : '${party.name}$duplicateNameSuffix',
    );
    _legalNameController.text = party.legalName.trim().isEmpty
        ? ''
        : Validators.capitalizeFirstLetter(party.legalName);
    _aliasController.text = party.alias;
    _areaCodeController.text = party.areaCode;
    _partyType = party.partyType;
    _gstinController.text = party.gstin.trim().isEmpty
        ? ''
        : GstinValidator.normalize(party.gstin);
    if (party.phone != '+91 00000 00000') {
      final normalizedPhone = PartyModel.normalizePhone(party.phone);
      if (normalizedPhone.isNotEmpty) {
        _phoneController.text = normalizedPhone;
      }
    }
    _setAdditionalPhoneEntries(party.additionalPhoneDetails);
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

    _openingBalanceDirection = PartyModel.openingBalanceDirection(
      party.openingBalance,
    );
    _openingBalanceController.text = PartyModel.formatDecimalInput(
      party.openingBalance,
    );
    _openingBalanceAsOfDate = party.openingBalanceAsOfDate ?? DateTime.now();

    _loyaltyPointsOpeningBalanceController.text =
        party.loyaltyPointsOpeningBalance.trim().isEmpty
        ? _defaultDecimal
        : party.loyaltyPointsOpeningBalance.trim();

    _creditLimitEnabled = party.hasCustomCreditLimit;
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
    _additionalField3Enabled = party.additionalField3.isNotEmpty;
    _additionalField3Controller.text = party.additionalField3;
    _additionalField4Enabled = party.additionalField4.isNotEmpty;
    final field4Parsed = DateTime.tryParse(party.additionalField4);
    _additionalField4Date = field4Parsed != null
        ? _dateOnly(field4Parsed)
        : _dateOnly(DateTime.now());
    _defaultPriceTier = party.defaultPriceTier;
  }

  List<String> _collectAdditionalPhones() {
    return _additionalPhoneEntries
        .map((entry) => entry.phone.trim())
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
    _openingBalanceFocusNode.dispose();
    _loyaltyPointsFocusNode.dispose();
    _creditLimitFocusNode.dispose();
    _additionalField1Controller.dispose();
    _additionalField2Controller.dispose();
    _additionalField3Controller.dispose();
    super.dispose();
  }

  AddPartyResult _buildResult() {
    return AddPartyResult(
      partyName: Validators.capitalizeFirstLetter(_partyNameController.text),
      legalName: _legalNameController.text.trim().isEmpty
          ? ''
          : Validators.capitalizeFirstLetter(_legalNameController.text),
      alias: _aliasController.text.trim(),
      partyType: _partyType,
      gstin: _gstinController.text.trim().isEmpty
          ? ''
          : GstinValidator.normalize(_gstinController.text),
      phone: _phoneController.text.trim(),
      additionalPhones: _collectAdditionalPhones(),
      additionalPhoneDetails: List<PartyAdditionalPhoneDetail>.from(
        _additionalPhoneEntries,
      ),
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
      openingBalance: PartyModel.signedOpeningBalanceString(
        magnitude: _normalizedDecimal(_openingBalanceController.text),
        direction: _openingBalanceDirection,
      ),
      openingBalanceAsOfDate: _openingBalanceAsOfDate,
      loyaltyPointsOpeningBalance: _normalizedDecimal(
        _loyaltyPointsOpeningBalanceController.text,
      ),
      loyaltyPointsAsOfDate: _openingBalanceAsOfDate,
      hasCustomCreditLimit: _creditLimitEnabled && _useCustomCreditLimit,
      creditLimit: _creditLimitEnabled && _useCustomCreditLimit
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
      additionalField3Enabled: _additionalField3Enabled,
      additionalField3: _additionalField3Enabled
          ? _additionalField3Controller.text.trim()
          : '',
      additionalField4Enabled: _additionalField4Enabled,
      additionalField4: _additionalField4Enabled
          ? _serializedAdditionalField4()
          : '',
      defaultPriceTier: _defaultPriceTier,
    );
  }

  String _serializedAdditionalField4() {
    final date = _dateOnly(_additionalField4Date);
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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
        onPressed: _isVerifyingGstin
            ? null
            : _showStoredGstinVerificationDetails,
        icon: const Icon(Icons.check_circle, size: 18, color: verifiedColor),
        color: verifiedColor,
        tooltip: 'View GST details',
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(
          width: _partyDensity().controlHeight - 8,
          height: _partyDensity().controlHeight - 2,
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
      constraints: BoxConstraints.tightFor(
        width: _partyDensity().controlHeight - 8,
        height: _partyDensity().controlHeight - 2,
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
    final partyGroupingEnabled = ref.read(partyGroupingEnabledProvider);
    final partyGroupError = partyGroupingEnabled
        ? Validators.requiredSelection(
            _partyGroup,
            fieldName: 'Party group',
          )
        : null;
    final openingBalanceError = Validators.nonNegativeDecimalAmount(
      _openingBalanceController.text,
    );
    final creditLimitError = _creditLimitEnabled && _useCustomCreditLimit
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

    for (final entry in _additionalPhoneEntries) {
      final value = entry.phone.trim();
      if (value.isEmpty) {
        errors.add('Enter a phone number or remove this entry');
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
      debugPrint(
        '[PartyUpdate] dialog save partyId=${party.id} '
        'name="${result.partyName}" phone="${result.phone}"',
      );
      // Finish any in-flight photo upload before PATCHing / closing the dialog.
      // Otherwise Update overwrites list/detail with a party that still has no
      // profile image, and a disposed editor never patches the final URL.
      final editor = _profileImageEditorKey.currentState;
      if (editor != null) {
        try {
          await editor.waitForIdle();
        } on Object catch (error, stackTrace) {
          debugPrint('[PartyUpdate] waitForIdle: $error\n$stackTrace');
        }
        if (!mounted) return;
        _profileImageUrl = editor.imageUrl ?? _profileImageUrl;
        _profileMediaAssetId = editor.mediaAssetId ?? _profileMediaAssetId;
      }

      if (!mounted) return;

      final updated = await ref
          .read(partyListProvider.notifier)
          .updateParty(
            party.id,
            result,
            isActive: party.isActive,
            seedParty: party,
          );

      if (!mounted) return;

      // If Update raced ahead of bind on the server, keep the uploaded image.
      final imageUrl = _profileImageUrl ?? updated.profileImageUrl;
      final mediaId = _profileMediaAssetId ?? updated.profileMediaAssetId;
      if (imageUrl != updated.profileImageUrl ||
          mediaId != updated.profileMediaAssetId) {
        try {
          await ref
              .read(partyListProvider.notifier)
              .patchProfileImage(
                party.id,
                profileImageUrl: imageUrl,
                profileMediaAssetId: mediaId,
                clear: imageUrl == null && mediaId == null,
              );
        } on Object {
          // Profile image is optional; do not fail the whole save.
        }
      }

      if (!mounted) return;

      _showSaveFeedback(
        message: 'Party "${result.partyName}" updated successfully',
        isError: false,
      );
      _popDialog(result);
    } on PartyOfflineException {
      if (!mounted) return;
      _showSaveFeedback(
        message: 'Update saved offline. It will sync when you are back online.',
        isError: false,
      );
      _popDialog(result);
      ref.invalidate(partyListProvider);
    } on ApiValidationException catch (e) {
      if (!mounted) return;
      _applyApiValidationErrors(e);
      _showSaveFeedback(message: e.message, isError: true);
    } on PartyException catch (e, stackTrace) {
      debugPrint('[PartyUpdate] PartyException: ${e.message}\n$stackTrace');
      if (!mounted) return;
      _showSaveFeedback(message: e.message, isError: true);
    } on PartyBusinessNotSelectedException {
      if (!mounted) return;
      _showSaveFeedback(
        message: 'Business not selected. Please select a business first.',
        isError: true,
      );
    } on Object catch (error, stackTrace) {
      debugPrint('[PartyUpdate] dialog catch: $error\n$stackTrace');
      if (!mounted) return;
      _showSaveFeedback(
        message: PartyErrorMapper.messageFor(error),
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
          await ref
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
        _popDialog(result);
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
        _popDialog(result);
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
    _additionalField3Controller.clear();
    _setAdditionalPhoneEntries(const []);
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
      _openingBalanceDirection = OpeningBalanceDirection.toReceive;
      _creditLimitEnabled = false;
      _useCustomCreditLimit = false;
      _additionalField1Enabled = false;
      _additionalField2Enabled = false;
      _additionalField3Enabled = false;
      _additionalField4Enabled = false;
      _additionalField4Date = _dateOnly(DateTime.now());
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _capturePartyFormSnapshot();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppPlatform.current.isMobile;
    final content = _buildDialogContent(
      showHeader: !isMobile,
      rounded: !isMobile,
    );

    if (isMobile) {
      final title = _isEditMode ? 'Edit Party' : 'Add Party';
      return _wrapWithCloseGuard(
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _isSaving ? null : _requestClose,
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
        ),
      );
    }

    final media = MediaQuery.sizeOf(context);
    final availableWidth = media.width - 48;
    final preferredWidth = availableWidth >= _addPartyDialogWidth
        ? _addPartyDialogWidth
        : availableWidth.clamp(0, _addPartyDialogMaxWidth);

    final fallbackHeight = media.height * _addPartyDialogMaxHeightFactor;

    return _wrapWithCloseGuard(
      LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : fallbackHeight;

          return SizedBox(
            width: preferredWidth.toDouble(),
            height: height,
            child: content,
          );
        },
      ),
    );
  }

  Widget _buildDialogContent({
    required bool showHeader,
    required bool rounded,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: rounded ? AppRadius.lgBorder : BorderRadius.zero,
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final density = _PartyDialogDensity.from(constraints);
          return _PartyDialogDensityScope(
            density: density,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showHeader) ...[
                      _buildHeader(),
                      const Divider(height: 1, color: _cardBorder),
                    ],
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          primary: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  density.pagePaddingH,
                                  density.pagePaddingTop,
                                  density.pagePaddingH,
                                  density.pagePaddingBottom,
                                ),
                                child: _buildTopFields(),
                              ),
                              SizedBox(height: density.sectionGap),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: density.pagePaddingH,
                                ),
                                child: _buildTabBar(),
                              ),
                              const Divider(height: 1, color: _cardBorder),
                              Padding(
                                padding: EdgeInsets.all(density.pagePaddingH),
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
        },
      ),
    );
  }

  _PartyDialogDensity _partyDensity() => _PartyDialogDensityScope.of(context);

  TextStyle _partyFieldTextStyle() =>
      saleFieldTextStyle.copyWith(fontSize: _partyDensity().fieldFontSize);

  SaleTextField _partySaleTextField({
    required TextEditingController controller,
    String? hint,
    bool hasError = false,
    bool enabled = true,
    bool autofocus = false,
    bool borderless = false,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    Widget? prefix,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final density = _partyDensity();
    return SaleTextField(
      controller: controller,
      hint: hint,
      hasError: hasError,
      enabled: enabled,
      borderless: borderless,
      compact: density.useCompactFields,
      controlHeight: density.controlHeight,
      style: _partyFieldTextStyle(),
      autofocus: autofocus,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      prefix: prefix,
      suffixIcon: suffixIcon,
      onChanged: onChanged,
      onTap: onTap,
      textCapitalization: textCapitalization,
    );
  }

  Widget _buildHeader() {
    final density = _partyDensity();
    final subtitle = _isEditMode
        ? 'Update contact, tax, and address details for this party.'
        : 'Enter party details to create a new party.';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        density.pagePaddingH,
        density.footerVerticalPadding + 4,
        density.pagePaddingH,
        density.footerVerticalPadding + 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Edit Party' : 'Add Party',
                  style: TextStyle(
                    fontSize: density.headerTitleSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (density.showHeaderSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: _isSaving
                ? null
                : () => unawaited(
                    showPartySettingsSidePanel(context: context),
                  ),
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Party settings',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: _isSaving ? null : () => unawaited(_requestClose()),
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildTopFields() {
    final density = _PartyDialogDensityScope.of(context);

    final partyNameField = _buildInlineTextField(
      controller: _partyNameController,
      hint: 'Party Name *',
      hasError: _partyNameError != null,
      errorText: _partyNameError,
      autofocus: !_isEditMode,
      maxLength: Validators.partyNameMaxLength,
      inputFormatters: [
        const CapitalizeFirstLetterFormatter(),
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
      inputFormatters: const [CapitalizeFirstLetterFormatter()],
    );

    final gstinField = _buildInlineTextField(
      controller: _gstinController,
      focusNode: _gstinFocusNode,
      hint: _requiresGstin ? 'GSTIN *' : 'GSTIN',
      hasError: _gstinError != null,
      errorText: _gstinError,
      maxLength: 15,
      inputFormatters: gstinInputFormatters,
      onChanged: _handleGstinChanged,
      suffixIcon: _buildGstinSuffixIcon(),
    );

    final phoneField = ValueListenableBuilder<TextEditingValue>(
      valueListenable: _phoneController,
      builder: (context, _, __) {
        return _buildInlineTextField(
          controller: _phoneController,
          hint: 'Mobile Number *',
          keyboardType: TextInputType.number,
          maxLength: 10,
          prefix: Icon(
            LucideIcons.phone,
            size: 18,
            color: AppColors.textSecondary.withValues(alpha: 0.55),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          hasError: _phoneError != null,
          errorText: _phoneError,
          suffixIcon: _buildMobileNumberSuffixActions(),
          onChanged: (_) {
            if (_phoneError != null) {
              setState(() => _phoneError = null);
            }
          },
        );
      },
    );

    const gridSpan = 4;
    final showGstinField = ref.watch(enableGstinOnPartyProvider);
    final partyGroupingEnabled = ref.watch(partyGroupingEnabledProvider);

    final primaryCells = <FormGridCell>[
      FormGridCell(span: gridSpan, child: partyNameField),
      if (showGstinField) FormGridCell(span: gridSpan, child: gstinField),
      FormGridCell(span: gridSpan, child: phoneField),
      if (partyGroupingEnabled)
        FormGridCell(span: gridSpan, child: _buildPartyGroupControls()),
      FormGridCell(span: gridSpan, child: legalNameField),
      FormGridCell(span: gridSpan, child: _buildDefaultPriceTierField()),
    ];

    final seed =
        widget.partyToEdit?.id ??
        widget.duplicateFrom?.id ??
        _partyNameController.text.trim();

    final basicDetailsBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PartyProfileImageEditor(
              key: _profileImageEditorKey,
              partyId: widget.partyToEdit?.id,
              partyName: _partyNameController.text,
              seed: seed.isEmpty ? 'party' : seed,
              size: density.profileImageSize,
              initialImageUrl: _profileImageUrl,
              initialMediaAssetId: _profileMediaAssetId,
              onChanged: ({required imageUrl, required mediaAssetId}) {
                _profileImageUrl = imageUrl;
                _profileMediaAssetId = mediaAssetId;
                final partyId = widget.partyToEdit?.id;
                if (partyId != null) {
                  unawaited(
                    ref
                        .read(partyListProvider.notifier)
                        .patchProfileImage(
                          partyId,
                          profileImageUrl: imageUrl,
                          profileMediaAssetId: mediaAssetId,
                          clear: imageUrl == null && mediaAssetId == null,
                        ),
                  );
                }
              },
            ),
            const SizedBox(width: FormSpacing.gutter),
            Expanded(
              child: FormGrid(
                rowGap: density.gridRowGap,
                cells: primaryCells,
              ),
            ),
          ],
        ),
        if (_additionalPhoneEntries.isNotEmpty) ...[
          SizedBox(height: density.sectionGap),
          _buildAdditionalPhoneEntriesList(),
        ],
        SizedBox(height: density.sectionGap),
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

    return _buildPartySectionPanel(
      title: 'Basic Details',
      titleIcon: LucideIcons.userPlus,
      titleIconColor: AppColors.primary,
      child: basicDetailsBody,
    );
  }

  Widget _buildAdditionalPhoneEntriesList() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(6),
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.phone,
                  size: 16,
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Additional Numbers',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          for (
            var index = 0;
            index < _additionalPhoneEntries.length;
            index++
          ) ...[
            _buildAdditionalPhoneEntryRow(index),
            if (index < _additionalPhoneEntries.length - 1)
              const Divider(height: 1, color: _cardBorder),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalPhoneEntryRow(int index) {
    final entry = _additionalPhoneEntries[index];
    final label = entry.label.trim();
    final error = index < _additionalPhoneErrors.length
        ? _additionalPhoneErrors[index]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: _partyAdditionalRowMinHeight,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.gripVertical,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  LucideIcons.phone,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.65),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _phoneWithRoleSuffix(entry.phone, isPrimary: false),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (label.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.md),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit number',
                  onPressed: () => _promptAdditionalPhone(editIndex: index),
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 17,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove number',
                  onPressed: () => _removeAdditionalPhoneEntry(index),
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 17,
                    color: AppColors.error.withValues(alpha: 0.9),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              error,
              style: const TextStyle(fontSize: 11, color: AppColors.error),
            ),
          ),
      ],
    );
  }

  bool get _primaryMobileComplete =>
      PartyModel.normalizePhone(_phoneController.text).length == 10;

  Widget? _buildMobileNumberSuffixActions() {
    if (!_primaryMobileComplete) {
      if (!AppPlatform.current.isMobile) {
        return null;
      }
      return IconButton(
        icon: const Icon(Icons.contacts_outlined, size: 19),
        tooltip: 'Import from contacts',
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: _importContactIntoForm,
      );
    }

    if (_additionalPhoneEntries.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: _buildPartyPhonesDropdownSuffix(),
      );
    }

    final addAnother = IconButton(
      icon: Icon(
        Icons.add_circle_outline,
        size: 20,
        color: AppColors.primary.withValues(alpha: 0.95),
      ),
      tooltip: 'Add another number',
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () => _promptAdditionalPhone(),
    );

    if (!AppPlatform.current.isMobile) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: addAnother,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.contacts_outlined, size: 19),
            tooltip: 'Import from contacts',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: _importContactIntoForm,
          ),
          addAnother,
        ],
      ),
    );
  }

  Widget _buildPartyPhonesDropdownSuffix() {
    final primary = PartyModel.normalizePhone(_phoneController.text);

    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
        elevation: const WidgetStatePropertyAll(6),
        shadowColor: const WidgetStatePropertyAll(Colors.black26),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 4),
        ),
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () {},
          child: _PartyPhoneMenuRow(
            phone: primary,
            role: 'P',
            isSelected: true,
          ),
        ),
        for (var i = 0; i < _additionalPhoneEntries.length; i++)
          MenuItemButton(
            onPressed: () => _promoteAdditionalPhoneToPrimary(i),
            child: _PartyPhoneMenuRow(
              phone: _additionalPhoneEntries[i].phone,
              role: 'S',
              label: _additionalPhoneEntries[i].label,
            ),
          ),
        if (_additionalPhoneEntries.length < kMaxPartyAdditionalPhones) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Divider(height: 1, color: _cardBorder),
          ),
          MenuItemButton(
            onPressed: () => unawaited(_promptAdditionalPhone()),
            child: const Row(
              children: [
                Icon(Icons.add, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Add another number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
      builder: (context, controller, child) {
        return IconButton(
          icon: Icon(
            Icons.arrow_drop_down_circle_outlined,
            size: 22,
            color: AppColors.primary.withValues(alpha: 0.95),
          ),
          tooltip: 'All numbers',
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }

  Widget _buildDefaultPriceTierField() {
    final tierLabels = ref.watch(pricingTierLabelsProvider);
    final density = _partyDensity();
    return SaleGenericSelectDropdown(
      value: PriceTier.labelFor(
        _defaultPriceTier,
        apiTierLabels: tierLabels,
      ),
      options: PriceTier.dropdownOptionsFor(apiTierLabels: tierLabels),
      hintText: 'Default Price Tier',
      compact: density.useCompactFields,
      triggerHeight: density.controlHeight,
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
    final density = _partyDensity();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SaleGenericSelectDropdown(
          value: _partyGroup,
          options: partyGroups,
          hintText: 'Party Group *',
          hasError: _partyGroupError != null,
          compact: density.useCompactFields,
          triggerHeight: density.controlHeight,
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
    Widget? prefix,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _partySaleTextField(
          controller: controller,
          hint: hint,
          hasError: hasError,
          autofocus: autofocus,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          prefix: prefix,
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
    final density = _PartyDialogDensityScope.of(context);
    final tabIconSize = density.tabIconSize;

    return TabBar(
      controller: _tabController,
      onTap: (_) => setState(() {}),
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      labelPadding: EdgeInsets.symmetric(
        horizontal: density.isTight ? 8 : 12,
      ),
      labelStyle: TextStyle(
        fontSize: density.isTight ? 12 : 13,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: density.isTight ? 12 : 13,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        Tab(
          height: density.isTight ? 32 : (density.useCompactFields ? 36 : 40),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.house,
                size: tabIconSize,
                color: _tabController.index == 0
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              const Text('GST & Address'),
            ],
          ),
        ),
        Tab(
          height: density.isTight ? 32 : (density.useCompactFields ? 36 : 40),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.creditCard,
                size: tabIconSize,
                color: _tabController.index == 1
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
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
        Tab(
          height: density.isTight ? 32 : (density.useCompactFields ? 36 : 40),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.settings,
                size: tabIconSize,
                color: _tabController.index == 2
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              const Text('Additional Fields'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartySectionPanel({
    required String title,
    required IconData titleIcon,
    required Color titleIconColor,
    required Widget child,
    Widget? titleTrailing,
  }) {
    final density = _partyDensity();
    final inset = density.isTight ? 10.0 : 14.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _partySectionPanelFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _partySectionPanelBorder),
      ),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(titleIcon, size: 18, color: titleIconColor),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: density.fieldFontSize + 1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (titleTrailing != null) ...[
                  const Spacer(),
                  titleTrailing,
                ],
              ],
            ),
            SizedBox(height: density.sectionGap + 2),
            child,
          ],
        ),
      ),
    );
  }

  Widget _partyFieldLeadingIcon(IconData icon) {
    return Icon(
      icon,
      size: 18,
      color: AppColors.textSecondary.withValues(alpha: 0.65),
    );
  }

  Widget _partyIconInputShell({
    required IconData icon,
    required Widget field,
    double? height,
  }) {
    final density = _partyDensity();
    final shellHeight = height ?? density.controlHeight;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: shellHeight,
          child: Row(
            children: [
              _partyFieldLeadingIcon(icon),
              const SizedBox(width: 10),
              Expanded(child: field),
            ],
          ),
        ),
      ),
    );
  }

  Widget _partyGstDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required ValueChanged<String> onSelected,
    String hintText = 'Select',
  }) {
    final density = _partyDensity();
    return _LabeledField(
      label: label,
      child: _partyIconInputShell(
        icon: icon,
        field: SaleGenericSelectDropdown(
          value: value,
          options: options,
          hintText: hintText,
          compact: density.useCompactFields,
          borderless: true,
          triggerHeight: density.controlHeight - 2,
          onSelected: onSelected,
        ),
      ),
    );
  }

  Widget _buildGstAddressTab() {
    final shippingAddressEnabled = ref.watch(
      partyShippingAddressEnabledProvider,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final density = _PartyDialogDensityScope.of(context);
        final gap = density.sectionGap;
        final columnGap = density.isTight ? 10.0 : FormSpacing.gutter;
        final isNarrow = constraints.maxWidth < 640;

        final gstDetailsPanel = _buildPartySectionPanel(
          title: 'GST Details',
          titleIcon: LucideIcons.fileText,
          titleIconColor: const Color(0xFF3B82F6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _partyGstDropdownField(
                label: 'Party Type',
                icon: LucideIcons.user,
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
              SizedBox(height: gap),
              _partyGstDropdownField(
                label: 'GST Type',
                icon: LucideIcons.fileText,
                value: _gstType,
                options: _gstTypes,
                onSelected: (value) => setState(() {
                  _gstType = value;
                  if (!_requiresGstin && _gstinError != null) {
                    _gstinError = null;
                  }
                }),
              ),
              SizedBox(height: gap),
              _partyGstDropdownField(
                label: 'State',
                icon: LucideIcons.mapPin,
                value: _state,
                options: SaleDropdownOptions.indianStates,
                onSelected: (value) => setState(() => _state = value),
              ),
              SizedBox(height: gap),
              _LabeledField(
                label: 'Email ID',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _partyIconInputShell(
                      icon: LucideIcons.mail,
                      field: _partySaleTextField(
                        controller: _emailController,
                        hint: 'Enter email ID (optional)',
                        borderless: true,
                        hasError: _emailError != null,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
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
          ),
        );

        final billingBody = _buildAddressSection(
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

        final shippingBody = shippingAddressEnabled && _showShippingAddress
            ? _buildAddressSection(
                isShipping: true,
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
            : null;

        final billingPanel = _buildPartySectionPanel(
          title: 'Billing Address',
          titleIcon: LucideIcons.mapPin,
          titleIconColor: AppColors.primary,
          titleTrailing: !shippingAddressEnabled || _showShippingAddress
              ? null
              : _buildEnableShippingAddressLink(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              billingBody,
              if (shippingBody != null) ...[
                SizedBox(height: gap + 4),
                Text(
                  'Shipping Address',
                  style: TextStyle(
                    fontSize: density.fieldFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: density.isTight ? 4 : FormSpacing.label),
                shippingBody,
              ],
            ],
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              gstDetailsPanel,
              SizedBox(height: columnGap),
              billingPanel,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: gstDetailsPanel),
            SizedBox(width: columnGap),
            Expanded(child: billingPanel),
          ],
        );
      },
    );
  }

  Widget _buildEnableShippingAddressLink() {
    return TextButton(
      onPressed: () => setState(() => _showShippingAddress = true),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        '+ Enable Shipping Address',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAddressSection({
    required TextEditingController addressController,
    required bool showDetailed,
    required VoidCallback onToggleDetailed,
    required Widget detailedFields,
    bool isShipping = false,
  }) {
    final density = _PartyDialogDensityScope.of(context);
    final addressLines = density.addressMinLines;
    const addressRadius = BorderRadius.vertical(top: Radius.circular(8));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: addressRadius,
            border: const Border(
              top: BorderSide(color: _cardBorder),
              left: BorderSide(color: _cardBorder),
              right: BorderSide(color: _cardBorder),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _partyFieldLeadingIcon(LucideIcons.house),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: addressController,
                    style: _partyFieldTextStyle(),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: buildSaleFieldDecoration(
                      fixedHeight: false,
                      compact: density.useCompactFields,
                      borderless: true,
                      hint: isShipping
                          ? 'Enter complete shipping address'
                          : 'Enter complete billing address',
                    ),
                    minLines: addressLines,
                    maxLines: addressLines,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildDetailedAddressToggleBar(
          showDetailed: showDetailed,
          onPressed: onToggleDetailed,
        ),
        if (showDetailed) ...[
          SizedBox(height: density.sectionGap),
          detailedFields,
        ],
      ],
    );
  }

  Widget _buildDetailedAddressToggleBar({
    required bool showDetailed,
    required VoidCallback onPressed,
  }) {
    final density = _partyDensity();
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: density.isTight ? 8 : 10,
            horizontal: 12,
          ),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: _cardBorder),
              right: BorderSide(color: _cardBorder),
              bottom: BorderSide(color: _cardBorder),
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                showDetailed
                    ? LucideIcons.eyeOff
                    : LucideIcons.eye,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                showDetailed
                    ? 'Hide detailed address'
                    : 'Show detailed address',
                style: TextStyle(
                  fontSize: density.fieldFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
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

        final density = _partyDensity();
        final detailGap = density.sectionGap;

        final addressLineField = _LabeledField(
          label: 'Address',
          child: _partySaleTextField(
            controller: addressLineController,
            hint: 'Street, building, area',
            textCapitalization: TextCapitalization.sentences,
          ),
        );

        final cityField = _LabeledField(
          label: 'City',
          child: _partySaleTextField(
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
            compact: density.useCompactFields,
            triggerHeight: density.controlHeight,
            onSelected: onStateChanged,
          ),
        );

        final pincodeField = _LabeledField(
          label: 'Pincode',
          child: _partySaleTextField(
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
            compact: density.useCompactFields,
            triggerHeight: density.controlHeight,
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
    final gap = _PartyDialogDensityScope.of(context).sectionGap;
    final loyaltyEnabled = ref.watch(partyLoyaltyPointsEnabledProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVyaparOpeningBalanceDateRow(),
        SizedBox(height: gap),
        _buildVyaparOpeningBalanceTypeRadios(),
        SizedBox(height: gap),
        _buildVyaparCreditLimitSection(),
        if (loyaltyEnabled) ...[
          SizedBox(height: gap),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _creditBalanceFieldMaxWidth,
            ),
            child: _buildVyaparLoyaltyPointsField(),
          ),
        ],
      ],
    );
  }

  Widget _buildVyaparOpeningBalanceDateRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final openingBalance = ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _creditBalanceFieldMaxWidth,
          ),
          child: _buildVyaparOutlinedAmountField(
            label: 'Opening Balance',
            controller: _openingBalanceController,
            focusNode: _openingBalanceFocusNode,
            errorText: _openingBalanceError,
            onChanged: () {
              if (_openingBalanceError != null) {
                setState(() => _openingBalanceError = null);
              }
            },
          ),
        );
        final asOfDate = ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _creditBalanceFieldMaxWidth,
          ),
          child: _buildVyaparOutlinedDateField(
            label: 'As Of Date',
            selectedDate: _openingBalanceAsOfDate,
            datePickerKey: _openingBalanceAsOfDatePickerKey,
            onDateSelected: (date) =>
                setState(() => _openingBalanceAsOfDate = _dateOnly(date)),
          ),
        );

        final gap = _partyDensity().sectionGap;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              openingBalance,
              SizedBox(height: gap),
              asOfDate,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            openingBalance,
            SizedBox(width: gap + 4),
            asOfDate,
          ],
        );
      },
    );
  }

  Widget _buildVyaparOutlinedAmountField({
    required String label,
    required TextEditingController controller,
    FocusNode? focusNode,
    String? errorText,
    Widget? prefix,
    VoidCallback? onChanged,
  }) {
    final density = _partyDensity();
    final verticalPad = density.isTight
        ? 8.0
        : (density.useCompactFields ? 10.0 : 12.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          style: _partyFieldTextStyle(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [nonNegativeDecimalInputFormatter],
          onChanged: (_) => onChanged?.call(),
          decoration:
              buildFormControlDecoration(
                labelText: label,
                hasError: errorText != null,
                fixedHeight: false,
              ).copyWith(
                prefix: prefix,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: verticalPad,
                ),
              ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              errorText,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildVyaparOutlinedDateField({
    required String label,
    required DateTime selectedDate,
    required GlobalKey<SaleSingleDatePickerAnchorState> datePickerKey,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    final density = _partyDensity();
    final innerHeight = math.max(20.0, density.controlHeight - 10);

    return SaleSingleDatePickerAnchor(
      key: datePickerKey,
      selectedDate: selectedDate,
      onDateSelected: onDateSelected,
      child: InputDecorator(
        decoration: buildFormControlDecoration(
          labelText: label,
          fixedHeight: false,
        ),
        child: InkWell(
          onTap: () => datePickerKey.currentState?.toggle(),
          child: SizedBox(
            height: innerHeight,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    formatSaleSingleDate(selectedDate),
                    style: _partyFieldTextStyle(),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: density.isTight ? 14 : 16,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVyaparOpeningBalanceTypeRadios() {
    final gap = _partyDensity().sectionGap + 4;
    return Row(
      children: [
        _buildVyaparBalanceDirectionRadio(OpeningBalanceDirection.toPay),
        SizedBox(width: gap),
        _buildVyaparBalanceDirectionRadio(OpeningBalanceDirection.toReceive),
      ],
    );
  }

  Widget _buildVyaparBalanceDirectionRadio(OpeningBalanceDirection direction) {
    final density = _partyDensity();
    final selected = _openingBalanceDirection == direction;
    final selectedColor = direction == OpeningBalanceDirection.toReceive
        ? _vyaparReceiveRadioColor
        : AppColors.primary;

    return InkWell(
      onTap: () => setState(() => _openingBalanceDirection = direction),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<OpeningBalanceDirection>(
              value: direction,
              groupValue: _openingBalanceDirection,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return selectedColor;
                }
                return AppColors.primary;
              }),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _openingBalanceDirection = value);
              },
            ),
            Text(
              direction.label,
              style: TextStyle(
                fontSize: density.fieldFontSize,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVyaparLoyaltyPointsField() {
    return _buildVyaparOutlinedAmountField(
      label: 'Loyalty Points Opening Balance',
      controller: _loyaltyPointsOpeningBalanceController,
      focusNode: _loyaltyPointsFocusNode,
      errorText: _loyaltyBalanceError,
      onChanged: () {
        if (_loyaltyBalanceError != null) {
          setState(() => _loyaltyBalanceError = null);
        }
      },
    );
  }

  Widget _buildVyaparCreditLimitSection() {
    final noLimitActive = !_useCustomCreditLimit;
    final density = _partyDensity();
    final gap = density.sectionGap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Credit Limit',
              style: TextStyle(
                fontSize: density.fieldFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message:
                  'Turn on to cap outstanding balance for this party. '
                  'Choose No Limit or enter a custom amount.',
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Switch(
              value: _creditLimitEnabled,
              activeColor: AppColors.primary,
              trackOutlineColor: WidgetStateProperty.all(
                AppColors.primary.withValues(alpha: 0.35),
              ),
              onChanged: (enabled) {
                setState(() {
                  _creditLimitEnabled = enabled;
                  if (!enabled) {
                    _useCustomCreditLimit = false;
                    _creditLimitError = null;
                  }
                });
              },
            ),
          ],
        ),
        if (_creditLimitEnabled) ...[
          SizedBox(height: gap),
          Row(
            children: [
              Text(
                'No Limit',
                style: TextStyle(
                  fontSize: density.fieldFontSize,
                  fontWeight: noLimitActive ? FontWeight.w700 : FontWeight.w500,
                  color: noLimitActive
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              Switch(
                value: _useCustomCreditLimit,
                activeColor: AppColors.primary,
                trackOutlineColor: WidgetStateProperty.all(
                  AppColors.primary.withValues(alpha: 0.35),
                ),
                onChanged: (useCustom) {
                  setState(() {
                    _useCustomCreditLimit = useCustom;
                    if (useCustom &&
                        _creditLimitController.text.trim().isEmpty) {
                      _creditLimitController.text = _defaultDecimal;
                    }
                    if (!useCustom) {
                      _creditLimitError = null;
                    }
                  });
                },
              ),
              Text(
                'Custom Limit',
                style: TextStyle(
                  fontSize: density.fieldFontSize,
                  fontWeight:
                      !noLimitActive ? FontWeight.w700 : FontWeight.w500,
                  color: !noLimitActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (_useCustomCreditLimit) ...[
            SizedBox(height: gap),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _creditBalanceFieldMaxWidth,
              ),
              child: _buildVyaparOutlinedAmountField(
                label: 'Credit Limit Amount',
                controller: _creditLimitController,
                focusNode: _creditLimitFocusNode,
                errorText: _creditLimitError,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('₹', style: saleFieldTextStyle),
                ),
                onChanged: () {
                  if (_creditLimitError != null) {
                    setState(() => _creditLimitError = null);
                  }
                },
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildAdditionalFieldsTab() {
    final partySettings = ref.watch(partySettingsProvider).value;
    final configs =
        partySettings?.additionalFields ??
        PartyAdditionalFieldCatalog.defaultFields();

    final rows = <Widget>[];
    for (
      var i = 0;
      i < configs.length && i < PartyAdditionalFieldCatalog.fieldCount;
      i++
    ) {
      final config = configs[i];
      if (!config.enabled) continue;
      final label = config.label.trim().isEmpty
          ? PartyAdditionalFieldCatalog.defaultLabelForIndex(i)
          : config.label.trim();
      if (i == 3 &&
          config.valueKind == PartyAdditionalFieldValueKind.date) {
        rows.add(
          _buildAdditionalDateFieldRow(
            label: label,
            enabled: _additionalField4Enabled,
            selectedDate: _additionalField4Date,
            onEnabledChanged: (value) =>
                setState(() => _additionalField4Enabled = value),
            onDateSelected: (date) =>
                setState(() => _additionalField4Date = _dateOnly(date)),
          ),
        );
      } else {
        final controller = switch (i) {
          0 => _additionalField1Controller,
          1 => _additionalField2Controller,
          2 => _additionalField3Controller,
          _ => _additionalField3Controller,
        };
        final enabled = switch (i) {
          0 => _additionalField1Enabled,
          1 => _additionalField2Enabled,
          2 => _additionalField3Enabled,
          _ => false,
        };
        rows.add(
          _buildAdditionalFieldRow(
            label: label,
            enabled: enabled,
            controller: controller,
            onEnabledChanged: (value) => setState(() {
              switch (i) {
                case 0:
                  _additionalField1Enabled = value;
                case 1:
                  _additionalField2Enabled = value;
                case 2:
                  _additionalField3Enabled = value;
              }
            }),
          ),
        );
      }
      rows.add(const SizedBox(height: AppSpacing.md));
    }
    if (rows.isNotEmpty) rows.removeLast();

    if (rows.isEmpty) {
      return Text(
        'Enable additional fields in Settings → Party.',
        style: AppTypography.inter(
          fontSize: AppTypography.bodyMediumSize,
          color: AppColors.textSecondary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
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
          child: _partySaleTextField(
            controller: controller,
            hint: label,
            enabled: enabled,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDateFieldRow({
    required String label,
    required bool enabled,
    required DateTime selectedDate,
    required ValueChanged<bool> onEnabledChanged,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          child: Opacity(
            opacity: enabled ? 1 : 0.45,
            child: IgnorePointer(
              ignoring: !enabled,
              child: _buildVyaparOutlinedDateField(
                label: label,
                selectedDate: selectedDate,
                datePickerKey: _additionalField4DatePickerKey,
                onDateSelected: onDateSelected,
              ),
            ),
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

    final density = _PartyDialogDensityScope.of(context);
    final compactFooter = density.useCompactFields;
    final buttonHeight = density.controlHeight;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          density.pagePaddingH,
          density.footerVerticalPadding,
          density.pagePaddingH,
          density.footerVerticalPadding,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 480;

            final saveButton = FilledButton(
              onPressed: _isSaving ? null : () => _save(saveAndNew: false),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: compactFooter ? 18 : 24,
                  vertical: compactFooter ? 8 : 10,
                ),
                minimumSize: Size(0, buttonHeight),
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
                padding: EdgeInsets.symmetric(
                  horizontal: compactFooter ? 16 : 20,
                  vertical: compactFooter ? 8 : 10,
                ),
                minimumSize: Size(0, buttonHeight),
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
                padding: EdgeInsets.symmetric(
                  horizontal: compactFooter ? 16 : 20,
                  vertical: compactFooter ? 8 : 10,
                ),
                minimumSize: Size(0, buttonHeight),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                  ),
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
          _popDialog();
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
    final density = _PartyDialogDensityScope.of(context);
    final labelGap = density.isTight
        ? 3.0
        : (density.useCompactFields ? 4.0 : FormSpacing.label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: saleFieldLabelStyle.copyWith(
            fontSize: density.fieldFontSize,
          ),
        ),
        SizedBox(height: labelGap),
        child,
      ],
    );
  }
}

class _PartyPhoneMenuRow extends StatelessWidget {
  const _PartyPhoneMenuRow({
    required this.phone,
    required this.role,
    this.label = '',
    this.isSelected = false,
  });

  final String phone;
  final String role;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final tag = label.trim();
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  phone.trim(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                role,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              if (tag.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isSelected)
          const Icon(
            Icons.check,
            size: 18,
            color: AppColors.primary,
          ),
      ],
    );
  }
}
