/// Offline payment bank details shown on the license info screen.
abstract final class PlansPricingLicenseConstants {
  static const offlinePaymentDetails = <String, String>{
    'Account Name': 'Simply Vyapar Apps Private Limited',
    'Account No': '50200030169402',
    'Account Type': 'Current',
    'IFSC Code': 'HDFC0003782',
    'Branch Name': 'HDFC Bank Limited, Kasavanahalli, Bangalore',
    'Swift Code': 'HDFCINBB',
  };

  static const fallbackDeviceId = '5c27d7034dde5725';
  static const fallbackSyncCompanyId = 'DDSTOCK_t_2023_12_06_17_51_19_9wm';
}

/// Which accordion section should open first on the license info page.
enum MobileLicenseInfoSection {
  none,
  attachLicense,
  offlinePayment,
}
