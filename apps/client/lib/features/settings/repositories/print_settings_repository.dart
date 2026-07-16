import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';

class PrintSettingsRepository {
  PrintSettingsRepository(this._storageService);

  final StorageService _storageService;

  static const _kPrinterType = 'print_settings.printer_type';
  static const _kThermalPageSize = 'print_settings.thermal_page_size';
  static const _kBold = 'print_settings.bold';
  static const _kAutoCut = 'print_settings.auto_cut';
  static const _kExtraLines = 'print_settings.extra_lines';
  static const _kCopies = 'print_settings.copies';
  static const _kOrientation = 'print_settings.orientation';
  static const _kInvoiceTextSize = 'print_settings.invoice_text_size';
  static const _kCompanyTextSize = 'print_settings.company_text_size';
  static const _kCompanyName = 'print_settings.company_name';
  static const _kCompanyLogo = 'print_settings.company_logo';
  static const _kAddress = 'print_settings.address';
  static const _kPhone = 'print_settings.phone';
  static const _kGstin = 'print_settings.gstin';
  static const _kBankDetails = 'print_settings.bank_details';
  static const _kTermsToggle = 'print_settings.terms_toggle';
  static const _kTermsText = 'print_settings.terms_text';

  Future<PrintSettings> load() async {
    const defaults = PrintSettings.defaults();

    return PrintSettings(
      printerType: PrinterTypeX.fromStorageKey(
        _storageService.read(_kPrinterType),
      ),
      thermalPageSize: ThermalPageSizeX.fromStorageKey(
        _storageService.read(_kThermalPageSize),
      ),
      useTextStylingBold: _readBool(_kBold, defaults.useTextStylingBold),
      autoCutPaperAfterPrinting:
          _readBool(_kAutoCut, defaults.autoCutPaperAfterPrinting),
      extraLinesAtEnd: _readInt(_kExtraLines, defaults.extraLinesAtEnd),
      numberOfCopies: _readInt(_kCopies, defaults.numberOfCopies),
      orientation: RegularOrientationX.fromStorageKey(
        _storageService.read(_kOrientation),
      ),
      invoiceTextSize: PrintTextSizeX.fromStorageKey(
        _storageService.read(_kInvoiceTextSize),
      ),
      companyTextSize: PrintTextSizeX.fromStorageKey(
        _storageService.read(_kCompanyTextSize),
      ),
      printCompanyName: _readBool(_kCompanyName, defaults.printCompanyName),
      printCompanyLogo: _readBool(_kCompanyLogo, defaults.printCompanyLogo),
      printAddress: _readBool(_kAddress, defaults.printAddress),
      printPhone: _readBool(_kPhone, defaults.printPhone),
      printGstin: _readBool(_kGstin, defaults.printGstin),
      printBankDetails: _readBool(_kBankDetails, defaults.printBankDetails),
      printTermsAndConditions:
          _readBool(_kTermsToggle, defaults.printTermsAndConditions),
      termsAndConditions:
          _storageService.read(_kTermsText) ?? defaults.termsAndConditions,
    );
  }

  Future<void> save(PrintSettings settings) async {
    await Future.wait([
      _storageService.write(_kPrinterType, settings.printerType.storageKey),
      _storageService.write(
        _kThermalPageSize,
        settings.thermalPageSize.storageKey,
      ),
      _storageService.write(
        _kBold,
        _writeBool(settings.useTextStylingBold),
      ),
      _storageService.write(
        _kAutoCut,
        _writeBool(settings.autoCutPaperAfterPrinting),
      ),
      _storageService.write(
        _kExtraLines,
        settings.extraLinesAtEnd.toString(),
      ),
      _storageService.write(
        _kCopies,
        settings.numberOfCopies.toString(),
      ),
      _storageService.write(_kOrientation, settings.orientation.storageKey),
      _storageService.write(
        _kInvoiceTextSize,
        settings.invoiceTextSize.storageKey,
      ),
      _storageService.write(
        _kCompanyTextSize,
        settings.companyTextSize.storageKey,
      ),
      _storageService.write(
        _kCompanyName,
        _writeBool(settings.printCompanyName),
      ),
      _storageService.write(
        _kCompanyLogo,
        _writeBool(settings.printCompanyLogo),
      ),
      _storageService.write(_kAddress, _writeBool(settings.printAddress)),
      _storageService.write(_kPhone, _writeBool(settings.printPhone)),
      _storageService.write(_kGstin, _writeBool(settings.printGstin)),
      _storageService.write(
        _kBankDetails,
        _writeBool(settings.printBankDetails),
      ),
      _storageService.write(
        _kTermsToggle,
        _writeBool(settings.printTermsAndConditions),
      ),
      _storageService.write(_kTermsText, settings.termsAndConditions),
    ]);
  }

  bool _readBool(String key, bool defaultValue) {
    final raw = _storageService.read(key);
    if (raw == null) return defaultValue;
    return raw == '1';
  }

  int _readInt(String key, int defaultValue) {
    final raw = _storageService.read(key);
    if (raw == null) return defaultValue;
    return int.tryParse(raw) ?? defaultValue;
  }

  String _writeBool(bool value) => value ? '1' : '0';
}
