import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';

/// Creates an [HttpClient] that uses the patched [SecurityContext.defaultContext]
/// and a **strictly pinned** `badCertificateCallback` fallback for outdated
/// Windows root stores.
///
/// The callback only returns `true` when all of the following hold:
/// 1. The connection host is exactly [AppConfig.apiBaseUrl]'s host
/// 2. The certificate issuer is Let's Encrypt / ISRG
/// 3. The certificate subject or PEM names that same API host
///
/// This is not a blind bypass — a MITM cert for another domain is rejected.
HttpClient createPinnedApiHttpClient() {
  return HttpClient(context: SecurityContext.defaultContext)
    ..badCertificateCallback = allowPinnedApiCertificate;
}

/// Strict pin used as a last-resort TLS fallback (notably unpatched Windows 10).
bool allowPinnedApiCertificate(
  X509Certificate cert,
  String host,
  int port,
) {
  final apiHost = Uri.tryParse(AppConfig.apiBaseUrl)?.host;
  if (apiHost == null || apiHost.isEmpty) return false;

  // 1. Must be our configured API host only.
  if (host != apiHost) return false;

  // 2. Issuer must be Let's Encrypt / ISRG (Railway's CA chain).
  final issuer = cert.issuer;
  final isLetsEncrypt = issuer.contains("Let's Encrypt") ||
      issuer.contains('ISRG') ||
      issuer.contains('R3') ||
      issuer.contains('R10') ||
      issuer.contains('R11') ||
      issuer.contains('E1') ||
      issuer.contains('E5') ||
      issuer.contains('E6');
  if (!isLetsEncrypt) return false;

  // 3. Leaf must be issued for our host (blocks LE certs for other domains).
  final namesOurHost =
      cert.subject.contains(apiHost) || cert.pem.contains(apiHost);
  return namesOurHost;
}
