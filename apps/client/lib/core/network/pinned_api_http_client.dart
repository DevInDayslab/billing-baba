import 'dart:io';

import 'package:dio/io.dart';

/// Temporary full BoringSSL / TLS certificate bypass for the desktop client.
///
/// TODO: Restore strict Let's Encrypt pinning before production release.
class BypassSslHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = allowPinnedApiCertificate;
  }
}

/// Installs a global [HttpOverrides] so every [HttpClient] accepts all certs.
void installSslBypass() {
  HttpOverrides.global = BypassSslHttpOverrides();
}

/// Creates an [HttpClient] that accepts every certificate.
HttpClient createPinnedApiHttpClient() {
  return HttpClient(context: SecurityContext.defaultContext)
    ..badCertificateCallback = allowPinnedApiCertificate;
}

/// Dio adapter that bypasses both handshake and leaf-cert checks.
IOHttpClientAdapter createBypassSslHttpClientAdapter() {
  return IOHttpClientAdapter(
    createHttpClient: createPinnedApiHttpClient,
    validateCertificate: (cert, host, status) => true,
  );
}

/// Temporary full TLS bypass — accepts any host certificate.
bool allowPinnedApiCertificate(
  X509Certificate cert,
  String host,
  int port,
) {
  return true;
}
