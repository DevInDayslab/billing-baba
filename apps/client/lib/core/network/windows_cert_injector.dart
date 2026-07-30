import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// Injects trusted roots from the Windows system certificate store into Dart's
/// BoringSSL [SecurityContext], matching native Windows TLS trust behavior.
///
/// Uses direct `crypt32.dll` FFI bindings rather than `package:win32`'s barrel
/// import: win32 6.x does not export CertOpenSystemStore /
/// CertEnumCertificatesInStore, and importing `win32.dart` eagerly opens
/// Windows DLLs (which breaks non-Windows builds).
class WindowsCertInjector {
  WindowsCertInjector._();

  static DynamicLibrary? _crypt32;

  /// Reads the Windows `ROOT` stores and adds each certificate to
  /// [SecurityContext.defaultContext].
  static void injectSystemCertificates() {
    if (!Platform.isWindows) return;

    try {
      _crypt32 = DynamicLibrary.open('crypt32.dll');
      // Current-user ROOT (same as CertOpenSystemStore).
      _injectFromSystemStore('ROOT');
      // Local Machine ROOT — enterprise / IT-deployed roots.
      _injectFromLocalMachineStore('ROOT');
    } on Object catch (e, st) {
      debugPrint('WindowsCertInjector failed: $e\n$st');
    } finally {
      _crypt32 = null;
    }
  }

  static void _injectFromSystemStore(String name) {
    final storeName = name.toNativeUtf16();
    try {
      final hStore = _certOpenSystemStore(nullptr, storeName);
      if (hStore == nullptr) return;
      try {
        _enumerateAndInject(hStore);
      } finally {
        _certCloseStore(hStore, 0);
      }
    } finally {
      calloc.free(storeName);
    }
  }

  static void _injectFromLocalMachineStore(String storeName) {
    final namePtr = storeName.toNativeUtf16();
    try {
      // CERT_STORE_PROV_SYSTEM is passed as an integer cast to LPCSTR.
      final hStore = _certOpenStore(
        Pointer<Void>.fromAddress(_certStoreProvSystem),
        0,
        nullptr,
        _certSystemStoreLocalMachine | _certStoreReadonlyFlag,
        namePtr,
      );
      if (hStore == nullptr) return;
      try {
        _enumerateAndInject(hStore);
      } finally {
        _certCloseStore(hStore, 0);
      }
    } finally {
      calloc.free(namePtr);
    }
  }

  static void _enumerateAndInject(Pointer<Void> hStore) {
    Pointer<Void> pCertContext = nullptr;

    while (true) {
      pCertContext = _certEnumCertificatesInStore(hStore, pCertContext);
      if (pCertContext == nullptr) break;

      final ctx = pCertContext.cast<_CertContext>().ref;
      if (ctx.pbCertEncoded == nullptr || ctx.cbCertEncoded <= 0) continue;

      // Copy before the next enum call frees this CERT_CONTEXT.
      final certBytes = Uint8List.fromList(
        ctx.pbCertEncoded.asTypedList(ctx.cbCertEncoded),
      );

      try {
        SecurityContext.defaultContext.setTrustedCertificatesBytes(certBytes);
      } on Object {
        // BoringSSL may reject malformed or obsolete store entries.
      }
    }
  }

  static Pointer<Void> Function(Pointer<Void>, Pointer<Utf16>)
  get _certOpenSystemStore => _crypt32!
      .lookupFunction<
        Pointer<Void> Function(Pointer<Void>, Pointer<Utf16>),
        Pointer<Void> Function(Pointer<Void>, Pointer<Utf16>)
      >('CertOpenSystemStoreW');

  static Pointer<Void> Function(
    Pointer<Void>,
    int,
    Pointer<Void>,
    int,
    Pointer<Utf16>,
  )
  get _certOpenStore => _crypt32!
      .lookupFunction<
        Pointer<Void> Function(
          Pointer<Void>,
          Uint32,
          Pointer<Void>,
          Uint32,
          Pointer<Utf16>,
        ),
        Pointer<Void> Function(
          Pointer<Void>,
          int,
          Pointer<Void>,
          int,
          Pointer<Utf16>,
        )
      >('CertOpenStore');

  static Pointer<Void> Function(Pointer<Void>, Pointer<Void>)
  get _certEnumCertificatesInStore => _crypt32!
      .lookupFunction<
        Pointer<Void> Function(Pointer<Void>, Pointer<Void>),
        Pointer<Void> Function(Pointer<Void>, Pointer<Void>)
      >('CertEnumCertificatesInStore');

  static int Function(Pointer<Void>, int) get _certCloseStore => _crypt32!
      .lookupFunction<
        Int32 Function(Pointer<Void>, Uint32),
        int Function(Pointer<Void>, int)
      >('CertCloseStore');
}

/// Minimal layout of `CERT_CONTEXT` (wincrypt.h).
base class _CertContext extends Struct {
  @Uint32()
  external int dwCertEncodingType;

  external Pointer<Uint8> pbCertEncoded;

  @Uint32()
  external int cbCertEncoded;

  external Pointer<Void> pCertInfo;

  external Pointer<Void> hCertStore;
}

/// CERT_STORE_PROV_SYSTEM (9) — encoded as pointer address for LPCSTR provider.
const int _certStoreProvSystem = 9;

/// CERT_SYSTEM_STORE_LOCAL_MACHINE
const int _certSystemStoreLocalMachine = 0x00020000;

/// CERT_STORE_READONLY_FLAG
const int _certStoreReadonlyFlag = 0x00008000;
