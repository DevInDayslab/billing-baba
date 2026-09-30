const kMaxPartyAdditionalPhones = 4;

/// Additional mobile number with an optional user label (e.g. WhatsApp, Office).
class PartyAdditionalPhoneDetail {
  const PartyAdditionalPhoneDetail({
    required this.phone,
    this.label = '',
  });

  final String phone;
  final String label;

  factory PartyAdditionalPhoneDetail.fromJson(Map<String, dynamic> json) {
    return PartyAdditionalPhoneDetail(
      phone: json['phone']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'label': label,
  };

  PartyAdditionalPhoneDetail copyWith({String? phone, String? label}) {
    return PartyAdditionalPhoneDetail(
      phone: phone ?? this.phone,
      label: label ?? this.label,
    );
  }
}
