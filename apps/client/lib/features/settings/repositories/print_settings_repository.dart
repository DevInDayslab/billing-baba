import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';

class PrintSettingsRepository {
  PrintSettingsRepository(this._storageService, this._businessId);

  final StorageService _storageService;
  final String _businessId;

  String _scopedKey(String suffix) =>
      '${StorageKeys.printSettings}_$_businessId.$suffix';

  static const _kPrinterType = 'printer_type';
  static const _kThermalPageSize = 'thermal_page_size';
  static const _kBold = 'bold';
  static const _kAutoCut = 'auto_cut';
  static const _kExtraLines = 'extra_lines';
  static const _kCopies = 'copies';
  static const _kOrientation = 'orientation';
  static const _kInvoiceTextSize = 'invoice_text_size';
  static const _kCompanyTextSize = 'company_text_size';
  static const _kCompanyName = 'company_name';
  static const _kCompanyLogo = 'company_logo';
  static const _kAddress = 'address';
  static const _kPhone = 'phone';
  static const _kGstin = 'gstin';
  static const _kBankDetails = 'bank_details';
  static const _kTermsToggle = 'terms_toggle';
  static const _kTermsText = 'terms_text';

  Future<PrintSettings> load() async {
    const defaults = PrintSettings.defaults();

    return PrintSettings(
      printerType: PrinterTypeX.fromStorageKey(
        _storageService.read(_scopedKey(_kPrinterType)),
      ),
      thermalPageSize: ThermalPageSizeX.fromStorageKey(
        _storageService.read(_scopedKey(_kThermalPageSize)),
      ),
      useTextStylingBold: _readBool(_kBold, defaults.useTextStylingBold),
      autoCutPaperAfterPrinting: _readBool(
        _kAutoCut,
        defaults.autoCutPaperAfterPrinting,
      ),
      extraLinesAtEnd: _readInt(_kExtraLines, defaults.extraLinesAtEnd),
      numberOfCopies: _readInt(_kCopies, defaults.numberOfCopies),
      orientation: RegularOrientationX.fromStorageKey(
        _storageService.read(_scopedKey(_kOrientation)),
      ),
      invoiceTextSize: PrintTextSizeX.fromStorageKey(
        _storageService.read(_scopedKey(_kInvoiceTextSize)),
      ),
      companyTextSize: PrintTextSizeX.fromStorageKey(
        _storageService.read(_scopedKey(_kCompanyTextSize)),
      ),
      printCompanyName: _readBool(_kCompanyName, defaults.printCompanyName),
      printCompanyLogo: _readBool(_kCompanyLogo, defaults.printCompanyLogo),
      printAddress: _readBool(_kAddress, defaults.printAddress),
      printPhone: _readBool(_kPhone, defaults.printPhone),
      printGstin: _readBool(_kGstin, defaults.printGstin),
      printBankDetails: _readBool(_kBankDetails, defaults.printBankDetails),
      printTermsAndConditions: _readBool(
        _kTermsToggle,
        defaults.printTermsAndConditions,
      ),
      termsAndConditions:
          _storageService.read(_scopedKey(_kTermsText)) ??
          defaults.termsAndConditions,
    );
  }

  Future<void> save(PrintSettings settings) async {
    await Future.wait([
      _storageService.write(
        _scopedKey(_kPrinterType),
        settings.printerType.storageKey,
      ),
      _storageService.write(
        _scopedKey(_kThermalPageSize),
        settings.thermalPageSize.storageKey,
      ),
      _storageService.write(
        _scopedKey(_kBold),
        _writeBool(settings.useTextStylingBold),
      ),
      _storageService.write(
        _scopedKey(_kAutoCut),
        _writeBool(settings.autoCutPaperAfterPrinting),
      ),
      _storageService.write(
        _scopedKey(_kExtraLines),
        settings.extraLinesAtEnd.toString(),
      ),
      _storageService.write(
        _scopedKey(_kCopies),
        settings.numberOfCopies.toString(),
      ),
      _storageService.write(
        _scopedKey(_kOrientation),
        settings.orientation.storageKey,
      ),
      _storageService.write(
        _scopedKey(_kInvoiceTextSize),
        settings.invoiceTextSize.storageKey,
      ),
      _storageService.write(
        _scopedKey(_kCompanyTextSize),
        settings.companyTextSize.storageKey,
      ),
      _storageService.write(
        _scopedKey(_kCompanyName),
        _writeBool(settings.printCompanyName),
      ),
      _storageService.write(
        _scopedKey(_kCompanyLogo),
        _writeBool(settings.printCompanyLogo),
      ),
      _storageService.write(
        _scopedKey(_kAddress),
        _writeBool(settings.printAddress),
      ),
      _storageService.write(
        _scopedKey(_kPhone),
        _writeBool(settings.printPhone),
      ),
      _storageService.write(
        _scopedKey(_kGstin),
        _writeBool(settings.printGstin),
      ),
      _storageService.write(
        _scopedKey(_kBankDetails),
        _writeBool(settings.printBankDetails),
      ),
      _storageService.write(
        _scopedKey(_kTermsToggle),
        _writeBool(settings.printTermsAndConditions),
      ),
      _storageService.write(
        _scopedKey(_kTermsText),
        settings.termsAndConditions,
      ),
    ]);
  }

  bool _readBool(String key, bool defaultValue) {
    final raw = _storageService.read(_scopedKey(key));
    if (raw == null) return defaultValue;
    return raw == '1';
  }

  int _readInt(String key, int defaultValue) {
    final raw = _storageService.read(_scopedKey(key));
    if (raw == null) return defaultValue;
    return int.tryParse(raw) ?? defaultValue;
  }

  String _writeBool(bool value) => value ? '1' : '0';
}
