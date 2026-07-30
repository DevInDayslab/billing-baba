enum PrinterType { regular, thermal }

enum ThermalPageSize {
  twoInch, // 58mm
  threeInch, // 68mm (default)
  fourInch, // 88mm
}

enum RegularOrientation { portrait, landscape }

enum PrintTextSize { small, medium, large }

extension PrinterTypeX on PrinterType {
  String get storageKey => switch (this) {
    PrinterType.regular => 'regular',
    PrinterType.thermal => 'thermal',
  };

  static PrinterType fromStorageKey(String? key) =>
      PrinterType.values.firstWhere(
        (e) => e.storageKey == key,
        orElse: () => PrinterType.thermal,
      );
}

extension ThermalPageSizeX on ThermalPageSize {
  String get storageKey => switch (this) {
    ThermalPageSize.twoInch => 'two_inch',
    ThermalPageSize.threeInch => 'three_inch',
    ThermalPageSize.fourInch => 'four_inch',
  };

  static ThermalPageSize fromStorageKey(String? key) =>
      ThermalPageSize.values.firstWhere(
        (e) => e.storageKey == key,
        orElse: () => ThermalPageSize.threeInch,
      );
}

extension RegularOrientationX on RegularOrientation {
  String get storageKey => switch (this) {
    RegularOrientation.portrait => 'portrait',
    RegularOrientation.landscape => 'landscape',
  };

  static RegularOrientation fromStorageKey(String? key) =>
      RegularOrientation.values.firstWhere(
        (e) => e.storageKey == key,
        orElse: () => RegularOrientation.portrait,
      );
}

extension PrintTextSizeX on PrintTextSize {
  String get storageKey => switch (this) {
    PrintTextSize.small => 'small',
    PrintTextSize.medium => 'medium',
    PrintTextSize.large => 'large',
  };

  static PrintTextSize fromStorageKey(String? key) =>
      PrintTextSize.values.firstWhere(
        (e) => e.storageKey == key,
        orElse: () => PrintTextSize.medium,
      );
}

/// Device-local print preferences (not synced to cloud).
class PrintSettings {
  const PrintSettings({
    required this.printerType,
    required this.thermalPageSize,
    required this.useTextStylingBold,
    required this.autoCutPaperAfterPrinting,
    required this.extraLinesAtEnd,
    required this.numberOfCopies,
    required this.orientation,
    required this.invoiceTextSize,
    required this.companyTextSize,
    required this.printCompanyName,
    required this.printCompanyLogo,
    required this.printAddress,
    required this.printPhone,
    required this.printGstin,
    required this.printBankDetails,
    required this.printTermsAndConditions,
    required this.termsAndConditions,
  });

  const PrintSettings.defaults()
    : printerType = PrinterType.thermal,
      thermalPageSize = ThermalPageSize.threeInch,
      useTextStylingBold = true,
      autoCutPaperAfterPrinting = false,
      extraLinesAtEnd = 0,
      numberOfCopies = 1,
      orientation = RegularOrientation.portrait,
      invoiceTextSize = PrintTextSize.medium,
      companyTextSize = PrintTextSize.large,
      printCompanyName = true,
      printCompanyLogo = true,
      printAddress = true,
      printPhone = true,
      printGstin = true,
      printBankDetails = true,
      printTermsAndConditions = true,
      termsAndConditions = 'Thanks for doing business with us!';

  final PrinterType printerType;
  final ThermalPageSize thermalPageSize;
  final bool useTextStylingBold;
  final bool autoCutPaperAfterPrinting;
  final int extraLinesAtEnd;
  final int numberOfCopies;
  final RegularOrientation orientation;
  final PrintTextSize invoiceTextSize;
  final PrintTextSize companyTextSize;
  final bool printCompanyName;
  final bool printCompanyLogo;
  final bool printAddress;
  final bool printPhone;
  final bool printGstin;
  final bool printBankDetails;
  final bool printTermsAndConditions;
  final String termsAndConditions;

  PrintSettings copyWith({
    PrinterType? printerType,
    ThermalPageSize? thermalPageSize,
    bool? useTextStylingBold,
    bool? autoCutPaperAfterPrinting,
    int? extraLinesAtEnd,
    int? numberOfCopies,
    RegularOrientation? orientation,
    PrintTextSize? invoiceTextSize,
    PrintTextSize? companyTextSize,
    bool? printCompanyName,
    bool? printCompanyLogo,
    bool? printAddress,
    bool? printPhone,
    bool? printGstin,
    bool? printBankDetails,
    bool? printTermsAndConditions,
    String? termsAndConditions,
  }) {
    return PrintSettings(
      printerType: printerType ?? this.printerType,
      thermalPageSize: thermalPageSize ?? this.thermalPageSize,
      useTextStylingBold: useTextStylingBold ?? this.useTextStylingBold,
      autoCutPaperAfterPrinting:
          autoCutPaperAfterPrinting ?? this.autoCutPaperAfterPrinting,
      extraLinesAtEnd: extraLinesAtEnd ?? this.extraLinesAtEnd,
      numberOfCopies: numberOfCopies ?? this.numberOfCopies,
      orientation: orientation ?? this.orientation,
      invoiceTextSize: invoiceTextSize ?? this.invoiceTextSize,
      companyTextSize: companyTextSize ?? this.companyTextSize,
      printCompanyName: printCompanyName ?? this.printCompanyName,
      printCompanyLogo: printCompanyLogo ?? this.printCompanyLogo,
      printAddress: printAddress ?? this.printAddress,
      printPhone: printPhone ?? this.printPhone,
      printGstin: printGstin ?? this.printGstin,
      printBankDetails: printBankDetails ?? this.printBankDetails,
      printTermsAndConditions:
          printTermsAndConditions ?? this.printTermsAndConditions,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
    );
  }
}
