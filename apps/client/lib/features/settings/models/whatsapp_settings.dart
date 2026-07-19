class WhatsAppSettings {
  const WhatsAppSettings({required this.enabled});

  const WhatsAppSettings.defaults() : enabled = true;

  final bool enabled;

  WhatsAppSettings copyWith({bool? enabled}) {
    return WhatsAppSettings(enabled: enabled ?? this.enabled);
  }
}
