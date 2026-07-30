enum LogLevel {
  debug,
  info,
  warn,
  error;

  String get label => name.toUpperCase();

  /// Parse from env string; returns null when unrecognized.
  static LogLevel? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().toLowerCase();
    for (final level in LogLevel.values) {
      if (level.name == normalized) return level;
    }
    return null;
  }
}
