import 'dart:io';

/// Creates an [HttpClient] with a temporary full TLS bypass.
///
/// TODO: Restore strict Let's Encrypt pinning before production release.
/// Temporary workaround for CERTIFICATE_VERIFY_FAILED on some platforms
/// (missing local issuer / outdated root stores).
HttpClient createPinnedApiHttpClient() {
  return HttpClient(context: SecurityContext.defaultContext)
    ..badCertificateCallback = allowPinnedApiCertificate;
}

/// Temporary full TLS bypass — accepts any host certificate.
bool allowPinnedApiCertificate(
  X509Certificate cert,
  String host,
  int port,
) {
  return true;
}
