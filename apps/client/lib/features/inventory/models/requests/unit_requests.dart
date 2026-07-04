class UnitListQuery {
  const UnitListQuery({
    this.page = 1,
    this.limit = 20,
    this.q,
    this.isActive,
    this.sort = 'name',
    this.order = 'asc',
  });

  final int page;
  final int limit;
  final String? q;
  final bool? isActive;
  final String sort;
  final String order;

  UnitListQuery copyWith({int? page, int? limit, String? q, bool? isActive}) {
    return UnitListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      q: q ?? this.q,
      isActive: isActive ?? this.isActive,
      sort: sort,
      order: order,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (q != null && q!.isNotEmpty) 'q': q,
    if (isActive != null) 'is_active': isActive,
    'sort': sort,
    'order': order,
  };
}

class CreateUnitRequest {
  const CreateUnitRequest({
    required this.name,
    required this.shortName,
    this.symbol,
    this.decimalPlaces = 0,
    this.isSystem = false,
    this.isActive = true,
  });

  final String name;
  final String shortName;
  final String? symbol;
  final int decimalPlaces;
  final bool isSystem;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'name': name,
    'short_name': shortName,
    if (symbol != null && symbol!.isNotEmpty) 'symbol': symbol,
    'decimal_places': decimalPlaces,
    'is_system': isSystem,
    'is_active': isActive,
  };
}

class UpdateUnitRequest {
  const UpdateUnitRequest({
    this.name,
    this.shortName,
    this.symbol,
    this.decimalPlaces,
    this.isActive,
  });

  final String? name;
  final String? shortName;
  final String? symbol;
  final int? decimalPlaces;
  final bool? isActive;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (shortName != null) json['short_name'] = shortName;
    if (symbol != null) json['symbol'] = symbol;
    if (decimalPlaces != null) json['decimal_places'] = decimalPlaces;
    if (isActive != null) json['is_active'] = isActive;
    return json;
  }
}

class UnitConversionListQuery {
  const UnitConversionListQuery({
    this.page = 1,
    this.limit = 20,
    this.fromUnitId,
    this.toUnitId,
  });

  final int page;
  final int limit;
  final String? fromUnitId;
  final String? toUnitId;

  UnitConversionListQuery copyWith({
    int? page,
    int? limit,
    String? fromUnitId,
    String? toUnitId,
  }) {
    return UnitConversionListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      fromUnitId: fromUnitId ?? this.fromUnitId,
      toUnitId: toUnitId ?? this.toUnitId,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (fromUnitId != null) 'from_unit_id': fromUnitId,
    if (toUnitId != null) 'to_unit_id': toUnitId,
  };
}

class CreateUnitConversionRequest {
  const CreateUnitConversionRequest({
    required this.fromUnitId,
    required this.toUnitId,
    required this.conversionFactor,
  });

  final String fromUnitId;
  final String toUnitId;
  final String conversionFactor;

  Map<String, dynamic> toJson() => {
    'from_unit_id': fromUnitId,
    'to_unit_id': toUnitId,
    'conversion_factor': conversionFactor,
  };
}

class UpdateUnitConversionRequest {
  const UpdateUnitConversionRequest({
    this.fromUnitId,
    this.toUnitId,
    this.conversionFactor,
  });

  final String? fromUnitId;
  final String? toUnitId;
  final String? conversionFactor;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (fromUnitId != null) json['from_unit_id'] = fromUnitId;
    if (toUnitId != null) json['to_unit_id'] = toUnitId;
    if (conversionFactor != null) json['conversion_factor'] = conversionFactor;
    return json;
  }
}
