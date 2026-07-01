import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// In-memory attachment for sale / document forms.
@immutable
class SaleFormAttachment {
  const SaleFormAttachment({
    required this.id,
    required this.name,
    this.path = '',
  });

  factory SaleFormAttachment.create({
    required String name,
    String path = '',
  }) {
    return SaleFormAttachment(
      id: const Uuid().v4(),
      name: name,
      path: path.isEmpty ? name : path,
    );
  }

  final String id;
  final String name;
  final String path;

  String get displayName {
    if (name.isNotEmpty) return name;
    final segments = path.split(RegExp(r'[/\\]'));
    return segments.isNotEmpty ? segments.last : path;
  }

  SaleFormAttachment copyWith({String? name, String? path}) {
    return SaleFormAttachment(
      id: id,
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }
}
