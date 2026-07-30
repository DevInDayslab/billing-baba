import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Temporary full BoringSSL / TLS certificate bypass for the desktop client.
///
/// Temporary workaround — restore strict Let's Encrypt pinning before release.
class BypassSslHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

/// Installs a global [HttpOverrides] so every [HttpClient] accepts all certs.
void installSslBypass() {
  HttpOverrides.global = BypassSslHttpOverrides();
}

/// Creates an [HttpClient] that accepts every certificate.
HttpClient createPinnedApiHttpClient() {
  return HttpClient()..badCertificateCallback = (cert, host, port) => true;
}

/// Dio adapter that bypasses both handshake and leaf-cert checks.
IOHttpClientAdapter createBypassSslHttpClientAdapter() {
  return IOHttpClientAdapter(
    createHttpClient: createPinnedApiHttpClient,
    validateCertificate: (cert, host, status) => true,
  );
}

/// Dio instance configured with the temporary TLS bypass.
Dio createBypassSslDio({BaseOptions? options}) {
  return Dio(options)..httpClientAdapter = createBypassSslHttpClientAdapter();
}

/// Temporary full TLS bypass — accepts any host certificate.
bool allowPinnedApiCertificate(
  X509Certificate cert,
  String host,
  int port,
) {
  return true;
}
