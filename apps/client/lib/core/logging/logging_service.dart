import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/diagnostics_store.dart';
import 'package:billing_baba/core/logging/log_level.dart';
import 'package:billing_baba/core/logging/log_sanitizer.dart';
import 'package:billing_baba/core/network/network_error_details.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Centralized application logging with rotating file output.
class LoggingService {
  LoggingService._();

  static final LoggingService instance = LoggingService._();

  static const int _maxFileBytes = 5 * 1024 * 1024;
  static const _maxRotatedFiles = 5;
  static const _maxBufferLines = 500;

  final _buffer = ListQueue<String>();
  final _writeQueue = Queue<_LogEntry>();
  var _initialized = false;
  var _isWriting = false;
  Directory? _logDirectory;
  File? _logFile;

  bool get isInitialized => _initialized;

  Directory? get logDirectory => _logDirectory;

  Future<void> initialize() async {
    if (_initialized) return;

    _logDirectory = await _resolveLogDirectory();
    await _logDirectory!.create(recursive: true);
    _logFile = File('${_logDirectory!.path}/billing_baba.log');

    _initialized = true;
    await _rotateIfNeeded();
  }

  Future<Directory> _resolveLogDirectory() async {
    if (!kIsWeb && AppPlatform.current.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.isNotEmpty) {
        return Directory('$localAppData\\${AppConfig.appName}\\logs');
      }
    }

    final documents = await _documentsDirectory();
    return Directory('${documents.path}/${AppConfig.appName}/logs');
  }

  Future<Directory> _documentsDirectory() async {
    if (!kIsWeb && AppPlatform.current.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null && userProfile.isNotEmpty) {
        return Directory('$userProfile\\Documents');
      }
    }
    if (!kIsWeb && AppPlatform.current.isMacOS) {
      return Directory('${Platform.environment['HOME'] ?? ''}/Documents');
    }
    if (!kIsWeb && AppPlatform.current.isLinux) {
      return Directory('${Platform.environment['HOME'] ?? ''}/Documents');
    }
    // Fallback for mobile — use app documents via path_provider pattern.
    final temp = Directory.systemTemp;
    return temp;
  }

  void debug(String message) => _log(LogLevel.debug, message);

  void info(String message) => _log(LogLevel.info, message);

  void warn(String message) => _log(LogLevel.warn, message);

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    final buffer = StringBuffer(message);
    if (error != null) {
      buffer.write('\n$error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    _log(LogLevel.error, buffer.toString());
    if (error is Object) {
      DiagnosticsStore.instance.recordError(
        NetworkErrorDetails(
          title: 'Application error',
          reason: error.runtimeType.toString(),
          details: error.toString(),
        ),
      );
    }
  }

  void _log(LogLevel level, String message) {
    final timestamp = _formatTimestamp(DateTime.now());
    final line = '$timestamp ${level.label} $message';

    final echoToConsole = switch (level) {
      LogLevel.error || LogLevel.warn => kDebugMode,
      LogLevel.info || LogLevel.debug => AppConfig.consoleVerbose,
    };
    if (echoToConsole) {
      debugPrint(line);
    }

    _buffer.add(line);
    while (_buffer.length > _maxBufferLines) {
      _buffer.removeFirst();
    }

    if (!_initialized) return;

    _writeQueue.add(_LogEntry(line));
    unawaited(_flushQueue());
  }

  Future<void> _flushQueue() async {
    if (_isWriting || _writeQueue.isEmpty || _logFile == null) return;
    _isWriting = true;
    try {
      while (_writeQueue.isNotEmpty) {
        final entry = _writeQueue.removeFirst();
        await _logFile!.writeAsString(
          '${entry.line}\n',
          mode: FileMode.append,
          flush: true,
        );
        await _rotateIfNeeded();
      }
    } on Object catch (e) {
      debugPrint('LoggingService write failed: $e');
    } finally {
      _isWriting = false;
      if (_writeQueue.isNotEmpty) {
        unawaited(_flushQueue());
      }
    }
  }

  Future<void> _rotateIfNeeded() async {
    final file = _logFile;
    if (file == null || !await file.exists()) return;

    final length = await file.length();
    if (length < _maxFileBytes) return;

    for (var i = _maxRotatedFiles - 1; i >= 1; i--) {
      final older = File('${file.path}.$i');
      final newer = i == 1 ? file : File('${file.path}.${i - 1}');
      if (await newer.exists()) {
        await newer.rename(older.path);
      }
    }
    await file.writeAsString('', flush: true);
  }

  String _formatTimestamp(DateTime time) {
    return '${time.year.toString().padLeft(4, '0')}-'
        '${time.month.toString().padLeft(2, '0')}-'
        '${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  Future<String> readRecentLogs({int maxLines = 500}) async {
    if (_logFile != null && await _logFile!.exists()) {
      final content = await _logFile!.readAsString();
      final lines = content.split('\n');
      if (lines.length > maxLines) {
        return lines.sublist(lines.length - maxLines).join('\n');
      }
      return content;
    }
    return _buffer.join('\n');
  }

  Future<void> copyLogsToClipboard() async {
    final logs = await readRecentLogs();
    await Clipboard.setData(ClipboardData(text: logs));
  }

  Future<void> openLogFolder() async {
    final dir = _logDirectory;
    if (dir == null) return;

    if (kIsWeb) return;

    final platform = AppPlatform.current;
    if (platform.isWindows) {
      await Process.run('explorer', [dir.path]);
    } else if (platform.isMacOS) {
      await Process.run('open', [dir.path]);
    } else if (platform.isLinux) {
      await Process.run('xdg-open', [dir.path]);
    }
  }

  Future<void> logStartupBanner({
    required List<String> configLines,
    required List<String> deviceLines,
  }) async {
    const divider = '----------------------------------------';
    info(divider);
    info('Billing Baba Startup');
    for (final line in deviceLines) {
      info(line);
    }
    for (final line in configLines) {
      info(line);
    }
    info(divider);
  }

  static String maskPhone(String phone) => LogSanitizer.maskPhone(phone);
}

class _LogEntry {
  _LogEntry(this.line);
  final String line;
}
