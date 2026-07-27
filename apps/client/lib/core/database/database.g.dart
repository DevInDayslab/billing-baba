// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SalesLocalTable extends SalesLocal
    with TableInfo<$SalesLocalTable, SaleLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _docNumberMeta = const VerificationMeta(
    'docNumber',
  );
  @override
  late final GeneratedColumn<String> docNumber = GeneratedColumn<String>(
    'doc_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finalAmountMeta = const VerificationMeta(
    'finalAmount',
  );
  @override
  late final GeneratedColumn<double> finalAmount = GeneratedColumn<double>(
    'final_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apiResponseJsonMeta = const VerificationMeta(
    'apiResponseJson',
  );
  @override
  late final GeneratedColumn<String> apiResponseJson = GeneratedColumn<String>(
    'api_response_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    docNumber,
    partyId,
    totalAmount,
    taxAmount,
    finalAmount,
    createdAt,
    savedAt,
    paymentMethod,
    apiResponseJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('doc_number')) {
      context.handle(
        _docNumberMeta,
        docNumber.isAcceptableOrUnknown(data['doc_number']!, _docNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_docNumberMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_taxAmountMeta);
    }
    if (data.containsKey('final_amount')) {
      context.handle(
        _finalAmountMeta,
        finalAmount.isAcceptableOrUnknown(
          data['final_amount']!,
          _finalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_finalAmountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('api_response_json')) {
      context.handle(
        _apiResponseJsonMeta,
        apiResponseJson.isAcceptableOrUnknown(
          data['api_response_json']!,
          _apiResponseJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_apiResponseJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleLocal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      docNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_number'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      ),
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
      finalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}final_amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      apiResponseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_response_json'],
      )!,
    );
  }

  @override
  $SalesLocalTable createAlias(String alias) {
    return $SalesLocalTable(attachedDatabase, alias);
  }
}

class SaleLocal extends DataClass implements Insertable<SaleLocal> {
  final String id;
  final String businessId;
  final String docNumber;
  final String? partyId;
  final double totalAmount;
  final double taxAmount;
  final double finalAmount;
  final DateTime createdAt;
  final DateTime savedAt;
  final String paymentMethod;
  final String apiResponseJson;
  const SaleLocal({
    required this.id,
    required this.businessId,
    required this.docNumber,
    this.partyId,
    required this.totalAmount,
    required this.taxAmount,
    required this.finalAmount,
    required this.createdAt,
    required this.savedAt,
    required this.paymentMethod,
    required this.apiResponseJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['doc_number'] = Variable<String>(docNumber);
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    map['total_amount'] = Variable<double>(totalAmount);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['final_amount'] = Variable<double>(finalAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['saved_at'] = Variable<DateTime>(savedAt);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['api_response_json'] = Variable<String>(apiResponseJson);
    return map;
  }

  SalesLocalCompanion toCompanion(bool nullToAbsent) {
    return SalesLocalCompanion(
      id: Value(id),
      businessId: Value(businessId),
      docNumber: Value(docNumber),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      totalAmount: Value(totalAmount),
      taxAmount: Value(taxAmount),
      finalAmount: Value(finalAmount),
      createdAt: Value(createdAt),
      savedAt: Value(savedAt),
      paymentMethod: Value(paymentMethod),
      apiResponseJson: Value(apiResponseJson),
    );
  }

  factory SaleLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleLocal(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      docNumber: serializer.fromJson<String>(json['docNumber']),
      partyId: serializer.fromJson<String?>(json['partyId']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      finalAmount: serializer.fromJson<double>(json['finalAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      apiResponseJson: serializer.fromJson<String>(json['apiResponseJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'docNumber': serializer.toJson<String>(docNumber),
      'partyId': serializer.toJson<String?>(partyId),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'finalAmount': serializer.toJson<double>(finalAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'apiResponseJson': serializer.toJson<String>(apiResponseJson),
    };
  }

  SaleLocal copyWith({
    String? id,
    String? businessId,
    String? docNumber,
    Value<String?> partyId = const Value.absent(),
    double? totalAmount,
    double? taxAmount,
    double? finalAmount,
    DateTime? createdAt,
    DateTime? savedAt,
    String? paymentMethod,
    String? apiResponseJson,
  }) => SaleLocal(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    docNumber: docNumber ?? this.docNumber,
    partyId: partyId.present ? partyId.value : this.partyId,
    totalAmount: totalAmount ?? this.totalAmount,
    taxAmount: taxAmount ?? this.taxAmount,
    finalAmount: finalAmount ?? this.finalAmount,
    createdAt: createdAt ?? this.createdAt,
    savedAt: savedAt ?? this.savedAt,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    apiResponseJson: apiResponseJson ?? this.apiResponseJson,
  );
  SaleLocal copyWithCompanion(SalesLocalCompanion data) {
    return SaleLocal(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      docNumber: data.docNumber.present ? data.docNumber.value : this.docNumber,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      finalAmount: data.finalAmount.present
          ? data.finalAmount.value
          : this.finalAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      apiResponseJson: data.apiResponseJson.present
          ? data.apiResponseJson.value
          : this.apiResponseJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleLocal(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('docNumber: $docNumber, ')
          ..write('partyId: $partyId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('finalAmount: $finalAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('savedAt: $savedAt, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('apiResponseJson: $apiResponseJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    docNumber,
    partyId,
    totalAmount,
    taxAmount,
    finalAmount,
    createdAt,
    savedAt,
    paymentMethod,
    apiResponseJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleLocal &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.docNumber == this.docNumber &&
          other.partyId == this.partyId &&
          other.totalAmount == this.totalAmount &&
          other.taxAmount == this.taxAmount &&
          other.finalAmount == this.finalAmount &&
          other.createdAt == this.createdAt &&
          other.savedAt == this.savedAt &&
          other.paymentMethod == this.paymentMethod &&
          other.apiResponseJson == this.apiResponseJson);
}

class SalesLocalCompanion extends UpdateCompanion<SaleLocal> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> docNumber;
  final Value<String?> partyId;
  final Value<double> totalAmount;
  final Value<double> taxAmount;
  final Value<double> finalAmount;
  final Value<DateTime> createdAt;
  final Value<DateTime> savedAt;
  final Value<String> paymentMethod;
  final Value<String> apiResponseJson;
  final Value<int> rowid;
  const SalesLocalCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.docNumber = const Value.absent(),
    this.partyId = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.finalAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.apiResponseJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesLocalCompanion.insert({
    required String id,
    required String businessId,
    required String docNumber,
    this.partyId = const Value.absent(),
    required double totalAmount,
    required double taxAmount,
    required double finalAmount,
    required DateTime createdAt,
    this.savedAt = const Value.absent(),
    required String paymentMethod,
    required String apiResponseJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       docNumber = Value(docNumber),
       totalAmount = Value(totalAmount),
       taxAmount = Value(taxAmount),
       finalAmount = Value(finalAmount),
       createdAt = Value(createdAt),
       paymentMethod = Value(paymentMethod),
       apiResponseJson = Value(apiResponseJson);
  static Insertable<SaleLocal> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? docNumber,
    Expression<String>? partyId,
    Expression<double>? totalAmount,
    Expression<double>? taxAmount,
    Expression<double>? finalAmount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? savedAt,
    Expression<String>? paymentMethod,
    Expression<String>? apiResponseJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (docNumber != null) 'doc_number': docNumber,
      if (partyId != null) 'party_id': partyId,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (finalAmount != null) 'final_amount': finalAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (savedAt != null) 'saved_at': savedAt,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (apiResponseJson != null) 'api_response_json': apiResponseJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? docNumber,
    Value<String?>? partyId,
    Value<double>? totalAmount,
    Value<double>? taxAmount,
    Value<double>? finalAmount,
    Value<DateTime>? createdAt,
    Value<DateTime>? savedAt,
    Value<String>? paymentMethod,
    Value<String>? apiResponseJson,
    Value<int>? rowid,
  }) {
    return SalesLocalCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      docNumber: docNumber ?? this.docNumber,
      partyId: partyId ?? this.partyId,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      createdAt: createdAt ?? this.createdAt,
      savedAt: savedAt ?? this.savedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      apiResponseJson: apiResponseJson ?? this.apiResponseJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (docNumber.present) {
      map['doc_number'] = Variable<String>(docNumber.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (finalAmount.present) {
      map['final_amount'] = Variable<double>(finalAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (apiResponseJson.present) {
      map['api_response_json'] = Variable<String>(apiResponseJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesLocalCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('docNumber: $docNumber, ')
          ..write('partyId: $partyId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('finalAmount: $finalAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('savedAt: $savedAt, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('apiResponseJson: $apiResponseJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesLineLocalTable extends SalesLineLocal
    with TableInfo<$SalesLineLocalTable, SaleLineLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesLineLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales_local (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTotalMeta = const VerificationMeta(
    'lineTotal',
  );
  @override
  late final GeneratedColumn<double> lineTotal = GeneratedColumn<double>(
    'line_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cgstAmountMeta = const VerificationMeta(
    'cgstAmount',
  );
  @override
  late final GeneratedColumn<double> cgstAmount = GeneratedColumn<double>(
    'cgst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sgstAmountMeta = const VerificationMeta(
    'sgstAmount',
  );
  @override
  late final GeneratedColumn<double> sgstAmount = GeneratedColumn<double>(
    'sgst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _igstAmountMeta = const VerificationMeta(
    'igstAmount',
  );
  @override
  late final GeneratedColumn<double> igstAmount = GeneratedColumn<double>(
    'igst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    saleId,
    itemId,
    itemName,
    quantity,
    rate,
    lineTotal,
    cgstAmount,
    sgstAmount,
    igstAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales_line_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleLineLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('line_total')) {
      context.handle(
        _lineTotalMeta,
        lineTotal.isAcceptableOrUnknown(data['line_total']!, _lineTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_lineTotalMeta);
    }
    if (data.containsKey('cgst_amount')) {
      context.handle(
        _cgstAmountMeta,
        cgstAmount.isAcceptableOrUnknown(data['cgst_amount']!, _cgstAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_cgstAmountMeta);
    }
    if (data.containsKey('sgst_amount')) {
      context.handle(
        _sgstAmountMeta,
        sgstAmount.isAcceptableOrUnknown(data['sgst_amount']!, _sgstAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_sgstAmountMeta);
    }
    if (data.containsKey('igst_amount')) {
      context.handle(
        _igstAmountMeta,
        igstAmount.isAcceptableOrUnknown(data['igst_amount']!, _igstAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_igstAmountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleLineLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleLineLocal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      lineTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}line_total'],
      )!,
      cgstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cgst_amount'],
      )!,
      sgstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sgst_amount'],
      )!,
      igstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igst_amount'],
      )!,
    );
  }

  @override
  $SalesLineLocalTable createAlias(String alias) {
    return $SalesLineLocalTable(attachedDatabase, alias);
  }
}

class SaleLineLocal extends DataClass implements Insertable<SaleLineLocal> {
  final String id;
  final String businessId;
  final String saleId;
  final String itemId;
  final String itemName;
  final int quantity;
  final double rate;
  final double lineTotal;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  const SaleLineLocal({
    required this.id,
    required this.businessId,
    required this.saleId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.rate,
    required this.lineTotal,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['sale_id'] = Variable<String>(saleId);
    map['item_id'] = Variable<String>(itemId);
    map['item_name'] = Variable<String>(itemName);
    map['quantity'] = Variable<int>(quantity);
    map['rate'] = Variable<double>(rate);
    map['line_total'] = Variable<double>(lineTotal);
    map['cgst_amount'] = Variable<double>(cgstAmount);
    map['sgst_amount'] = Variable<double>(sgstAmount);
    map['igst_amount'] = Variable<double>(igstAmount);
    return map;
  }

  SalesLineLocalCompanion toCompanion(bool nullToAbsent) {
    return SalesLineLocalCompanion(
      id: Value(id),
      businessId: Value(businessId),
      saleId: Value(saleId),
      itemId: Value(itemId),
      itemName: Value(itemName),
      quantity: Value(quantity),
      rate: Value(rate),
      lineTotal: Value(lineTotal),
      cgstAmount: Value(cgstAmount),
      sgstAmount: Value(sgstAmount),
      igstAmount: Value(igstAmount),
    );
  }

  factory SaleLineLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleLineLocal(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      saleId: serializer.fromJson<String>(json['saleId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      rate: serializer.fromJson<double>(json['rate']),
      lineTotal: serializer.fromJson<double>(json['lineTotal']),
      cgstAmount: serializer.fromJson<double>(json['cgstAmount']),
      sgstAmount: serializer.fromJson<double>(json['sgstAmount']),
      igstAmount: serializer.fromJson<double>(json['igstAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'saleId': serializer.toJson<String>(saleId),
      'itemId': serializer.toJson<String>(itemId),
      'itemName': serializer.toJson<String>(itemName),
      'quantity': serializer.toJson<int>(quantity),
      'rate': serializer.toJson<double>(rate),
      'lineTotal': serializer.toJson<double>(lineTotal),
      'cgstAmount': serializer.toJson<double>(cgstAmount),
      'sgstAmount': serializer.toJson<double>(sgstAmount),
      'igstAmount': serializer.toJson<double>(igstAmount),
    };
  }

  SaleLineLocal copyWith({
    String? id,
    String? businessId,
    String? saleId,
    String? itemId,
    String? itemName,
    int? quantity,
    double? rate,
    double? lineTotal,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
  }) => SaleLineLocal(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    saleId: saleId ?? this.saleId,
    itemId: itemId ?? this.itemId,
    itemName: itemName ?? this.itemName,
    quantity: quantity ?? this.quantity,
    rate: rate ?? this.rate,
    lineTotal: lineTotal ?? this.lineTotal,
    cgstAmount: cgstAmount ?? this.cgstAmount,
    sgstAmount: sgstAmount ?? this.sgstAmount,
    igstAmount: igstAmount ?? this.igstAmount,
  );
  SaleLineLocal copyWithCompanion(SalesLineLocalCompanion data) {
    return SaleLineLocal(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      rate: data.rate.present ? data.rate.value : this.rate,
      lineTotal: data.lineTotal.present ? data.lineTotal.value : this.lineTotal,
      cgstAmount: data.cgstAmount.present
          ? data.cgstAmount.value
          : this.cgstAmount,
      sgstAmount: data.sgstAmount.present
          ? data.sgstAmount.value
          : this.sgstAmount,
      igstAmount: data.igstAmount.present
          ? data.igstAmount.value
          : this.igstAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleLineLocal(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('saleId: $saleId, ')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('rate: $rate, ')
          ..write('lineTotal: $lineTotal, ')
          ..write('cgstAmount: $cgstAmount, ')
          ..write('sgstAmount: $sgstAmount, ')
          ..write('igstAmount: $igstAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    saleId,
    itemId,
    itemName,
    quantity,
    rate,
    lineTotal,
    cgstAmount,
    sgstAmount,
    igstAmount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleLineLocal &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.saleId == this.saleId &&
          other.itemId == this.itemId &&
          other.itemName == this.itemName &&
          other.quantity == this.quantity &&
          other.rate == this.rate &&
          other.lineTotal == this.lineTotal &&
          other.cgstAmount == this.cgstAmount &&
          other.sgstAmount == this.sgstAmount &&
          other.igstAmount == this.igstAmount);
}

class SalesLineLocalCompanion extends UpdateCompanion<SaleLineLocal> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> saleId;
  final Value<String> itemId;
  final Value<String> itemName;
  final Value<int> quantity;
  final Value<double> rate;
  final Value<double> lineTotal;
  final Value<double> cgstAmount;
  final Value<double> sgstAmount;
  final Value<double> igstAmount;
  final Value<int> rowid;
  const SalesLineLocalCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.saleId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rate = const Value.absent(),
    this.lineTotal = const Value.absent(),
    this.cgstAmount = const Value.absent(),
    this.sgstAmount = const Value.absent(),
    this.igstAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesLineLocalCompanion.insert({
    required String id,
    required String businessId,
    required String saleId,
    required String itemId,
    required String itemName,
    required int quantity,
    required double rate,
    required double lineTotal,
    required double cgstAmount,
    required double sgstAmount,
    required double igstAmount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       saleId = Value(saleId),
       itemId = Value(itemId),
       itemName = Value(itemName),
       quantity = Value(quantity),
       rate = Value(rate),
       lineTotal = Value(lineTotal),
       cgstAmount = Value(cgstAmount),
       sgstAmount = Value(sgstAmount),
       igstAmount = Value(igstAmount);
  static Insertable<SaleLineLocal> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? saleId,
    Expression<String>? itemId,
    Expression<String>? itemName,
    Expression<int>? quantity,
    Expression<double>? rate,
    Expression<double>? lineTotal,
    Expression<double>? cgstAmount,
    Expression<double>? sgstAmount,
    Expression<double>? igstAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (saleId != null) 'sale_id': saleId,
      if (itemId != null) 'item_id': itemId,
      if (itemName != null) 'item_name': itemName,
      if (quantity != null) 'quantity': quantity,
      if (rate != null) 'rate': rate,
      if (lineTotal != null) 'line_total': lineTotal,
      if (cgstAmount != null) 'cgst_amount': cgstAmount,
      if (sgstAmount != null) 'sgst_amount': sgstAmount,
      if (igstAmount != null) 'igst_amount': igstAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesLineLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? saleId,
    Value<String>? itemId,
    Value<String>? itemName,
    Value<int>? quantity,
    Value<double>? rate,
    Value<double>? lineTotal,
    Value<double>? cgstAmount,
    Value<double>? sgstAmount,
    Value<double>? igstAmount,
    Value<int>? rowid,
  }) {
    return SalesLineLocalCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      saleId: saleId ?? this.saleId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      lineTotal: lineTotal ?? this.lineTotal,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (lineTotal.present) {
      map['line_total'] = Variable<double>(lineTotal.value);
    }
    if (cgstAmount.present) {
      map['cgst_amount'] = Variable<double>(cgstAmount.value);
    }
    if (sgstAmount.present) {
      map['sgst_amount'] = Variable<double>(sgstAmount.value);
    }
    if (igstAmount.present) {
      map['igst_amount'] = Variable<double>(igstAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesLineLocalCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('saleId: $saleId, ')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('rate: $rate, ')
          ..write('lineTotal: $lineTotal, ')
          ..write('cgstAmount: $cgstAmount, ')
          ..write('sgstAmount: $sgstAmount, ')
          ..write('igstAmount: $igstAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HeldBillsLocalTable extends HeldBillsLocal
    with TableInfo<$HeldBillsLocalTable, HeldBillsLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeldBillsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentsJsonMeta = const VerificationMeta(
    'paymentsJson',
  );
  @override
  late final GeneratedColumn<String> paymentsJson = GeneratedColumn<String>(
    'payments_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heldAtMeta = const VerificationMeta('heldAt');
  @override
  late final GeneratedColumn<DateTime> heldAt = GeneratedColumn<DateTime>(
    'held_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    itemsJson,
    paymentsJson,
    customerName,
    notes,
    heldAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'held_bills_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<HeldBillsLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    if (data.containsKey('payments_json')) {
      context.handle(
        _paymentsJsonMeta,
        paymentsJson.isAcceptableOrUnknown(
          data['payments_json']!,
          _paymentsJsonMeta,
        ),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('held_at')) {
      context.handle(
        _heldAtMeta,
        heldAt.isAcceptableOrUnknown(data['held_at']!, _heldAtMeta),
      );
    } else if (isInserting) {
      context.missing(_heldAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HeldBillsLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeldBillsLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
      paymentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payments_json'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      heldAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}held_at'],
      )!,
    );
  }

  @override
  $HeldBillsLocalTable createAlias(String alias) {
    return $HeldBillsLocalTable(attachedDatabase, alias);
  }
}

class HeldBillsLocalData extends DataClass
    implements Insertable<HeldBillsLocalData> {
  final String id;
  final String businessId;
  final String itemsJson;
  final String paymentsJson;
  final String? customerName;
  final String? notes;
  final DateTime heldAt;
  const HeldBillsLocalData({
    required this.id,
    required this.businessId,
    required this.itemsJson,
    required this.paymentsJson,
    this.customerName,
    this.notes,
    required this.heldAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['items_json'] = Variable<String>(itemsJson);
    map['payments_json'] = Variable<String>(paymentsJson);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['held_at'] = Variable<DateTime>(heldAt);
    return map;
  }

  HeldBillsLocalCompanion toCompanion(bool nullToAbsent) {
    return HeldBillsLocalCompanion(
      id: Value(id),
      businessId: Value(businessId),
      itemsJson: Value(itemsJson),
      paymentsJson: Value(paymentsJson),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      heldAt: Value(heldAt),
    );
  }

  factory HeldBillsLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeldBillsLocalData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      paymentsJson: serializer.fromJson<String>(json['paymentsJson']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      notes: serializer.fromJson<String?>(json['notes']),
      heldAt: serializer.fromJson<DateTime>(json['heldAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'paymentsJson': serializer.toJson<String>(paymentsJson),
      'customerName': serializer.toJson<String?>(customerName),
      'notes': serializer.toJson<String?>(notes),
      'heldAt': serializer.toJson<DateTime>(heldAt),
    };
  }

  HeldBillsLocalData copyWith({
    String? id,
    String? businessId,
    String? itemsJson,
    String? paymentsJson,
    Value<String?> customerName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? heldAt,
  }) => HeldBillsLocalData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    itemsJson: itemsJson ?? this.itemsJson,
    paymentsJson: paymentsJson ?? this.paymentsJson,
    customerName: customerName.present ? customerName.value : this.customerName,
    notes: notes.present ? notes.value : this.notes,
    heldAt: heldAt ?? this.heldAt,
  );
  HeldBillsLocalData copyWithCompanion(HeldBillsLocalCompanion data) {
    return HeldBillsLocalData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      paymentsJson: data.paymentsJson.present
          ? data.paymentsJson.value
          : this.paymentsJson,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      notes: data.notes.present ? data.notes.value : this.notes,
      heldAt: data.heldAt.present ? data.heldAt.value : this.heldAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HeldBillsLocalData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('paymentsJson: $paymentsJson, ')
          ..write('customerName: $customerName, ')
          ..write('notes: $notes, ')
          ..write('heldAt: $heldAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    itemsJson,
    paymentsJson,
    customerName,
    notes,
    heldAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeldBillsLocalData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.itemsJson == this.itemsJson &&
          other.paymentsJson == this.paymentsJson &&
          other.customerName == this.customerName &&
          other.notes == this.notes &&
          other.heldAt == this.heldAt);
}

class HeldBillsLocalCompanion extends UpdateCompanion<HeldBillsLocalData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> itemsJson;
  final Value<String> paymentsJson;
  final Value<String?> customerName;
  final Value<String?> notes;
  final Value<DateTime> heldAt;
  final Value<int> rowid;
  const HeldBillsLocalCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.paymentsJson = const Value.absent(),
    this.customerName = const Value.absent(),
    this.notes = const Value.absent(),
    this.heldAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HeldBillsLocalCompanion.insert({
    required String id,
    required String businessId,
    required String itemsJson,
    this.paymentsJson = const Value.absent(),
    this.customerName = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime heldAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       itemsJson = Value(itemsJson),
       heldAt = Value(heldAt);
  static Insertable<HeldBillsLocalData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? itemsJson,
    Expression<String>? paymentsJson,
    Expression<String>? customerName,
    Expression<String>? notes,
    Expression<DateTime>? heldAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (itemsJson != null) 'items_json': itemsJson,
      if (paymentsJson != null) 'payments_json': paymentsJson,
      if (customerName != null) 'customer_name': customerName,
      if (notes != null) 'notes': notes,
      if (heldAt != null) 'held_at': heldAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HeldBillsLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? itemsJson,
    Value<String>? paymentsJson,
    Value<String?>? customerName,
    Value<String?>? notes,
    Value<DateTime>? heldAt,
    Value<int>? rowid,
  }) {
    return HeldBillsLocalCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      itemsJson: itemsJson ?? this.itemsJson,
      paymentsJson: paymentsJson ?? this.paymentsJson,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
      heldAt: heldAt ?? this.heldAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (paymentsJson.present) {
      map['payments_json'] = Variable<String>(paymentsJson.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (heldAt.present) {
      map['held_at'] = Variable<DateTime>(heldAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeldBillsLocalCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('paymentsJson: $paymentsJson, ')
          ..write('customerName: $customerName, ')
          ..write('notes: $notes, ')
          ..write('heldAt: $heldAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeadsTable extends Leads with TableInfo<$LeadsTable, LeadTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leadSourceMeta = const VerificationMeta(
    'leadSource',
  );
  @override
  late final GeneratedColumn<String> leadSource = GeneratedColumn<String>(
    'lead_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
    'assigned_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    company,
    phone,
    email,
    leadSource,
    status,
    assignedTo,
    notes,
    syncVersion,
    isDeleted,
    updatedAt,
    deletedAt,
    deviceId,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leads';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeadTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('lead_source')) {
      context.handle(
        _leadSourceMeta,
        leadSource.isAcceptableOrUnknown(data['lead_source']!, _leadSourceMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeadTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeadTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      leadSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_source'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LeadsTable createAlias(String alias) {
    return $LeadsTable(attachedDatabase, alias);
  }
}

class LeadTableData extends DataClass implements Insertable<LeadTableData> {
  final String id;
  final String businessId;
  final String name;
  final String? company;
  final String? phone;
  final String? email;
  final String? leadSource;
  final String status;
  final String? assignedTo;
  final String? notes;
  final int syncVersion;
  final bool isDeleted;
  final String updatedAt;
  final String? deletedAt;
  final String deviceId;
  final String syncStatus;
  final String createdAt;
  const LeadTableData({
    required this.id,
    required this.businessId,
    required this.name,
    this.company,
    this.phone,
    this.email,
    this.leadSource,
    required this.status,
    this.assignedTo,
    this.notes,
    required this.syncVersion,
    required this.isDeleted,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || leadSource != null) {
      map['lead_source'] = Variable<String>(leadSource);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<String>(assignedTo);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  LeadsCompanion toCompanion(bool nullToAbsent) {
    return LeadsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      leadSource: leadSource == null && nullToAbsent
          ? const Value.absent()
          : Value(leadSource),
      status: Value(status),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory LeadTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeadTableData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      company: serializer.fromJson<String?>(json['company']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      leadSource: serializer.fromJson<String?>(json['leadSource']),
      status: serializer.fromJson<String>(json['status']),
      assignedTo: serializer.fromJson<String?>(json['assignedTo']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'company': serializer.toJson<String?>(company),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'leadSource': serializer.toJson<String?>(leadSource),
      'status': serializer.toJson<String>(status),
      'assignedTo': serializer.toJson<String?>(assignedTo),
      'notes': serializer.toJson<String?>(notes),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  LeadTableData copyWith({
    String? id,
    String? businessId,
    String? name,
    Value<String?> company = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> leadSource = const Value.absent(),
    String? status,
    Value<String?> assignedTo = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? syncVersion,
    bool? isDeleted,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? deviceId,
    String? syncStatus,
    String? createdAt,
  }) => LeadTableData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    company: company.present ? company.value : this.company,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    leadSource: leadSource.present ? leadSource.value : this.leadSource,
    status: status ?? this.status,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
    notes: notes.present ? notes.value : this.notes,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  LeadTableData copyWithCompanion(LeadsCompanion data) {
    return LeadTableData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      company: data.company.present ? data.company.value : this.company,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      leadSource: data.leadSource.present
          ? data.leadSource.value
          : this.leadSource,
      status: data.status.present ? data.status.value : this.status,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeadTableData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('leadSource: $leadSource, ')
          ..write('status: $status, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('notes: $notes, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    name,
    company,
    phone,
    email,
    leadSource,
    status,
    assignedTo,
    notes,
    syncVersion,
    isDeleted,
    updatedAt,
    deletedAt,
    deviceId,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeadTableData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.company == this.company &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.leadSource == this.leadSource &&
          other.status == this.status &&
          other.assignedTo == this.assignedTo &&
          other.notes == this.notes &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class LeadsCompanion extends UpdateCompanion<LeadTableData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String?> company;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> leadSource;
  final Value<String> status;
  final Value<String?> assignedTo;
  final Value<String?> notes;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> deviceId;
  final Value<String> syncStatus;
  final Value<String> createdAt;
  final Value<int> rowid;
  const LeadsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.company = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.leadSource = const Value.absent(),
    this.status = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeadsCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    this.company = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.leadSource = const Value.absent(),
    this.status = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       name = Value(name),
       updatedAt = Value(updatedAt),
       createdAt = Value(createdAt);
  static Insertable<LeadTableData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? company,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? leadSource,
    Expression<String>? status,
    Expression<String>? assignedTo,
    Expression<String>? notes,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? syncStatus,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (company != null) 'company': company,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (leadSource != null) 'lead_source': leadSource,
      if (status != null) 'status': status,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (notes != null) 'notes': notes,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeadsCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? name,
    Value<String?>? company,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? leadSource,
    Value<String>? status,
    Value<String?>? assignedTo,
    Value<String?>? notes,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? syncStatus,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return LeadsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      leadSource: leadSource ?? this.leadSource,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      notes: notes ?? this.notes,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (leadSource.present) {
      map['lead_source'] = Variable<String>(leadSource.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeadsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('leadSource: $leadSource, ')
          ..write('status: $status, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('notes: $notes, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeadActivitiesTable extends LeadActivities
    with TableInfo<$LeadActivitiesTable, LeadActivityTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeadActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leadIdMeta = const VerificationMeta('leadId');
  @override
  late final GeneratedColumn<String> leadId = GeneratedColumn<String>(
    'lead_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedByMeta = const VerificationMeta(
    'addedBy',
  );
  @override
  late final GeneratedColumn<String> addedBy = GeneratedColumn<String>(
    'added_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    leadId,
    businessId,
    type,
    notes,
    addedBy,
    syncVersion,
    isDeleted,
    updatedAt,
    deletedAt,
    deviceId,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lead_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeadActivityTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lead_id')) {
      context.handle(
        _leadIdMeta,
        leadId.isAcceptableOrUnknown(data['lead_id']!, _leadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_leadIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('added_by')) {
      context.handle(
        _addedByMeta,
        addedBy.isAcceptableOrUnknown(data['added_by']!, _addedByMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeadActivityTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeadActivityTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      leadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      addedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_by'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LeadActivitiesTable createAlias(String alias) {
    return $LeadActivitiesTable(attachedDatabase, alias);
  }
}

class LeadActivityTableData extends DataClass
    implements Insertable<LeadActivityTableData> {
  final String id;
  final String leadId;
  final String businessId;
  final String type;
  final String? notes;
  final String? addedBy;
  final int syncVersion;
  final bool isDeleted;
  final String updatedAt;
  final String? deletedAt;
  final String deviceId;
  final String syncStatus;
  final String createdAt;
  const LeadActivityTableData({
    required this.id,
    required this.leadId,
    required this.businessId,
    required this.type,
    this.notes,
    this.addedBy,
    required this.syncVersion,
    required this.isDeleted,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lead_id'] = Variable<String>(leadId);
    map['business_id'] = Variable<String>(businessId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || addedBy != null) {
      map['added_by'] = Variable<String>(addedBy);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  LeadActivitiesCompanion toCompanion(bool nullToAbsent) {
    return LeadActivitiesCompanion(
      id: Value(id),
      leadId: Value(leadId),
      businessId: Value(businessId),
      type: Value(type),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      addedBy: addedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(addedBy),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory LeadActivityTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeadActivityTableData(
      id: serializer.fromJson<String>(json['id']),
      leadId: serializer.fromJson<String>(json['leadId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      type: serializer.fromJson<String>(json['type']),
      notes: serializer.fromJson<String?>(json['notes']),
      addedBy: serializer.fromJson<String?>(json['addedBy']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'leadId': serializer.toJson<String>(leadId),
      'businessId': serializer.toJson<String>(businessId),
      'type': serializer.toJson<String>(type),
      'notes': serializer.toJson<String?>(notes),
      'addedBy': serializer.toJson<String?>(addedBy),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  LeadActivityTableData copyWith({
    String? id,
    String? leadId,
    String? businessId,
    String? type,
    Value<String?> notes = const Value.absent(),
    Value<String?> addedBy = const Value.absent(),
    int? syncVersion,
    bool? isDeleted,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? deviceId,
    String? syncStatus,
    String? createdAt,
  }) => LeadActivityTableData(
    id: id ?? this.id,
    leadId: leadId ?? this.leadId,
    businessId: businessId ?? this.businessId,
    type: type ?? this.type,
    notes: notes.present ? notes.value : this.notes,
    addedBy: addedBy.present ? addedBy.value : this.addedBy,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  LeadActivityTableData copyWithCompanion(LeadActivitiesCompanion data) {
    return LeadActivityTableData(
      id: data.id.present ? data.id.value : this.id,
      leadId: data.leadId.present ? data.leadId.value : this.leadId,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      type: data.type.present ? data.type.value : this.type,
      notes: data.notes.present ? data.notes.value : this.notes,
      addedBy: data.addedBy.present ? data.addedBy.value : this.addedBy,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeadActivityTableData(')
          ..write('id: $id, ')
          ..write('leadId: $leadId, ')
          ..write('businessId: $businessId, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('addedBy: $addedBy, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    leadId,
    businessId,
    type,
    notes,
    addedBy,
    syncVersion,
    isDeleted,
    updatedAt,
    deletedAt,
    deviceId,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeadActivityTableData &&
          other.id == this.id &&
          other.leadId == this.leadId &&
          other.businessId == this.businessId &&
          other.type == this.type &&
          other.notes == this.notes &&
          other.addedBy == this.addedBy &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class LeadActivitiesCompanion extends UpdateCompanion<LeadActivityTableData> {
  final Value<String> id;
  final Value<String> leadId;
  final Value<String> businessId;
  final Value<String> type;
  final Value<String?> notes;
  final Value<String?> addedBy;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> deviceId;
  final Value<String> syncStatus;
  final Value<String> createdAt;
  final Value<int> rowid;
  const LeadActivitiesCompanion({
    this.id = const Value.absent(),
    this.leadId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.type = const Value.absent(),
    this.notes = const Value.absent(),
    this.addedBy = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeadActivitiesCompanion.insert({
    required String id,
    required String leadId,
    required String businessId,
    required String type,
    this.notes = const Value.absent(),
    this.addedBy = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       leadId = Value(leadId),
       businessId = Value(businessId),
       type = Value(type),
       updatedAt = Value(updatedAt),
       createdAt = Value(createdAt);
  static Insertable<LeadActivityTableData> custom({
    Expression<String>? id,
    Expression<String>? leadId,
    Expression<String>? businessId,
    Expression<String>? type,
    Expression<String>? notes,
    Expression<String>? addedBy,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? syncStatus,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (leadId != null) 'lead_id': leadId,
      if (businessId != null) 'business_id': businessId,
      if (type != null) 'type': type,
      if (notes != null) 'notes': notes,
      if (addedBy != null) 'added_by': addedBy,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeadActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? leadId,
    Value<String>? businessId,
    Value<String>? type,
    Value<String?>? notes,
    Value<String?>? addedBy,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? syncStatus,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return LeadActivitiesCompanion(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      businessId: businessId ?? this.businessId,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      addedBy: addedBy ?? this.addedBy,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (leadId.present) {
      map['lead_id'] = Variable<String>(leadId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (addedBy.present) {
      map['added_by'] = Variable<String>(addedBy.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeadActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('leadId: $leadId, ')
          ..write('businessId: $businessId, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('addedBy: $addedBy, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts
    with TableInfo<$ContactsTable, ContactTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salutationMeta = const VerificationMeta(
    'salutation',
  );
  @override
  late final GeneratedColumn<String> salutation = GeneratedColumn<String>(
    'salutation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountNameMeta = const VerificationMeta(
    'accountName',
  );
  @override
  late final GeneratedColumn<String> accountName = GeneratedColumn<String>(
    'account_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
    'assigned_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    firstName,
    lastName,
    salutation,
    accountName,
    phone,
    email,
    assignedTo,
    title,
    description,
    syncVersion,
    isDeleted,
    updatedAt,
    deletedAt,
    deviceId,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('salutation')) {
      context.handle(
        _salutationMeta,
        salutation.isAcceptableOrUnknown(data['salutation']!, _salutationMeta),
      );
    }
    if (data.containsKey('account_name')) {
      context.handle(
        _accountNameMeta,
        accountName.isAcceptableOrUnknown(
          data['account_name']!,
          _accountNameMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      ),
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      salutation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salutation'],
      ),
      accountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class ContactTableData extends DataClass
    implements Insertable<ContactTableData> {
  final String id;
  final String businessId;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? salutation;
  final String? accountName;
  final String? phone;
  final String? email;
  final String? assignedTo;
  final String? title;
  final String? description;
  final int syncVersion;
  final bool isDeleted;
  final String updatedAt;
  final String? deletedAt;
  final String deviceId;
  final String syncStatus;
  final String createdAt;
  const ContactTableData({
    required this.id,
    required this.businessId,
    required this.name,
    this.firstName,
    this.lastName,
    this.salutation,
    this.accountName,
    this.phone,
    this.email,
    this.assignedTo,
    this.title,
    this.description,
    required this.syncVersion,
    required this.isDeleted,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || salutation != null) {
      map['salutation'] = Variable<String>(salutation);
    }
    if (!nullToAbsent || accountName != null) {
      map['account_name'] = Variable<String>(accountName);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<String>(assignedTo);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      salutation: salutation == null && nullToAbsent
          ? const Value.absent()
          : Value(salutation),
      accountName: accountName == null && nullToAbsent
          ? const Value.absent()
          : Value(accountName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory ContactTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactTableData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      salutation: serializer.fromJson<String?>(json['salutation']),
      accountName: serializer.fromJson<String?>(json['accountName']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      assignedTo: serializer.fromJson<String?>(json['assignedTo']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'salutation': serializer.toJson<String?>(salutation),
      'accountName': serializer.toJson<String?>(accountName),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'assignedTo': serializer.toJson<String?>(assignedTo),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  ContactTableData copyWith({
    String? id,
    String? businessId,
    String? name,
    Value<String?> firstName = const Value.absent(),
    Value<String?> lastName = const Value.absent(),
    Value<String?> salutation = const Value.absent(),
    Value<String?> accountName = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> assignedTo = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? syncVersion,
    bool? isDeleted,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? deviceId,
    String? syncStatus,
    String? createdAt,
  }) => ContactTableData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    firstName: firstName.present ? firstName.value : this.firstName,
    lastName: lastName.present ? lastName.value : this.lastName,
    salutation: salutation.present ? salutation.value : this.salutation,
    accountName: accountName.present ? accountName.value : this.accountName,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  ContactTableData copyWithCompanion(ContactsCompanion data) {
    return ContactTableData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      salutation: data.salutation.present
          ? data.salutation.value
          : this.salutation,
      accountName: data.accountName.present
          ? data.accountName.value
          : this.accountName,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactTableData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('salutation: $salutation, ')
          ..write('accountName: $accountName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    name,
    firstName,
    lastName,
    salutation,
    accountName,
    phone,
    email,
    assignedTo,
    title,
    description,
    syncVersion,
    isDeleted,
    updatedAt,
    deletedAt,
    deviceId,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactTableData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.salutation == this.salutation &&
          other.accountName == this.accountName &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.assignedTo == this.assignedTo &&
          other.title == this.title &&
          other.description == this.description &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class ContactsCompanion extends UpdateCompanion<ContactTableData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<String?> salutation;
  final Value<String?> accountName;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> assignedTo;
  final Value<String?> title;
  final Value<String?> description;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> deviceId;
  final Value<String> syncStatus;
  final Value<String> createdAt;
  final Value<int> rowid;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.salutation = const Value.absent(),
    this.accountName = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.salutation = const Value.absent(),
    this.accountName = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       name = Value(name),
       updatedAt = Value(updatedAt),
       createdAt = Value(createdAt);
  static Insertable<ContactTableData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? salutation,
    Expression<String>? accountName,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? assignedTo,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? syncStatus,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (salutation != null) 'salutation': salutation,
      if (accountName != null) 'account_name': accountName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? name,
    Value<String?>? firstName,
    Value<String?>? lastName,
    Value<String?>? salutation,
    Value<String?>? accountName,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? assignedTo,
    Value<String?>? title,
    Value<String?>? description,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? syncStatus,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      salutation: salutation ?? this.salutation,
      accountName: accountName ?? this.accountName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      assignedTo: assignedTo ?? this.assignedTo,
      title: title ?? this.title,
      description: description ?? this.description,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (salutation.present) {
      map['salutation'] = Variable<String>(salutation.value);
    }
    if (accountName.present) {
      map['account_name'] = Variable<String>(accountName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('salutation: $salutation, ')
          ..write('accountName: $accountName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactActivitiesTable extends ContactActivities
    with TableInfo<$ContactActivitiesTable, ContactActivityTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedByMeta = const VerificationMeta(
    'addedBy',
  );
  @override
  late final GeneratedColumn<String> addedBy = GeneratedColumn<String>(
    'added_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    businessId,
    type,
    notes,
    addedBy,
    syncVersion,
    isDeleted,
    updatedAt,
    deletedAt,
    deviceId,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactActivityTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('added_by')) {
      context.handle(
        _addedByMeta,
        addedBy.isAcceptableOrUnknown(data['added_by']!, _addedByMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactActivityTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactActivityTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      addedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_by'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ContactActivitiesTable createAlias(String alias) {
    return $ContactActivitiesTable(attachedDatabase, alias);
  }
}

class ContactActivityTableData extends DataClass
    implements Insertable<ContactActivityTableData> {
  final String id;
  final String contactId;
  final String businessId;
  final String type;
  final String? notes;
  final String? addedBy;
  final int syncVersion;
  final bool isDeleted;
  final String updatedAt;
  final String? deletedAt;
  final String deviceId;
  final String syncStatus;
  final String createdAt;
  const ContactActivityTableData({
    required this.id,
    required this.contactId,
    required this.businessId,
    required this.type,
    this.notes,
    this.addedBy,
    required this.syncVersion,
    required this.isDeleted,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['contact_id'] = Variable<String>(contactId);
    map['business_id'] = Variable<String>(businessId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || addedBy != null) {
      map['added_by'] = Variable<String>(addedBy);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ContactActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ContactActivitiesCompanion(
      id: Value(id),
      contactId: Value(contactId),
      businessId: Value(businessId),
      type: Value(type),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      addedBy: addedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(addedBy),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory ContactActivityTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactActivityTableData(
      id: serializer.fromJson<String>(json['id']),
      contactId: serializer.fromJson<String>(json['contactId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      type: serializer.fromJson<String>(json['type']),
      notes: serializer.fromJson<String?>(json['notes']),
      addedBy: serializer.fromJson<String?>(json['addedBy']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contactId': serializer.toJson<String>(contactId),
      'businessId': serializer.toJson<String>(businessId),
      'type': serializer.toJson<String>(type),
      'notes': serializer.toJson<String?>(notes),
      'addedBy': serializer.toJson<String?>(addedBy),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  ContactActivityTableData copyWith({
    String? id,
    String? contactId,
    String? businessId,
    String? type,
    Value<String?> notes = const Value.absent(),
    Value<String?> addedBy = const Value.absent(),
    int? syncVersion,
    bool? isDeleted,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? deviceId,
    String? syncStatus,
    String? createdAt,
  }) => ContactActivityTableData(
    id: id ?? this.id,
    contactId: contactId ?? this.contactId,
    businessId: businessId ?? this.businessId,
    type: type ?? this.type,
    notes: notes.present ? notes.value : this.notes,
    addedBy: addedBy.present ? addedBy.value : this.addedBy,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  ContactActivityTableData copyWithCompanion(ContactActivitiesCompanion data) {
    return ContactActivityTableData(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      type: data.type.present ? data.type.value : this.type,
      notes: data.notes.present ? data.notes.value : this.notes,
      addedBy: data.addedBy.present ? data.addedBy.value : this.addedBy,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactActivityTableData(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('businessId: $businessId, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('addedBy: $addedBy, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contactId,
    businessId,
    type,
    notes,
    addedBy,
    syncVersion,
    isDeleted,
    updatedAt,
    deletedAt,
    deviceId,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactActivityTableData &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.businessId == this.businessId &&
          other.type == this.type &&
          other.notes == this.notes &&
          other.addedBy == this.addedBy &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class ContactActivitiesCompanion
    extends UpdateCompanion<ContactActivityTableData> {
  final Value<String> id;
  final Value<String> contactId;
  final Value<String> businessId;
  final Value<String> type;
  final Value<String?> notes;
  final Value<String?> addedBy;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> deviceId;
  final Value<String> syncStatus;
  final Value<String> createdAt;
  final Value<int> rowid;
  const ContactActivitiesCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.type = const Value.absent(),
    this.notes = const Value.absent(),
    this.addedBy = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactActivitiesCompanion.insert({
    required String id,
    required String contactId,
    required String businessId,
    required String type,
    this.notes = const Value.absent(),
    this.addedBy = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contactId = Value(contactId),
       businessId = Value(businessId),
       type = Value(type),
       updatedAt = Value(updatedAt),
       createdAt = Value(createdAt);
  static Insertable<ContactActivityTableData> custom({
    Expression<String>? id,
    Expression<String>? contactId,
    Expression<String>? businessId,
    Expression<String>? type,
    Expression<String>? notes,
    Expression<String>? addedBy,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? syncStatus,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (businessId != null) 'business_id': businessId,
      if (type != null) 'type': type,
      if (notes != null) 'notes': notes,
      if (addedBy != null) 'added_by': addedBy,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? contactId,
    Value<String>? businessId,
    Value<String>? type,
    Value<String?>? notes,
    Value<String?>? addedBy,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? syncStatus,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return ContactActivitiesCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      businessId: businessId ?? this.businessId,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      addedBy: addedBy ?? this.addedBy,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (addedBy.present) {
      map['added_by'] = Variable<String>(addedBy.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('businessId: $businessId, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('addedBy: $addedBy, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DealsTable extends Deals with TableInfo<$DealsTable, DealTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountNameMeta = const VerificationMeta(
    'accountName',
  );
  @override
  late final GeneratedColumn<String> accountName = GeneratedColumn<String>(
    'account_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
    'assigned_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expectedCloseDateMeta = const VerificationMeta(
    'expectedCloseDate',
  );
  @override
  late final GeneratedColumn<String> expectedCloseDate =
      GeneratedColumn<String>(
        'expected_close_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    stage,
    accountName,
    assignedTo,
    amount,
    expectedCloseDate,
    description,
    syncVersion,
    isDeleted,
    updatedAt,
    deletedAt,
    deviceId,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DealTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('account_name')) {
      context.handle(
        _accountNameMeta,
        accountName.isAcceptableOrUnknown(
          data['account_name']!,
          _accountNameMeta,
        ),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('expected_close_date')) {
      context.handle(
        _expectedCloseDateMeta,
        expectedCloseDate.isAcceptableOrUnknown(
          data['expected_close_date']!,
          _expectedCloseDateMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DealTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DealTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      accountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_name'],
      ),
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      expectedCloseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_close_date'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DealsTable createAlias(String alias) {
    return $DealsTable(attachedDatabase, alias);
  }
}

class DealTableData extends DataClass implements Insertable<DealTableData> {
  final String id;
  final String businessId;
  final String name;
  final String stage;
  final String? accountName;
  final String? assignedTo;
  final double amount;
  final String? expectedCloseDate;
  final String? description;
  final int syncVersion;
  final bool isDeleted;
  final String updatedAt;
  final String? deletedAt;
  final String deviceId;
  final String syncStatus;
  final String createdAt;
  const DealTableData({
    required this.id,
    required this.businessId,
    required this.name,
    required this.stage,
    this.accountName,
    this.assignedTo,
    required this.amount,
    this.expectedCloseDate,
    this.description,
    required this.syncVersion,
    required this.isDeleted,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    map['stage'] = Variable<String>(stage);
    if (!nullToAbsent || accountName != null) {
      map['account_name'] = Variable<String>(accountName);
    }
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<String>(assignedTo);
    }
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || expectedCloseDate != null) {
      map['expected_close_date'] = Variable<String>(expectedCloseDate);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  DealsCompanion toCompanion(bool nullToAbsent) {
    return DealsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      stage: Value(stage),
      accountName: accountName == null && nullToAbsent
          ? const Value.absent()
          : Value(accountName),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      amount: Value(amount),
      expectedCloseDate: expectedCloseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCloseDate),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory DealTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DealTableData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      stage: serializer.fromJson<String>(json['stage']),
      accountName: serializer.fromJson<String?>(json['accountName']),
      assignedTo: serializer.fromJson<String?>(json['assignedTo']),
      amount: serializer.fromJson<double>(json['amount']),
      expectedCloseDate: serializer.fromJson<String?>(
        json['expectedCloseDate'],
      ),
      description: serializer.fromJson<String?>(json['description']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'stage': serializer.toJson<String>(stage),
      'accountName': serializer.toJson<String?>(accountName),
      'assignedTo': serializer.toJson<String?>(assignedTo),
      'amount': serializer.toJson<double>(amount),
      'expectedCloseDate': serializer.toJson<String?>(expectedCloseDate),
      'description': serializer.toJson<String?>(description),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  DealTableData copyWith({
    String? id,
    String? businessId,
    String? name,
    String? stage,
    Value<String?> accountName = const Value.absent(),
    Value<String?> assignedTo = const Value.absent(),
    double? amount,
    Value<String?> expectedCloseDate = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? syncVersion,
    bool? isDeleted,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? deviceId,
    String? syncStatus,
    String? createdAt,
  }) => DealTableData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    stage: stage ?? this.stage,
    accountName: accountName.present ? accountName.value : this.accountName,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
    amount: amount ?? this.amount,
    expectedCloseDate: expectedCloseDate.present
        ? expectedCloseDate.value
        : this.expectedCloseDate,
    description: description.present ? description.value : this.description,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  DealTableData copyWithCompanion(DealsCompanion data) {
    return DealTableData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      stage: data.stage.present ? data.stage.value : this.stage,
      accountName: data.accountName.present
          ? data.accountName.value
          : this.accountName,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      amount: data.amount.present ? data.amount.value : this.amount,
      expectedCloseDate: data.expectedCloseDate.present
          ? data.expectedCloseDate.value
          : this.expectedCloseDate,
      description: data.description.present
          ? data.description.value
          : this.description,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DealTableData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('stage: $stage, ')
          ..write('accountName: $accountName, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('amount: $amount, ')
          ..write('expectedCloseDate: $expectedCloseDate, ')
          ..write('description: $description, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    name,
    stage,
    accountName,
    assignedTo,
    amount,
    expectedCloseDate,
    description,
    syncVersion,
    isDeleted,
    updatedAt,
    deletedAt,
    deviceId,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DealTableData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.stage == this.stage &&
          other.accountName == this.accountName &&
          other.assignedTo == this.assignedTo &&
          other.amount == this.amount &&
          other.expectedCloseDate == this.expectedCloseDate &&
          other.description == this.description &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class DealsCompanion extends UpdateCompanion<DealTableData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String> stage;
  final Value<String?> accountName;
  final Value<String?> assignedTo;
  final Value<double> amount;
  final Value<String?> expectedCloseDate;
  final Value<String?> description;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> deviceId;
  final Value<String> syncStatus;
  final Value<String> createdAt;
  final Value<int> rowid;
  const DealsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.stage = const Value.absent(),
    this.accountName = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.amount = const Value.absent(),
    this.expectedCloseDate = const Value.absent(),
    this.description = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DealsCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    required String stage,
    this.accountName = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.amount = const Value.absent(),
    this.expectedCloseDate = const Value.absent(),
    this.description = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       name = Value(name),
       stage = Value(stage),
       updatedAt = Value(updatedAt),
       createdAt = Value(createdAt);
  static Insertable<DealTableData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? stage,
    Expression<String>? accountName,
    Expression<String>? assignedTo,
    Expression<double>? amount,
    Expression<String>? expectedCloseDate,
    Expression<String>? description,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? syncStatus,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (stage != null) 'stage': stage,
      if (accountName != null) 'account_name': accountName,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (amount != null) 'amount': amount,
      if (expectedCloseDate != null) 'expected_close_date': expectedCloseDate,
      if (description != null) 'description': description,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DealsCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? name,
    Value<String>? stage,
    Value<String?>? accountName,
    Value<String?>? assignedTo,
    Value<double>? amount,
    Value<String?>? expectedCloseDate,
    Value<String?>? description,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? syncStatus,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return DealsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      accountName: accountName ?? this.accountName,
      assignedTo: assignedTo ?? this.assignedTo,
      amount: amount ?? this.amount,
      expectedCloseDate: expectedCloseDate ?? this.expectedCloseDate,
      description: description ?? this.description,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (accountName.present) {
      map['account_name'] = Variable<String>(accountName.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (expectedCloseDate.present) {
      map['expected_close_date'] = Variable<String>(expectedCloseDate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DealsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('stage: $stage, ')
          ..write('accountName: $accountName, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('amount: $amount, ')
          ..write('expectedCloseDate: $expectedCloseDate, ')
          ..write('description: $description, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commandIdMeta = const VerificationMeta(
    'commandId',
  );
  @override
  late final GeneratedColumn<String> commandId = GeneratedColumn<String>(
    'command_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mutationId,
    kind,
    entityType,
    entityId,
    operation,
    payload,
    businessId,
    deviceId,
    commandId,
    status,
    priority,
    attemptCount,
    createdAt,
    scheduledAt,
    lastAttemptAt,
    nextRetryAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('command_id')) {
      context.handle(
        _commandIdMeta,
        commandId.isAcceptableOrUnknown(data['command_id']!, _commandIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {mutationId},
  ];
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      commandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final String mutationId;
  final String kind;
  final String entityType;
  final String? entityId;
  final String operation;
  final String payload;
  final String businessId;
  final String? deviceId;
  final String? commandId;
  final String status;
  final int priority;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? lastAttemptAt;
  final DateTime? nextRetryAt;
  final String? lastError;
  const SyncQueueData({
    required this.id,
    required this.mutationId,
    required this.kind,
    required this.entityType,
    this.entityId,
    required this.operation,
    required this.payload,
    required this.businessId,
    this.deviceId,
    this.commandId,
    required this.status,
    required this.priority,
    required this.attemptCount,
    required this.createdAt,
    this.scheduledAt,
    this.lastAttemptAt,
    this.nextRetryAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mutation_id'] = Variable<String>(mutationId);
    map['kind'] = Variable<String>(kind);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['business_id'] = Variable<String>(businessId);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || commandId != null) {
      map['command_id'] = Variable<String>(commandId);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<int>(priority);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      mutationId: Value(mutationId),
      kind: Value(kind),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      businessId: Value(businessId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      commandId: commandId == null && nullToAbsent
          ? const Value.absent()
          : Value(commandId),
      status: Value(status),
      priority: Value(priority),
      attemptCount: Value(attemptCount),
      createdAt: Value(createdAt),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
      kind: serializer.fromJson<String>(json['kind']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      businessId: serializer.fromJson<String>(json['businessId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      commandId: serializer.fromJson<String?>(json['commandId']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mutationId': serializer.toJson<String>(mutationId),
      'kind': serializer.toJson<String>(kind),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'businessId': serializer.toJson<String>(businessId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'commandId': serializer.toJson<String?>(commandId),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<int>(priority),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueData copyWith({
    String? id,
    String? mutationId,
    String? kind,
    String? entityType,
    Value<String?> entityId = const Value.absent(),
    String? operation,
    String? payload,
    String? businessId,
    Value<String?> deviceId = const Value.absent(),
    Value<String?> commandId = const Value.absent(),
    String? status,
    int? priority,
    int? attemptCount,
    DateTime? createdAt,
    Value<DateTime?> scheduledAt = const Value.absent(),
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<DateTime?> nextRetryAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    mutationId: mutationId ?? this.mutationId,
    kind: kind ?? this.kind,
    entityType: entityType ?? this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    businessId: businessId ?? this.businessId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    commandId: commandId.present ? commandId.value : this.commandId,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    attemptCount: attemptCount ?? this.attemptCount,
    createdAt: createdAt ?? this.createdAt,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      kind: data.kind.present ? data.kind.value : this.kind,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      commandId: data.commandId.present ? data.commandId.value : this.commandId,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('mutationId: $mutationId, ')
          ..write('kind: $kind, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('commandId: $commandId, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mutationId,
    kind,
    entityType,
    entityId,
    operation,
    payload,
    businessId,
    deviceId,
    commandId,
    status,
    priority,
    attemptCount,
    createdAt,
    scheduledAt,
    lastAttemptAt,
    nextRetryAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.mutationId == this.mutationId &&
          other.kind == this.kind &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.businessId == this.businessId &&
          other.deviceId == this.deviceId &&
          other.commandId == this.commandId &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.attemptCount == this.attemptCount &&
          other.createdAt == this.createdAt &&
          other.scheduledAt == this.scheduledAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<String> mutationId;
  final Value<String> kind;
  final Value<String> entityType;
  final Value<String?> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> businessId;
  final Value<String?> deviceId;
  final Value<String?> commandId;
  final Value<String> status;
  final Value<int> priority;
  final Value<int> attemptCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> scheduledAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime?> nextRetryAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.kind = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.businessId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.commandId = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String mutationId,
    required String kind,
    required String entityType,
    this.entityId = const Value.absent(),
    required String operation,
    required String payload,
    required String businessId,
    this.deviceId = const Value.absent(),
    this.commandId = const Value.absent(),
    required String status,
    this.priority = const Value.absent(),
    this.attemptCount = const Value.absent(),
    required DateTime createdAt,
    this.scheduledAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mutationId = Value(mutationId),
       kind = Value(kind),
       entityType = Value(entityType),
       operation = Value(operation),
       payload = Value(payload),
       businessId = Value(businessId),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<String>? mutationId,
    Expression<String>? kind,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? businessId,
    Expression<String>? deviceId,
    Expression<String>? commandId,
    Expression<String>? status,
    Expression<int>? priority,
    Expression<int>? attemptCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mutationId != null) 'mutation_id': mutationId,
      if (kind != null) 'kind': kind,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (businessId != null) 'business_id': businessId,
      if (deviceId != null) 'device_id': deviceId,
      if (commandId != null) 'command_id': commandId,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (createdAt != null) 'created_at': createdAt,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? mutationId,
    Value<String>? kind,
    Value<String>? entityType,
    Value<String?>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<String>? businessId,
    Value<String?>? deviceId,
    Value<String?>? commandId,
    Value<String>? status,
    Value<int>? priority,
    Value<int>? attemptCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? scheduledAt,
    Value<DateTime?>? lastAttemptAt,
    Value<DateTime?>? nextRetryAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      mutationId: mutationId ?? this.mutationId,
      kind: kind ?? this.kind,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      businessId: businessId ?? this.businessId,
      deviceId: deviceId ?? this.deviceId,
      commandId: commandId ?? this.commandId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (commandId.present) {
      map['command_id'] = Variable<String>(commandId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('mutationId: $mutationId, ')
          ..write('kind: $kind, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('commandId: $commandId, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesLocalTable extends CategoriesLocal
    with TableInfo<$CategoriesLocalTable, CategoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    itemCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
    );
  }

  @override
  $CategoriesLocalTable createAlias(String alias) {
    return $CategoriesLocalTable(attachedDatabase, alias);
  }
}

class CategoryTableData extends DataClass
    implements Insertable<CategoryTableData> {
  final String id;
  final String businessId;
  final String name;
  final int syncVersion;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;

  /// Denormalized; not pushed to server.
  final int itemCount;
  const CategoryTableData({
    required this.id,
    required this.businessId,
    required this.name,
    required this.syncVersion,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deviceId,
    required this.itemCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['item_count'] = Variable<int>(itemCount);
    return map;
  }

  CategoriesLocalCompanion toCompanion(bool nullToAbsent) {
    return CategoriesLocalCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      itemCount: Value(itemCount),
    );
  }

  factory CategoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryTableData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
      'itemCount': serializer.toJson<int>(itemCount),
    };
  }

  CategoryTableData copyWith({
    String? id,
    String? businessId,
    String? name,
    int? syncVersion,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    int? itemCount,
  }) => CategoryTableData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    itemCount: itemCount ?? this.itemCount,
  );
  CategoryTableData copyWithCompanion(CategoriesLocalCompanion data) {
    return CategoryTableData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryTableData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('itemCount: $itemCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    name,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    itemCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryTableData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.itemCount == this.itemCount);
}

class CategoriesLocalCompanion extends UpdateCompanion<CategoryTableData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> itemCount;
  final Value<int> rowid;
  const CategoriesLocalCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesLocalCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CategoryTableData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? itemCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (itemCount != null) 'item_count': itemCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? name,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? itemCount,
    Value<int>? rowid,
  }) {
    return CategoriesLocalCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      itemCount: itemCount ?? this.itemCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesLocalCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('itemCount: $itemCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartiesLocalTable extends PartiesLocal
    with TableInfo<$PartiesLocalTable, PartyTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legalNameMeta = const VerificationMeta(
    'legalName',
  );
  @override
  late final GeneratedColumn<String> legalName = GeneratedColumn<String>(
    'legal_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mobileMeta = const VerificationMeta('mobile');
  @override
  late final GeneratedColumn<String> mobile = GeneratedColumn<String>(
    'mobile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partyGroupMeta = const VerificationMeta(
    'partyGroup',
  );
  @override
  late final GeneratedColumn<String> partyGroup = GeneratedColumn<String>(
    'party_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaCodeMeta = const VerificationMeta(
    'areaCode',
  );
  @override
  late final GeneratedColumn<String> areaCode = GeneratedColumn<String>(
    'area_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partyTypeMeta = const VerificationMeta(
    'partyType',
  );
  @override
  late final GeneratedColumn<String> partyType = GeneratedColumn<String>(
    'party_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('customer'),
  );
  static const VerificationMeta _partyCategoryMeta = const VerificationMeta(
    'partyCategory',
  );
  @override
  late final GeneratedColumn<String> partyCategory = GeneratedColumn<String>(
    'party_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricingTierMeta = const VerificationMeta(
    'pricingTier',
  );
  @override
  late final GeneratedColumn<String> pricingTier = GeneratedColumn<String>(
    'pricing_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tier_1'),
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateCodeMeta = const VerificationMeta(
    'stateCode',
  );
  @override
  late final GeneratedColumn<String> stateCode = GeneratedColumn<String>(
    'state_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<String> creditLimit = GeneratedColumn<String>(
    'credit_limit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<String> openingBalance = GeneratedColumn<String>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _hiddenLedgerBalanceMeta =
      const VerificationMeta('hiddenLedgerBalance');
  @override
  late final GeneratedColumn<String> hiddenLedgerBalance =
      GeneratedColumn<String>(
        'hidden_ledger_balance',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('0'),
      );
  static const VerificationMeta _profileImageUrlMeta = const VerificationMeta(
    'profileImageUrl',
  );
  @override
  late final GeneratedColumn<String> profileImageUrl = GeneratedColumn<String>(
    'profile_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileMediaAssetIdMeta =
      const VerificationMeta('profileMediaAssetId');
  @override
  late final GeneratedColumn<String> profileMediaAssetId =
      GeneratedColumn<String>(
        'profile_media_asset_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _connectedSinceMeta = const VerificationMeta(
    'connectedSince',
  );
  @override
  late final GeneratedColumn<String> connectedSince = GeneratedColumn<String>(
    'connected_since',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    legalName,
    alias,
    mobile,
    email,
    partyGroup,
    areaCode,
    partyType,
    partyCategory,
    pricingTier,
    gstin,
    stateCode,
    areaId,
    creditLimit,
    openingBalance,
    hiddenLedgerBalance,
    profileImageUrl,
    profileMediaAssetId,
    connectedSince,
    notes,
    isActive,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartyTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('legal_name')) {
      context.handle(
        _legalNameMeta,
        legalName.isAcceptableOrUnknown(data['legal_name']!, _legalNameMeta),
      );
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    }
    if (data.containsKey('mobile')) {
      context.handle(
        _mobileMeta,
        mobile.isAcceptableOrUnknown(data['mobile']!, _mobileMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('party_group')) {
      context.handle(
        _partyGroupMeta,
        partyGroup.isAcceptableOrUnknown(data['party_group']!, _partyGroupMeta),
      );
    }
    if (data.containsKey('area_code')) {
      context.handle(
        _areaCodeMeta,
        areaCode.isAcceptableOrUnknown(data['area_code']!, _areaCodeMeta),
      );
    }
    if (data.containsKey('party_type')) {
      context.handle(
        _partyTypeMeta,
        partyType.isAcceptableOrUnknown(data['party_type']!, _partyTypeMeta),
      );
    }
    if (data.containsKey('party_category')) {
      context.handle(
        _partyCategoryMeta,
        partyCategory.isAcceptableOrUnknown(
          data['party_category']!,
          _partyCategoryMeta,
        ),
      );
    }
    if (data.containsKey('pricing_tier')) {
      context.handle(
        _pricingTierMeta,
        pricingTier.isAcceptableOrUnknown(
          data['pricing_tier']!,
          _pricingTierMeta,
        ),
      );
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('state_code')) {
      context.handle(
        _stateCodeMeta,
        stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta),
      );
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('hidden_ledger_balance')) {
      context.handle(
        _hiddenLedgerBalanceMeta,
        hiddenLedgerBalance.isAcceptableOrUnknown(
          data['hidden_ledger_balance']!,
          _hiddenLedgerBalanceMeta,
        ),
      );
    }
    if (data.containsKey('profile_image_url')) {
      context.handle(
        _profileImageUrlMeta,
        profileImageUrl.isAcceptableOrUnknown(
          data['profile_image_url']!,
          _profileImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('profile_media_asset_id')) {
      context.handle(
        _profileMediaAssetIdMeta,
        profileMediaAssetId.isAcceptableOrUnknown(
          data['profile_media_asset_id']!,
          _profileMediaAssetIdMeta,
        ),
      );
    }
    if (data.containsKey('connected_since')) {
      context.handle(
        _connectedSinceMeta,
        connectedSince.isAcceptableOrUnknown(
          data['connected_since']!,
          _connectedSinceMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartyTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartyTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      legalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_name'],
      ),
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      ),
      mobile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      partyGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_group'],
      ),
      areaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_code'],
      ),
      partyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_type'],
      )!,
      partyCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_category'],
      ),
      pricingTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pricing_tier'],
      )!,
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      stateCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_code'],
      ),
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      ),
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credit_limit'],
      )!,
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening_balance'],
      )!,
      hiddenLedgerBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hidden_ledger_balance'],
      )!,
      profileImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_image_url'],
      ),
      profileMediaAssetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_media_asset_id'],
      ),
      connectedSince: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connected_since'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $PartiesLocalTable createAlias(String alias) {
    return $PartiesLocalTable(attachedDatabase, alias);
  }
}

class PartyTableData extends DataClass implements Insertable<PartyTableData> {
  final String id;
  final String businessId;
  final String name;
  final String? legalName;
  final String? alias;
  final String? mobile;
  final String? email;
  final String? partyGroup;
  final String? areaCode;
  final String partyType;
  final String? partyCategory;
  final String pricingTier;
  final String? gstin;
  final String? stateCode;
  final String? areaId;
  final String creditLimit;
  final String openingBalance;
  final String hiddenLedgerBalance;
  final String? profileImageUrl;
  final String? profileMediaAssetId;
  final String? connectedSince;
  final String? notes;
  final bool isActive;
  final int syncVersion;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  const PartyTableData({
    required this.id,
    required this.businessId,
    required this.name,
    this.legalName,
    this.alias,
    this.mobile,
    this.email,
    this.partyGroup,
    this.areaCode,
    required this.partyType,
    this.partyCategory,
    required this.pricingTier,
    this.gstin,
    this.stateCode,
    this.areaId,
    required this.creditLimit,
    required this.openingBalance,
    required this.hiddenLedgerBalance,
    this.profileImageUrl,
    this.profileMediaAssetId,
    this.connectedSince,
    this.notes,
    required this.isActive,
    required this.syncVersion,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || legalName != null) {
      map['legal_name'] = Variable<String>(legalName);
    }
    if (!nullToAbsent || alias != null) {
      map['alias'] = Variable<String>(alias);
    }
    if (!nullToAbsent || mobile != null) {
      map['mobile'] = Variable<String>(mobile);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || partyGroup != null) {
      map['party_group'] = Variable<String>(partyGroup);
    }
    if (!nullToAbsent || areaCode != null) {
      map['area_code'] = Variable<String>(areaCode);
    }
    map['party_type'] = Variable<String>(partyType);
    if (!nullToAbsent || partyCategory != null) {
      map['party_category'] = Variable<String>(partyCategory);
    }
    map['pricing_tier'] = Variable<String>(pricingTier);
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || stateCode != null) {
      map['state_code'] = Variable<String>(stateCode);
    }
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<String>(areaId);
    }
    map['credit_limit'] = Variable<String>(creditLimit);
    map['opening_balance'] = Variable<String>(openingBalance);
    map['hidden_ledger_balance'] = Variable<String>(hiddenLedgerBalance);
    if (!nullToAbsent || profileImageUrl != null) {
      map['profile_image_url'] = Variable<String>(profileImageUrl);
    }
    if (!nullToAbsent || profileMediaAssetId != null) {
      map['profile_media_asset_id'] = Variable<String>(profileMediaAssetId);
    }
    if (!nullToAbsent || connectedSince != null) {
      map['connected_since'] = Variable<String>(connectedSince);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  PartiesLocalCompanion toCompanion(bool nullToAbsent) {
    return PartiesLocalCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      legalName: legalName == null && nullToAbsent
          ? const Value.absent()
          : Value(legalName),
      alias: alias == null && nullToAbsent
          ? const Value.absent()
          : Value(alias),
      mobile: mobile == null && nullToAbsent
          ? const Value.absent()
          : Value(mobile),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      partyGroup: partyGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(partyGroup),
      areaCode: areaCode == null && nullToAbsent
          ? const Value.absent()
          : Value(areaCode),
      partyType: Value(partyType),
      partyCategory: partyCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(partyCategory),
      pricingTier: Value(pricingTier),
      gstin: gstin == null && nullToAbsent
          ? const Value.absent()
          : Value(gstin),
      stateCode: stateCode == null && nullToAbsent
          ? const Value.absent()
          : Value(stateCode),
      areaId: areaId == null && nullToAbsent
          ? const Value.absent()
          : Value(areaId),
      creditLimit: Value(creditLimit),
      openingBalance: Value(openingBalance),
      hiddenLedgerBalance: Value(hiddenLedgerBalance),
      profileImageUrl: profileImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(profileImageUrl),
      profileMediaAssetId: profileMediaAssetId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileMediaAssetId),
      connectedSince: connectedSince == null && nullToAbsent
          ? const Value.absent()
          : Value(connectedSince),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory PartyTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartyTableData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      legalName: serializer.fromJson<String?>(json['legalName']),
      alias: serializer.fromJson<String?>(json['alias']),
      mobile: serializer.fromJson<String?>(json['mobile']),
      email: serializer.fromJson<String?>(json['email']),
      partyGroup: serializer.fromJson<String?>(json['partyGroup']),
      areaCode: serializer.fromJson<String?>(json['areaCode']),
      partyType: serializer.fromJson<String>(json['partyType']),
      partyCategory: serializer.fromJson<String?>(json['partyCategory']),
      pricingTier: serializer.fromJson<String>(json['pricingTier']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      stateCode: serializer.fromJson<String?>(json['stateCode']),
      areaId: serializer.fromJson<String?>(json['areaId']),
      creditLimit: serializer.fromJson<String>(json['creditLimit']),
      openingBalance: serializer.fromJson<String>(json['openingBalance']),
      hiddenLedgerBalance: serializer.fromJson<String>(
        json['hiddenLedgerBalance'],
      ),
      profileImageUrl: serializer.fromJson<String?>(json['profileImageUrl']),
      profileMediaAssetId: serializer.fromJson<String?>(
        json['profileMediaAssetId'],
      ),
      connectedSince: serializer.fromJson<String?>(json['connectedSince']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'legalName': serializer.toJson<String?>(legalName),
      'alias': serializer.toJson<String?>(alias),
      'mobile': serializer.toJson<String?>(mobile),
      'email': serializer.toJson<String?>(email),
      'partyGroup': serializer.toJson<String?>(partyGroup),
      'areaCode': serializer.toJson<String?>(areaCode),
      'partyType': serializer.toJson<String>(partyType),
      'partyCategory': serializer.toJson<String?>(partyCategory),
      'pricingTier': serializer.toJson<String>(pricingTier),
      'gstin': serializer.toJson<String?>(gstin),
      'stateCode': serializer.toJson<String?>(stateCode),
      'areaId': serializer.toJson<String?>(areaId),
      'creditLimit': serializer.toJson<String>(creditLimit),
      'openingBalance': serializer.toJson<String>(openingBalance),
      'hiddenLedgerBalance': serializer.toJson<String>(hiddenLedgerBalance),
      'profileImageUrl': serializer.toJson<String?>(profileImageUrl),
      'profileMediaAssetId': serializer.toJson<String?>(profileMediaAssetId),
      'connectedSince': serializer.toJson<String?>(connectedSince),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  PartyTableData copyWith({
    String? id,
    String? businessId,
    String? name,
    Value<String?> legalName = const Value.absent(),
    Value<String?> alias = const Value.absent(),
    Value<String?> mobile = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> partyGroup = const Value.absent(),
    Value<String?> areaCode = const Value.absent(),
    String? partyType,
    Value<String?> partyCategory = const Value.absent(),
    String? pricingTier,
    Value<String?> gstin = const Value.absent(),
    Value<String?> stateCode = const Value.absent(),
    Value<String?> areaId = const Value.absent(),
    String? creditLimit,
    String? openingBalance,
    String? hiddenLedgerBalance,
    Value<String?> profileImageUrl = const Value.absent(),
    Value<String?> profileMediaAssetId = const Value.absent(),
    Value<String?> connectedSince = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    int? syncVersion,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
  }) => PartyTableData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    legalName: legalName.present ? legalName.value : this.legalName,
    alias: alias.present ? alias.value : this.alias,
    mobile: mobile.present ? mobile.value : this.mobile,
    email: email.present ? email.value : this.email,
    partyGroup: partyGroup.present ? partyGroup.value : this.partyGroup,
    areaCode: areaCode.present ? areaCode.value : this.areaCode,
    partyType: partyType ?? this.partyType,
    partyCategory: partyCategory.present
        ? partyCategory.value
        : this.partyCategory,
    pricingTier: pricingTier ?? this.pricingTier,
    gstin: gstin.present ? gstin.value : this.gstin,
    stateCode: stateCode.present ? stateCode.value : this.stateCode,
    areaId: areaId.present ? areaId.value : this.areaId,
    creditLimit: creditLimit ?? this.creditLimit,
    openingBalance: openingBalance ?? this.openingBalance,
    hiddenLedgerBalance: hiddenLedgerBalance ?? this.hiddenLedgerBalance,
    profileImageUrl: profileImageUrl.present
        ? profileImageUrl.value
        : this.profileImageUrl,
    profileMediaAssetId: profileMediaAssetId.present
        ? profileMediaAssetId.value
        : this.profileMediaAssetId,
    connectedSince: connectedSince.present
        ? connectedSince.value
        : this.connectedSince,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  PartyTableData copyWithCompanion(PartiesLocalCompanion data) {
    return PartyTableData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      legalName: data.legalName.present ? data.legalName.value : this.legalName,
      alias: data.alias.present ? data.alias.value : this.alias,
      mobile: data.mobile.present ? data.mobile.value : this.mobile,
      email: data.email.present ? data.email.value : this.email,
      partyGroup: data.partyGroup.present
          ? data.partyGroup.value
          : this.partyGroup,
      areaCode: data.areaCode.present ? data.areaCode.value : this.areaCode,
      partyType: data.partyType.present ? data.partyType.value : this.partyType,
      partyCategory: data.partyCategory.present
          ? data.partyCategory.value
          : this.partyCategory,
      pricingTier: data.pricingTier.present
          ? data.pricingTier.value
          : this.pricingTier,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      hiddenLedgerBalance: data.hiddenLedgerBalance.present
          ? data.hiddenLedgerBalance.value
          : this.hiddenLedgerBalance,
      profileImageUrl: data.profileImageUrl.present
          ? data.profileImageUrl.value
          : this.profileImageUrl,
      profileMediaAssetId: data.profileMediaAssetId.present
          ? data.profileMediaAssetId.value
          : this.profileMediaAssetId,
      connectedSince: data.connectedSince.present
          ? data.connectedSince.value
          : this.connectedSince,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartyTableData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('legalName: $legalName, ')
          ..write('alias: $alias, ')
          ..write('mobile: $mobile, ')
          ..write('email: $email, ')
          ..write('partyGroup: $partyGroup, ')
          ..write('areaCode: $areaCode, ')
          ..write('partyType: $partyType, ')
          ..write('partyCategory: $partyCategory, ')
          ..write('pricingTier: $pricingTier, ')
          ..write('gstin: $gstin, ')
          ..write('stateCode: $stateCode, ')
          ..write('areaId: $areaId, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('hiddenLedgerBalance: $hiddenLedgerBalance, ')
          ..write('profileImageUrl: $profileImageUrl, ')
          ..write('profileMediaAssetId: $profileMediaAssetId, ')
          ..write('connectedSince: $connectedSince, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    businessId,
    name,
    legalName,
    alias,
    mobile,
    email,
    partyGroup,
    areaCode,
    partyType,
    partyCategory,
    pricingTier,
    gstin,
    stateCode,
    areaId,
    creditLimit,
    openingBalance,
    hiddenLedgerBalance,
    profileImageUrl,
    profileMediaAssetId,
    connectedSince,
    notes,
    isActive,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyTableData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.legalName == this.legalName &&
          other.alias == this.alias &&
          other.mobile == this.mobile &&
          other.email == this.email &&
          other.partyGroup == this.partyGroup &&
          other.areaCode == this.areaCode &&
          other.partyType == this.partyType &&
          other.partyCategory == this.partyCategory &&
          other.pricingTier == this.pricingTier &&
          other.gstin == this.gstin &&
          other.stateCode == this.stateCode &&
          other.areaId == this.areaId &&
          other.creditLimit == this.creditLimit &&
          other.openingBalance == this.openingBalance &&
          other.hiddenLedgerBalance == this.hiddenLedgerBalance &&
          other.profileImageUrl == this.profileImageUrl &&
          other.profileMediaAssetId == this.profileMediaAssetId &&
          other.connectedSince == this.connectedSince &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class PartiesLocalCompanion extends UpdateCompanion<PartyTableData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String?> legalName;
  final Value<String?> alias;
  final Value<String?> mobile;
  final Value<String?> email;
  final Value<String?> partyGroup;
  final Value<String?> areaCode;
  final Value<String> partyType;
  final Value<String?> partyCategory;
  final Value<String> pricingTier;
  final Value<String?> gstin;
  final Value<String?> stateCode;
  final Value<String?> areaId;
  final Value<String> creditLimit;
  final Value<String> openingBalance;
  final Value<String> hiddenLedgerBalance;
  final Value<String?> profileImageUrl;
  final Value<String?> profileMediaAssetId;
  final Value<String?> connectedSince;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const PartiesLocalCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.legalName = const Value.absent(),
    this.alias = const Value.absent(),
    this.mobile = const Value.absent(),
    this.email = const Value.absent(),
    this.partyGroup = const Value.absent(),
    this.areaCode = const Value.absent(),
    this.partyType = const Value.absent(),
    this.partyCategory = const Value.absent(),
    this.pricingTier = const Value.absent(),
    this.gstin = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.areaId = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.hiddenLedgerBalance = const Value.absent(),
    this.profileImageUrl = const Value.absent(),
    this.profileMediaAssetId = const Value.absent(),
    this.connectedSince = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesLocalCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    this.legalName = const Value.absent(),
    this.alias = const Value.absent(),
    this.mobile = const Value.absent(),
    this.email = const Value.absent(),
    this.partyGroup = const Value.absent(),
    this.areaCode = const Value.absent(),
    this.partyType = const Value.absent(),
    this.partyCategory = const Value.absent(),
    this.pricingTier = const Value.absent(),
    this.gstin = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.areaId = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.hiddenLedgerBalance = const Value.absent(),
    this.profileImageUrl = const Value.absent(),
    this.profileMediaAssetId = const Value.absent(),
    this.connectedSince = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PartyTableData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? legalName,
    Expression<String>? alias,
    Expression<String>? mobile,
    Expression<String>? email,
    Expression<String>? partyGroup,
    Expression<String>? areaCode,
    Expression<String>? partyType,
    Expression<String>? partyCategory,
    Expression<String>? pricingTier,
    Expression<String>? gstin,
    Expression<String>? stateCode,
    Expression<String>? areaId,
    Expression<String>? creditLimit,
    Expression<String>? openingBalance,
    Expression<String>? hiddenLedgerBalance,
    Expression<String>? profileImageUrl,
    Expression<String>? profileMediaAssetId,
    Expression<String>? connectedSince,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (legalName != null) 'legal_name': legalName,
      if (alias != null) 'alias': alias,
      if (mobile != null) 'mobile': mobile,
      if (email != null) 'email': email,
      if (partyGroup != null) 'party_group': partyGroup,
      if (areaCode != null) 'area_code': areaCode,
      if (partyType != null) 'party_type': partyType,
      if (partyCategory != null) 'party_category': partyCategory,
      if (pricingTier != null) 'pricing_tier': pricingTier,
      if (gstin != null) 'gstin': gstin,
      if (stateCode != null) 'state_code': stateCode,
      if (areaId != null) 'area_id': areaId,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (hiddenLedgerBalance != null)
        'hidden_ledger_balance': hiddenLedgerBalance,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (profileMediaAssetId != null)
        'profile_media_asset_id': profileMediaAssetId,
      if (connectedSince != null) 'connected_since': connectedSince,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? name,
    Value<String?>? legalName,
    Value<String?>? alias,
    Value<String?>? mobile,
    Value<String?>? email,
    Value<String?>? partyGroup,
    Value<String?>? areaCode,
    Value<String>? partyType,
    Value<String?>? partyCategory,
    Value<String>? pricingTier,
    Value<String?>? gstin,
    Value<String?>? stateCode,
    Value<String?>? areaId,
    Value<String>? creditLimit,
    Value<String>? openingBalance,
    Value<String>? hiddenLedgerBalance,
    Value<String?>? profileImageUrl,
    Value<String?>? profileMediaAssetId,
    Value<String?>? connectedSince,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return PartiesLocalCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      legalName: legalName ?? this.legalName,
      alias: alias ?? this.alias,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      partyGroup: partyGroup ?? this.partyGroup,
      areaCode: areaCode ?? this.areaCode,
      partyType: partyType ?? this.partyType,
      partyCategory: partyCategory ?? this.partyCategory,
      pricingTier: pricingTier ?? this.pricingTier,
      gstin: gstin ?? this.gstin,
      stateCode: stateCode ?? this.stateCode,
      areaId: areaId ?? this.areaId,
      creditLimit: creditLimit ?? this.creditLimit,
      openingBalance: openingBalance ?? this.openingBalance,
      hiddenLedgerBalance: hiddenLedgerBalance ?? this.hiddenLedgerBalance,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileMediaAssetId: profileMediaAssetId ?? this.profileMediaAssetId,
      connectedSince: connectedSince ?? this.connectedSince,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (legalName.present) {
      map['legal_name'] = Variable<String>(legalName.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (mobile.present) {
      map['mobile'] = Variable<String>(mobile.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (partyGroup.present) {
      map['party_group'] = Variable<String>(partyGroup.value);
    }
    if (areaCode.present) {
      map['area_code'] = Variable<String>(areaCode.value);
    }
    if (partyType.present) {
      map['party_type'] = Variable<String>(partyType.value);
    }
    if (partyCategory.present) {
      map['party_category'] = Variable<String>(partyCategory.value);
    }
    if (pricingTier.present) {
      map['pricing_tier'] = Variable<String>(pricingTier.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<String>(stateCode.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<String>(creditLimit.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<String>(openingBalance.value);
    }
    if (hiddenLedgerBalance.present) {
      map['hidden_ledger_balance'] = Variable<String>(
        hiddenLedgerBalance.value,
      );
    }
    if (profileImageUrl.present) {
      map['profile_image_url'] = Variable<String>(profileImageUrl.value);
    }
    if (profileMediaAssetId.present) {
      map['profile_media_asset_id'] = Variable<String>(
        profileMediaAssetId.value,
      );
    }
    if (connectedSince.present) {
      map['connected_since'] = Variable<String>(connectedSince.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesLocalCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('legalName: $legalName, ')
          ..write('alias: $alias, ')
          ..write('mobile: $mobile, ')
          ..write('email: $email, ')
          ..write('partyGroup: $partyGroup, ')
          ..write('areaCode: $areaCode, ')
          ..write('partyType: $partyType, ')
          ..write('partyCategory: $partyCategory, ')
          ..write('pricingTier: $pricingTier, ')
          ..write('gstin: $gstin, ')
          ..write('stateCode: $stateCode, ')
          ..write('areaId: $areaId, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('hiddenLedgerBalance: $hiddenLedgerBalance, ')
          ..write('profileImageUrl: $profileImageUrl, ')
          ..write('profileMediaAssetId: $profileMediaAssetId, ')
          ..write('connectedSince: $connectedSince, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsLocalTable extends ItemsLocal
    with TableInfo<$ItemsLocalTable, ItemTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchKeywordsMeta = const VerificationMeta(
    'searchKeywords',
  );
  @override
  late final GeneratedColumn<String> searchKeywords = GeneratedColumn<String>(
    'search_keywords',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('product'),
  );
  static const VerificationMeta _hasStockTrackingMeta = const VerificationMeta(
    'hasStockTracking',
  );
  @override
  late final GeneratedColumn<bool> hasStockTracking = GeneratedColumn<bool>(
    'has_stock_tracking',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_stock_tracking" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandIdMeta = const VerificationMeta(
    'brandId',
  );
  @override
  late final GeneratedColumn<String> brandId = GeneratedColumn<String>(
    'brand_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsnCodeMeta = const VerificationMeta(
    'hsnCode',
  );
  @override
  late final GeneratedColumn<String> hsnCode = GeneratedColumn<String>(
    'hsn_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseUnitMeta = const VerificationMeta(
    'baseUnit',
  );
  @override
  late final GeneratedColumn<String> baseUnit = GeneratedColumn<String>(
    'base_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('piece'),
  );
  static const VerificationMeta _mrpMeta = const VerificationMeta('mrp');
  @override
  late final GeneratedColumn<String> mrp = GeneratedColumn<String>(
    'mrp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMrpOnlyMeta = const VerificationMeta(
    'isMrpOnly',
  );
  @override
  late final GeneratedColumn<bool> isMrpOnly = GeneratedColumn<bool>(
    'is_mrp_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mrp_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _marketPriceMeta = const VerificationMeta(
    'marketPrice',
  );
  @override
  late final GeneratedColumn<String> marketPrice = GeneratedColumn<String>(
    'market_price',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salePriceMeta = const VerificationMeta(
    'salePrice',
  );
  @override
  late final GeneratedColumn<String> salePrice = GeneratedColumn<String>(
    'sale_price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<String> purchasePrice = GeneratedColumn<String>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _reorderLevelMeta = const VerificationMeta(
    'reorderLevel',
  );
  @override
  late final GeneratedColumn<String> reorderLevel = GeneratedColumn<String>(
    'reorder_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultTaxRateMeta = const VerificationMeta(
    'defaultTaxRate',
  );
  @override
  late final GeneratedColumn<String> defaultTaxRate = GeneratedColumn<String>(
    'default_tax_rate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryImageUrlMeta = const VerificationMeta(
    'primaryImageUrl',
  );
  @override
  late final GeneratedColumn<String> primaryImageUrl = GeneratedColumn<String>(
    'primary_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    shortName,
    alias,
    searchKeywords,
    description,
    itemType,
    hasStockTracking,
    categoryId,
    brandId,
    hsnCode,
    barcode,
    baseUnit,
    mrp,
    isMrpOnly,
    marketPrice,
    salePrice,
    purchasePrice,
    reorderLevel,
    defaultTaxRate,
    primaryImageUrl,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    }
    if (data.containsKey('search_keywords')) {
      context.handle(
        _searchKeywordsMeta,
        searchKeywords.isAcceptableOrUnknown(
          data['search_keywords']!,
          _searchKeywordsMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    }
    if (data.containsKey('has_stock_tracking')) {
      context.handle(
        _hasStockTrackingMeta,
        hasStockTracking.isAcceptableOrUnknown(
          data['has_stock_tracking']!,
          _hasStockTrackingMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('brand_id')) {
      context.handle(
        _brandIdMeta,
        brandId.isAcceptableOrUnknown(data['brand_id']!, _brandIdMeta),
      );
    }
    if (data.containsKey('hsn_code')) {
      context.handle(
        _hsnCodeMeta,
        hsnCode.isAcceptableOrUnknown(data['hsn_code']!, _hsnCodeMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('base_unit')) {
      context.handle(
        _baseUnitMeta,
        baseUnit.isAcceptableOrUnknown(data['base_unit']!, _baseUnitMeta),
      );
    }
    if (data.containsKey('mrp')) {
      context.handle(
        _mrpMeta,
        mrp.isAcceptableOrUnknown(data['mrp']!, _mrpMeta),
      );
    }
    if (data.containsKey('is_mrp_only')) {
      context.handle(
        _isMrpOnlyMeta,
        isMrpOnly.isAcceptableOrUnknown(data['is_mrp_only']!, _isMrpOnlyMeta),
      );
    }
    if (data.containsKey('market_price')) {
      context.handle(
        _marketPriceMeta,
        marketPrice.isAcceptableOrUnknown(
          data['market_price']!,
          _marketPriceMeta,
        ),
      );
    }
    if (data.containsKey('sale_price')) {
      context.handle(
        _salePriceMeta,
        salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
        _reorderLevelMeta,
        reorderLevel.isAcceptableOrUnknown(
          data['reorder_level']!,
          _reorderLevelMeta,
        ),
      );
    }
    if (data.containsKey('default_tax_rate')) {
      context.handle(
        _defaultTaxRateMeta,
        defaultTaxRate.isAcceptableOrUnknown(
          data['default_tax_rate']!,
          _defaultTaxRateMeta,
        ),
      );
    }
    if (data.containsKey('primary_image_url')) {
      context.handle(
        _primaryImageUrlMeta,
        primaryImageUrl.isAcceptableOrUnknown(
          data['primary_image_url']!,
          _primaryImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      ),
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      ),
      searchKeywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_keywords'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      hasStockTracking: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_stock_tracking'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      brandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_id'],
      ),
      hsnCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hsn_code'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      baseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_unit'],
      )!,
      mrp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mrp'],
      ),
      isMrpOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mrp_only'],
      )!,
      marketPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market_price'],
      ),
      salePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_price'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_price'],
      )!,
      reorderLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reorder_level'],
      ),
      defaultTaxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_tax_rate'],
      ),
      primaryImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_image_url'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $ItemsLocalTable createAlias(String alias) {
    return $ItemsLocalTable(attachedDatabase, alias);
  }
}

class ItemTableData extends DataClass implements Insertable<ItemTableData> {
  final String id;
  final String businessId;
  final String name;
  final String? shortName;
  final String? alias;
  final String? searchKeywords;
  final String? description;
  final String itemType;
  final bool hasStockTracking;
  final String? categoryId;
  final String? brandId;
  final String? hsnCode;
  final String? barcode;
  final String baseUnit;
  final String? mrp;
  final bool isMrpOnly;
  final String? marketPrice;
  final String salePrice;
  final String purchasePrice;
  final String? reorderLevel;
  final String? defaultTaxRate;
  final String? primaryImageUrl;
  final int syncVersion;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  const ItemTableData({
    required this.id,
    required this.businessId,
    required this.name,
    this.shortName,
    this.alias,
    this.searchKeywords,
    this.description,
    required this.itemType,
    required this.hasStockTracking,
    this.categoryId,
    this.brandId,
    this.hsnCode,
    this.barcode,
    required this.baseUnit,
    this.mrp,
    required this.isMrpOnly,
    this.marketPrice,
    required this.salePrice,
    required this.purchasePrice,
    this.reorderLevel,
    this.defaultTaxRate,
    this.primaryImageUrl,
    required this.syncVersion,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || shortName != null) {
      map['short_name'] = Variable<String>(shortName);
    }
    if (!nullToAbsent || alias != null) {
      map['alias'] = Variable<String>(alias);
    }
    if (!nullToAbsent || searchKeywords != null) {
      map['search_keywords'] = Variable<String>(searchKeywords);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['item_type'] = Variable<String>(itemType);
    map['has_stock_tracking'] = Variable<bool>(hasStockTracking);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || brandId != null) {
      map['brand_id'] = Variable<String>(brandId);
    }
    if (!nullToAbsent || hsnCode != null) {
      map['hsn_code'] = Variable<String>(hsnCode);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['base_unit'] = Variable<String>(baseUnit);
    if (!nullToAbsent || mrp != null) {
      map['mrp'] = Variable<String>(mrp);
    }
    map['is_mrp_only'] = Variable<bool>(isMrpOnly);
    if (!nullToAbsent || marketPrice != null) {
      map['market_price'] = Variable<String>(marketPrice);
    }
    map['sale_price'] = Variable<String>(salePrice);
    map['purchase_price'] = Variable<String>(purchasePrice);
    if (!nullToAbsent || reorderLevel != null) {
      map['reorder_level'] = Variable<String>(reorderLevel);
    }
    if (!nullToAbsent || defaultTaxRate != null) {
      map['default_tax_rate'] = Variable<String>(defaultTaxRate);
    }
    if (!nullToAbsent || primaryImageUrl != null) {
      map['primary_image_url'] = Variable<String>(primaryImageUrl);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  ItemsLocalCompanion toCompanion(bool nullToAbsent) {
    return ItemsLocalCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      shortName: shortName == null && nullToAbsent
          ? const Value.absent()
          : Value(shortName),
      alias: alias == null && nullToAbsent
          ? const Value.absent()
          : Value(alias),
      searchKeywords: searchKeywords == null && nullToAbsent
          ? const Value.absent()
          : Value(searchKeywords),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      itemType: Value(itemType),
      hasStockTracking: Value(hasStockTracking),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      brandId: brandId == null && nullToAbsent
          ? const Value.absent()
          : Value(brandId),
      hsnCode: hsnCode == null && nullToAbsent
          ? const Value.absent()
          : Value(hsnCode),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      baseUnit: Value(baseUnit),
      mrp: mrp == null && nullToAbsent ? const Value.absent() : Value(mrp),
      isMrpOnly: Value(isMrpOnly),
      marketPrice: marketPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(marketPrice),
      salePrice: Value(salePrice),
      purchasePrice: Value(purchasePrice),
      reorderLevel: reorderLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(reorderLevel),
      defaultTaxRate: defaultTaxRate == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultTaxRate),
      primaryImageUrl: primaryImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryImageUrl),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory ItemTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemTableData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String?>(json['shortName']),
      alias: serializer.fromJson<String?>(json['alias']),
      searchKeywords: serializer.fromJson<String?>(json['searchKeywords']),
      description: serializer.fromJson<String?>(json['description']),
      itemType: serializer.fromJson<String>(json['itemType']),
      hasStockTracking: serializer.fromJson<bool>(json['hasStockTracking']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      brandId: serializer.fromJson<String?>(json['brandId']),
      hsnCode: serializer.fromJson<String?>(json['hsnCode']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      baseUnit: serializer.fromJson<String>(json['baseUnit']),
      mrp: serializer.fromJson<String?>(json['mrp']),
      isMrpOnly: serializer.fromJson<bool>(json['isMrpOnly']),
      marketPrice: serializer.fromJson<String?>(json['marketPrice']),
      salePrice: serializer.fromJson<String>(json['salePrice']),
      purchasePrice: serializer.fromJson<String>(json['purchasePrice']),
      reorderLevel: serializer.fromJson<String?>(json['reorderLevel']),
      defaultTaxRate: serializer.fromJson<String?>(json['defaultTaxRate']),
      primaryImageUrl: serializer.fromJson<String?>(json['primaryImageUrl']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String?>(shortName),
      'alias': serializer.toJson<String?>(alias),
      'searchKeywords': serializer.toJson<String?>(searchKeywords),
      'description': serializer.toJson<String?>(description),
      'itemType': serializer.toJson<String>(itemType),
      'hasStockTracking': serializer.toJson<bool>(hasStockTracking),
      'categoryId': serializer.toJson<String?>(categoryId),
      'brandId': serializer.toJson<String?>(brandId),
      'hsnCode': serializer.toJson<String?>(hsnCode),
      'barcode': serializer.toJson<String?>(barcode),
      'baseUnit': serializer.toJson<String>(baseUnit),
      'mrp': serializer.toJson<String?>(mrp),
      'isMrpOnly': serializer.toJson<bool>(isMrpOnly),
      'marketPrice': serializer.toJson<String?>(marketPrice),
      'salePrice': serializer.toJson<String>(salePrice),
      'purchasePrice': serializer.toJson<String>(purchasePrice),
      'reorderLevel': serializer.toJson<String?>(reorderLevel),
      'defaultTaxRate': serializer.toJson<String?>(defaultTaxRate),
      'primaryImageUrl': serializer.toJson<String?>(primaryImageUrl),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  ItemTableData copyWith({
    String? id,
    String? businessId,
    String? name,
    Value<String?> shortName = const Value.absent(),
    Value<String?> alias = const Value.absent(),
    Value<String?> searchKeywords = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? itemType,
    bool? hasStockTracking,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> brandId = const Value.absent(),
    Value<String?> hsnCode = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    String? baseUnit,
    Value<String?> mrp = const Value.absent(),
    bool? isMrpOnly,
    Value<String?> marketPrice = const Value.absent(),
    String? salePrice,
    String? purchasePrice,
    Value<String?> reorderLevel = const Value.absent(),
    Value<String?> defaultTaxRate = const Value.absent(),
    Value<String?> primaryImageUrl = const Value.absent(),
    int? syncVersion,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
  }) => ItemTableData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    shortName: shortName.present ? shortName.value : this.shortName,
    alias: alias.present ? alias.value : this.alias,
    searchKeywords: searchKeywords.present
        ? searchKeywords.value
        : this.searchKeywords,
    description: description.present ? description.value : this.description,
    itemType: itemType ?? this.itemType,
    hasStockTracking: hasStockTracking ?? this.hasStockTracking,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    brandId: brandId.present ? brandId.value : this.brandId,
    hsnCode: hsnCode.present ? hsnCode.value : this.hsnCode,
    barcode: barcode.present ? barcode.value : this.barcode,
    baseUnit: baseUnit ?? this.baseUnit,
    mrp: mrp.present ? mrp.value : this.mrp,
    isMrpOnly: isMrpOnly ?? this.isMrpOnly,
    marketPrice: marketPrice.present ? marketPrice.value : this.marketPrice,
    salePrice: salePrice ?? this.salePrice,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    reorderLevel: reorderLevel.present ? reorderLevel.value : this.reorderLevel,
    defaultTaxRate: defaultTaxRate.present
        ? defaultTaxRate.value
        : this.defaultTaxRate,
    primaryImageUrl: primaryImageUrl.present
        ? primaryImageUrl.value
        : this.primaryImageUrl,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  ItemTableData copyWithCompanion(ItemsLocalCompanion data) {
    return ItemTableData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      alias: data.alias.present ? data.alias.value : this.alias,
      searchKeywords: data.searchKeywords.present
          ? data.searchKeywords.value
          : this.searchKeywords,
      description: data.description.present
          ? data.description.value
          : this.description,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      hasStockTracking: data.hasStockTracking.present
          ? data.hasStockTracking.value
          : this.hasStockTracking,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      brandId: data.brandId.present ? data.brandId.value : this.brandId,
      hsnCode: data.hsnCode.present ? data.hsnCode.value : this.hsnCode,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      baseUnit: data.baseUnit.present ? data.baseUnit.value : this.baseUnit,
      mrp: data.mrp.present ? data.mrp.value : this.mrp,
      isMrpOnly: data.isMrpOnly.present ? data.isMrpOnly.value : this.isMrpOnly,
      marketPrice: data.marketPrice.present
          ? data.marketPrice.value
          : this.marketPrice,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      defaultTaxRate: data.defaultTaxRate.present
          ? data.defaultTaxRate.value
          : this.defaultTaxRate,
      primaryImageUrl: data.primaryImageUrl.present
          ? data.primaryImageUrl.value
          : this.primaryImageUrl,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemTableData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('alias: $alias, ')
          ..write('searchKeywords: $searchKeywords, ')
          ..write('description: $description, ')
          ..write('itemType: $itemType, ')
          ..write('hasStockTracking: $hasStockTracking, ')
          ..write('categoryId: $categoryId, ')
          ..write('brandId: $brandId, ')
          ..write('hsnCode: $hsnCode, ')
          ..write('barcode: $barcode, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('mrp: $mrp, ')
          ..write('isMrpOnly: $isMrpOnly, ')
          ..write('marketPrice: $marketPrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('defaultTaxRate: $defaultTaxRate, ')
          ..write('primaryImageUrl: $primaryImageUrl, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    businessId,
    name,
    shortName,
    alias,
    searchKeywords,
    description,
    itemType,
    hasStockTracking,
    categoryId,
    brandId,
    hsnCode,
    barcode,
    baseUnit,
    mrp,
    isMrpOnly,
    marketPrice,
    salePrice,
    purchasePrice,
    reorderLevel,
    defaultTaxRate,
    primaryImageUrl,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemTableData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.alias == this.alias &&
          other.searchKeywords == this.searchKeywords &&
          other.description == this.description &&
          other.itemType == this.itemType &&
          other.hasStockTracking == this.hasStockTracking &&
          other.categoryId == this.categoryId &&
          other.brandId == this.brandId &&
          other.hsnCode == this.hsnCode &&
          other.barcode == this.barcode &&
          other.baseUnit == this.baseUnit &&
          other.mrp == this.mrp &&
          other.isMrpOnly == this.isMrpOnly &&
          other.marketPrice == this.marketPrice &&
          other.salePrice == this.salePrice &&
          other.purchasePrice == this.purchasePrice &&
          other.reorderLevel == this.reorderLevel &&
          other.defaultTaxRate == this.defaultTaxRate &&
          other.primaryImageUrl == this.primaryImageUrl &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class ItemsLocalCompanion extends UpdateCompanion<ItemTableData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String?> shortName;
  final Value<String?> alias;
  final Value<String?> searchKeywords;
  final Value<String?> description;
  final Value<String> itemType;
  final Value<bool> hasStockTracking;
  final Value<String?> categoryId;
  final Value<String?> brandId;
  final Value<String?> hsnCode;
  final Value<String?> barcode;
  final Value<String> baseUnit;
  final Value<String?> mrp;
  final Value<bool> isMrpOnly;
  final Value<String?> marketPrice;
  final Value<String> salePrice;
  final Value<String> purchasePrice;
  final Value<String?> reorderLevel;
  final Value<String?> defaultTaxRate;
  final Value<String?> primaryImageUrl;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const ItemsLocalCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.alias = const Value.absent(),
    this.searchKeywords = const Value.absent(),
    this.description = const Value.absent(),
    this.itemType = const Value.absent(),
    this.hasStockTracking = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.brandId = const Value.absent(),
    this.hsnCode = const Value.absent(),
    this.barcode = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.mrp = const Value.absent(),
    this.isMrpOnly = const Value.absent(),
    this.marketPrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.defaultTaxRate = const Value.absent(),
    this.primaryImageUrl = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsLocalCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    this.shortName = const Value.absent(),
    this.alias = const Value.absent(),
    this.searchKeywords = const Value.absent(),
    this.description = const Value.absent(),
    this.itemType = const Value.absent(),
    this.hasStockTracking = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.brandId = const Value.absent(),
    this.hsnCode = const Value.absent(),
    this.barcode = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.mrp = const Value.absent(),
    this.isMrpOnly = const Value.absent(),
    this.marketPrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.defaultTaxRate = const Value.absent(),
    this.primaryImageUrl = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ItemTableData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<String>? alias,
    Expression<String>? searchKeywords,
    Expression<String>? description,
    Expression<String>? itemType,
    Expression<bool>? hasStockTracking,
    Expression<String>? categoryId,
    Expression<String>? brandId,
    Expression<String>? hsnCode,
    Expression<String>? barcode,
    Expression<String>? baseUnit,
    Expression<String>? mrp,
    Expression<bool>? isMrpOnly,
    Expression<String>? marketPrice,
    Expression<String>? salePrice,
    Expression<String>? purchasePrice,
    Expression<String>? reorderLevel,
    Expression<String>? defaultTaxRate,
    Expression<String>? primaryImageUrl,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (alias != null) 'alias': alias,
      if (searchKeywords != null) 'search_keywords': searchKeywords,
      if (description != null) 'description': description,
      if (itemType != null) 'item_type': itemType,
      if (hasStockTracking != null) 'has_stock_tracking': hasStockTracking,
      if (categoryId != null) 'category_id': categoryId,
      if (brandId != null) 'brand_id': brandId,
      if (hsnCode != null) 'hsn_code': hsnCode,
      if (barcode != null) 'barcode': barcode,
      if (baseUnit != null) 'base_unit': baseUnit,
      if (mrp != null) 'mrp': mrp,
      if (isMrpOnly != null) 'is_mrp_only': isMrpOnly,
      if (marketPrice != null) 'market_price': marketPrice,
      if (salePrice != null) 'sale_price': salePrice,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (defaultTaxRate != null) 'default_tax_rate': defaultTaxRate,
      if (primaryImageUrl != null) 'primary_image_url': primaryImageUrl,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? name,
    Value<String?>? shortName,
    Value<String?>? alias,
    Value<String?>? searchKeywords,
    Value<String?>? description,
    Value<String>? itemType,
    Value<bool>? hasStockTracking,
    Value<String?>? categoryId,
    Value<String?>? brandId,
    Value<String?>? hsnCode,
    Value<String?>? barcode,
    Value<String>? baseUnit,
    Value<String?>? mrp,
    Value<bool>? isMrpOnly,
    Value<String?>? marketPrice,
    Value<String>? salePrice,
    Value<String>? purchasePrice,
    Value<String?>? reorderLevel,
    Value<String?>? defaultTaxRate,
    Value<String?>? primaryImageUrl,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return ItemsLocalCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      alias: alias ?? this.alias,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      description: description ?? this.description,
      itemType: itemType ?? this.itemType,
      hasStockTracking: hasStockTracking ?? this.hasStockTracking,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      hsnCode: hsnCode ?? this.hsnCode,
      barcode: barcode ?? this.barcode,
      baseUnit: baseUnit ?? this.baseUnit,
      mrp: mrp ?? this.mrp,
      isMrpOnly: isMrpOnly ?? this.isMrpOnly,
      marketPrice: marketPrice ?? this.marketPrice,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (searchKeywords.present) {
      map['search_keywords'] = Variable<String>(searchKeywords.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (hasStockTracking.present) {
      map['has_stock_tracking'] = Variable<bool>(hasStockTracking.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (brandId.present) {
      map['brand_id'] = Variable<String>(brandId.value);
    }
    if (hsnCode.present) {
      map['hsn_code'] = Variable<String>(hsnCode.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (baseUnit.present) {
      map['base_unit'] = Variable<String>(baseUnit.value);
    }
    if (mrp.present) {
      map['mrp'] = Variable<String>(mrp.value);
    }
    if (isMrpOnly.present) {
      map['is_mrp_only'] = Variable<bool>(isMrpOnly.value);
    }
    if (marketPrice.present) {
      map['market_price'] = Variable<String>(marketPrice.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<String>(salePrice.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<String>(purchasePrice.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<String>(reorderLevel.value);
    }
    if (defaultTaxRate.present) {
      map['default_tax_rate'] = Variable<String>(defaultTaxRate.value);
    }
    if (primaryImageUrl.present) {
      map['primary_image_url'] = Variable<String>(primaryImageUrl.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsLocalCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('alias: $alias, ')
          ..write('searchKeywords: $searchKeywords, ')
          ..write('description: $description, ')
          ..write('itemType: $itemType, ')
          ..write('hasStockTracking: $hasStockTracking, ')
          ..write('categoryId: $categoryId, ')
          ..write('brandId: $brandId, ')
          ..write('hsnCode: $hsnCode, ')
          ..write('barcode: $barcode, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('mrp: $mrp, ')
          ..write('isMrpOnly: $isMrpOnly, ')
          ..write('marketPrice: $marketPrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('defaultTaxRate: $defaultTaxRate, ')
          ..write('primaryImageUrl: $primaryImageUrl, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitDefinitionsLocalTable extends UnitDefinitionsLocal
    with TableInfo<$UnitDefinitionsLocalTable, UnitDefinitionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitDefinitionsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decimalPlacesMeta = const VerificationMeta(
    'decimalPlaces',
  );
  @override
  late final GeneratedColumn<int> decimalPlaces = GeneratedColumn<int>(
    'decimal_places',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    shortName,
    symbol,
    decimalPlaces,
    isSystem,
    isActive,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unit_definitions_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnitDefinitionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    }
    if (data.containsKey('decimal_places')) {
      context.handle(
        _decimalPlacesMeta,
        decimalPlaces.isAcceptableOrUnknown(
          data['decimal_places']!,
          _decimalPlacesMeta,
        ),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitDefinitionTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitDefinitionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      ),
      decimalPlaces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}decimal_places'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $UnitDefinitionsLocalTable createAlias(String alias) {
    return $UnitDefinitionsLocalTable(attachedDatabase, alias);
  }
}

class UnitDefinitionTableData extends DataClass
    implements Insertable<UnitDefinitionTableData> {
  final String id;
  final String businessId;
  final String name;
  final String shortName;
  final String? symbol;
  final int decimalPlaces;
  final bool isSystem;
  final bool isActive;
  final int syncVersion;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  const UnitDefinitionTableData({
    required this.id,
    required this.businessId,
    required this.name,
    required this.shortName,
    this.symbol,
    required this.decimalPlaces,
    required this.isSystem,
    required this.isActive,
    required this.syncVersion,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    map['short_name'] = Variable<String>(shortName);
    if (!nullToAbsent || symbol != null) {
      map['symbol'] = Variable<String>(symbol);
    }
    map['decimal_places'] = Variable<int>(decimalPlaces);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_active'] = Variable<bool>(isActive);
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  UnitDefinitionsLocalCompanion toCompanion(bool nullToAbsent) {
    return UnitDefinitionsLocalCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      shortName: Value(shortName),
      symbol: symbol == null && nullToAbsent
          ? const Value.absent()
          : Value(symbol),
      decimalPlaces: Value(decimalPlaces),
      isSystem: Value(isSystem),
      isActive: Value(isActive),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory UnitDefinitionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitDefinitionTableData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String>(json['shortName']),
      symbol: serializer.fromJson<String?>(json['symbol']),
      decimalPlaces: serializer.fromJson<int>(json['decimalPlaces']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String>(shortName),
      'symbol': serializer.toJson<String?>(symbol),
      'decimalPlaces': serializer.toJson<int>(decimalPlaces),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isActive': serializer.toJson<bool>(isActive),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  UnitDefinitionTableData copyWith({
    String? id,
    String? businessId,
    String? name,
    String? shortName,
    Value<String?> symbol = const Value.absent(),
    int? decimalPlaces,
    bool? isSystem,
    bool? isActive,
    int? syncVersion,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
  }) => UnitDefinitionTableData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    shortName: shortName ?? this.shortName,
    symbol: symbol.present ? symbol.value : this.symbol,
    decimalPlaces: decimalPlaces ?? this.decimalPlaces,
    isSystem: isSystem ?? this.isSystem,
    isActive: isActive ?? this.isActive,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  UnitDefinitionTableData copyWithCompanion(
    UnitDefinitionsLocalCompanion data,
  ) {
    return UnitDefinitionTableData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      decimalPlaces: data.decimalPlaces.present
          ? data.decimalPlaces.value
          : this.decimalPlaces,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitDefinitionTableData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('symbol: $symbol, ')
          ..write('decimalPlaces: $decimalPlaces, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    name,
    shortName,
    symbol,
    decimalPlaces,
    isSystem,
    isActive,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitDefinitionTableData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.symbol == this.symbol &&
          other.decimalPlaces == this.decimalPlaces &&
          other.isSystem == this.isSystem &&
          other.isActive == this.isActive &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class UnitDefinitionsLocalCompanion
    extends UpdateCompanion<UnitDefinitionTableData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String> shortName;
  final Value<String?> symbol;
  final Value<int> decimalPlaces;
  final Value<bool> isSystem;
  final Value<bool> isActive;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const UnitDefinitionsLocalCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.symbol = const Value.absent(),
    this.decimalPlaces = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitDefinitionsLocalCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    required String shortName,
    this.symbol = const Value.absent(),
    this.decimalPlaces = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       name = Value(name),
       shortName = Value(shortName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UnitDefinitionTableData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<String>? symbol,
    Expression<int>? decimalPlaces,
    Expression<bool>? isSystem,
    Expression<bool>? isActive,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (symbol != null) 'symbol': symbol,
      if (decimalPlaces != null) 'decimal_places': decimalPlaces,
      if (isSystem != null) 'is_system': isSystem,
      if (isActive != null) 'is_active': isActive,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitDefinitionsLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? name,
    Value<String>? shortName,
    Value<String?>? symbol,
    Value<int>? decimalPlaces,
    Value<bool>? isSystem,
    Value<bool>? isActive,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return UnitDefinitionsLocalCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      symbol: symbol ?? this.symbol,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (decimalPlaces.present) {
      map['decimal_places'] = Variable<int>(decimalPlaces.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitDefinitionsLocalCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('symbol: $symbol, ')
          ..write('decimalPlaces: $decimalPlaces, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaxRatesLocalTable extends TaxRatesLocal
    with TableInfo<$TaxRatesLocalTable, TaxRateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaxRatesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<String> rate = GeneratedColumn<String>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    rate,
    isDefault,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tax_rates_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaxRateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaxRateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaxRateTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $TaxRatesLocalTable createAlias(String alias) {
    return $TaxRatesLocalTable(attachedDatabase, alias);
  }
}

class TaxRateTableData extends DataClass
    implements Insertable<TaxRateTableData> {
  final String id;
  final String businessId;
  final String name;
  final String rate;
  final bool isDefault;
  final int syncVersion;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  const TaxRateTableData({
    required this.id,
    required this.businessId,
    required this.name,
    required this.rate,
    required this.isDefault,
    required this.syncVersion,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    map['rate'] = Variable<String>(rate);
    map['is_default'] = Variable<bool>(isDefault);
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  TaxRatesLocalCompanion toCompanion(bool nullToAbsent) {
    return TaxRatesLocalCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      rate: Value(rate),
      isDefault: Value(isDefault),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory TaxRateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaxRateTableData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      rate: serializer.fromJson<String>(json['rate']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'rate': serializer.toJson<String>(rate),
      'isDefault': serializer.toJson<bool>(isDefault),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  TaxRateTableData copyWith({
    String? id,
    String? businessId,
    String? name,
    String? rate,
    bool? isDefault,
    int? syncVersion,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
  }) => TaxRateTableData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    rate: rate ?? this.rate,
    isDefault: isDefault ?? this.isDefault,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  TaxRateTableData copyWithCompanion(TaxRatesLocalCompanion data) {
    return TaxRateTableData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      rate: data.rate.present ? data.rate.value : this.rate,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaxRateTableData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('rate: $rate, ')
          ..write('isDefault: $isDefault, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    name,
    rate,
    isDefault,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxRateTableData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.rate == this.rate &&
          other.isDefault == this.isDefault &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class TaxRatesLocalCompanion extends UpdateCompanion<TaxRateTableData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String> rate;
  final Value<bool> isDefault;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const TaxRatesLocalCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.rate = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaxRatesLocalCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    required String rate,
    this.isDefault = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       name = Value(name),
       rate = Value(rate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaxRateTableData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? rate,
    Expression<bool>? isDefault,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (rate != null) 'rate': rate,
      if (isDefault != null) 'is_default': isDefault,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaxRatesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? name,
    Value<String>? rate,
    Value<bool>? isDefault,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return TaxRatesLocalCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      isDefault: isDefault ?? this.isDefault,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rate.present) {
      map['rate'] = Variable<String>(rate.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxRatesLocalCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('rate: $rate, ')
          ..write('isDefault: $isDefault, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GodownsLocalTable extends GodownsLocal
    with TableInfo<$GodownsLocalTable, GodownTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GodownsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    address,
    isDefault,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'godowns_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<GodownTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GodownTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GodownTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $GodownsLocalTable createAlias(String alias) {
    return $GodownsLocalTable(attachedDatabase, alias);
  }
}

class GodownTableData extends DataClass implements Insertable<GodownTableData> {
  final String id;
  final String businessId;
  final String name;
  final String? address;
  final bool isDefault;
  final int syncVersion;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  const GodownTableData({
    required this.id,
    required this.businessId,
    required this.name,
    this.address,
    required this.isDefault,
    required this.syncVersion,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  GodownsLocalCompanion toCompanion(bool nullToAbsent) {
    return GodownsLocalCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      isDefault: Value(isDefault),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory GodownTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GodownTableData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'isDefault': serializer.toJson<bool>(isDefault),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  GodownTableData copyWith({
    String? id,
    String? businessId,
    String? name,
    Value<String?> address = const Value.absent(),
    bool? isDefault,
    int? syncVersion,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
  }) => GodownTableData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    isDefault: isDefault ?? this.isDefault,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  GodownTableData copyWithCompanion(GodownsLocalCompanion data) {
    return GodownTableData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GodownTableData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('isDefault: $isDefault, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    name,
    address,
    isDefault,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GodownTableData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.address == this.address &&
          other.isDefault == this.isDefault &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class GodownsLocalCompanion extends UpdateCompanion<GodownTableData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String?> address;
  final Value<bool> isDefault;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const GodownsLocalCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GodownsLocalCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    this.address = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GodownTableData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? address,
    Expression<bool>? isDefault,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (isDefault != null) 'is_default': isDefault,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GodownsLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? name,
    Value<String?>? address,
    Value<bool>? isDefault,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return GodownsLocalCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GodownsLocalCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('isDefault: $isDefault, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BusinessSettingsLocalTable extends BusinessSettingsLocal
    with TableInfo<$BusinessSettingsLocalTable, BusinessSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessSettingsLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valuationMethodMeta = const VerificationMeta(
    'valuationMethod',
  );
  @override
  late final GeneratedColumn<String> valuationMethod = GeneratedColumn<String>(
    'valuation_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('average'),
  );
  static const VerificationMeta _defaultTaxTypeMeta = const VerificationMeta(
    'defaultTaxType',
  );
  @override
  late final GeneratedColumn<String> defaultTaxType = GeneratedColumn<String>(
    'default_tax_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _invoiceTermsMeta = const VerificationMeta(
    'invoiceTerms',
  );
  @override
  late final GeneratedColumn<String> invoiceTerms = GeneratedColumn<String>(
    'invoice_terms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enablePriceConflictAlertsMeta =
      const VerificationMeta('enablePriceConflictAlerts');
  @override
  late final GeneratedColumn<bool> enablePriceConflictAlerts =
      GeneratedColumn<bool>(
        'enable_price_conflict_alerts',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_price_conflict_alerts" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _creditLimitActionMeta = const VerificationMeta(
    'creditLimitAction',
  );
  @override
  late final GeneratedColumn<String> creditLimitAction =
      GeneratedColumn<String>(
        'credit_limit_action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('warn'),
      );
  static const VerificationMeta _pricingTierLabelsMeta = const VerificationMeta(
    'pricingTierLabels',
  );
  @override
  late final GeneratedColumn<String> pricingTierLabels =
      GeneratedColumn<String>(
        'pricing_tier_labels',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _defaultInvoiceTaxRateMeta =
      const VerificationMeta('defaultInvoiceTaxRate');
  @override
  late final GeneratedColumn<String> defaultInvoiceTaxRate =
      GeneratedColumn<String>(
        'default_invoice_tax_rate',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    valuationMethod,
    defaultTaxType,
    invoiceTerms,
    enablePriceConflictAlerts,
    creditLimitAction,
    pricingTierLabels,
    defaultInvoiceTaxRate,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'business_settings_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<BusinessSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('valuation_method')) {
      context.handle(
        _valuationMethodMeta,
        valuationMethod.isAcceptableOrUnknown(
          data['valuation_method']!,
          _valuationMethodMeta,
        ),
      );
    }
    if (data.containsKey('default_tax_type')) {
      context.handle(
        _defaultTaxTypeMeta,
        defaultTaxType.isAcceptableOrUnknown(
          data['default_tax_type']!,
          _defaultTaxTypeMeta,
        ),
      );
    }
    if (data.containsKey('invoice_terms')) {
      context.handle(
        _invoiceTermsMeta,
        invoiceTerms.isAcceptableOrUnknown(
          data['invoice_terms']!,
          _invoiceTermsMeta,
        ),
      );
    }
    if (data.containsKey('enable_price_conflict_alerts')) {
      context.handle(
        _enablePriceConflictAlertsMeta,
        enablePriceConflictAlerts.isAcceptableOrUnknown(
          data['enable_price_conflict_alerts']!,
          _enablePriceConflictAlertsMeta,
        ),
      );
    }
    if (data.containsKey('credit_limit_action')) {
      context.handle(
        _creditLimitActionMeta,
        creditLimitAction.isAcceptableOrUnknown(
          data['credit_limit_action']!,
          _creditLimitActionMeta,
        ),
      );
    }
    if (data.containsKey('pricing_tier_labels')) {
      context.handle(
        _pricingTierLabelsMeta,
        pricingTierLabels.isAcceptableOrUnknown(
          data['pricing_tier_labels']!,
          _pricingTierLabelsMeta,
        ),
      );
    }
    if (data.containsKey('default_invoice_tax_rate')) {
      context.handle(
        _defaultInvoiceTaxRateMeta,
        defaultInvoiceTaxRate.isAcceptableOrUnknown(
          data['default_invoice_tax_rate']!,
          _defaultInvoiceTaxRateMeta,
        ),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BusinessSettingsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      valuationMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valuation_method'],
      )!,
      defaultTaxType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_tax_type'],
      )!,
      invoiceTerms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_terms'],
      ),
      enablePriceConflictAlerts: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_price_conflict_alerts'],
      )!,
      creditLimitAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credit_limit_action'],
      )!,
      pricingTierLabels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pricing_tier_labels'],
      ),
      defaultInvoiceTaxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_invoice_tax_rate'],
      ),
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $BusinessSettingsLocalTable createAlias(String alias) {
    return $BusinessSettingsLocalTable(attachedDatabase, alias);
  }
}

class BusinessSettingsTableData extends DataClass
    implements Insertable<BusinessSettingsTableData> {
  final String id;
  final String businessId;
  final String valuationMethod;
  final String defaultTaxType;
  final String? invoiceTerms;
  final bool enablePriceConflictAlerts;
  final String creditLimitAction;

  /// JSON object string for pricing tier labels.
  final String? pricingTierLabels;
  final String? defaultInvoiceTaxRate;
  final int syncVersion;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  const BusinessSettingsTableData({
    required this.id,
    required this.businessId,
    required this.valuationMethod,
    required this.defaultTaxType,
    this.invoiceTerms,
    required this.enablePriceConflictAlerts,
    required this.creditLimitAction,
    this.pricingTierLabels,
    this.defaultInvoiceTaxRate,
    required this.syncVersion,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['valuation_method'] = Variable<String>(valuationMethod);
    map['default_tax_type'] = Variable<String>(defaultTaxType);
    if (!nullToAbsent || invoiceTerms != null) {
      map['invoice_terms'] = Variable<String>(invoiceTerms);
    }
    map['enable_price_conflict_alerts'] = Variable<bool>(
      enablePriceConflictAlerts,
    );
    map['credit_limit_action'] = Variable<String>(creditLimitAction);
    if (!nullToAbsent || pricingTierLabels != null) {
      map['pricing_tier_labels'] = Variable<String>(pricingTierLabels);
    }
    if (!nullToAbsent || defaultInvoiceTaxRate != null) {
      map['default_invoice_tax_rate'] = Variable<String>(defaultInvoiceTaxRate);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  BusinessSettingsLocalCompanion toCompanion(bool nullToAbsent) {
    return BusinessSettingsLocalCompanion(
      id: Value(id),
      businessId: Value(businessId),
      valuationMethod: Value(valuationMethod),
      defaultTaxType: Value(defaultTaxType),
      invoiceTerms: invoiceTerms == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceTerms),
      enablePriceConflictAlerts: Value(enablePriceConflictAlerts),
      creditLimitAction: Value(creditLimitAction),
      pricingTierLabels: pricingTierLabels == null && nullToAbsent
          ? const Value.absent()
          : Value(pricingTierLabels),
      defaultInvoiceTaxRate: defaultInvoiceTaxRate == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultInvoiceTaxRate),
      syncVersion: Value(syncVersion),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory BusinessSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessSettingsTableData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      valuationMethod: serializer.fromJson<String>(json['valuationMethod']),
      defaultTaxType: serializer.fromJson<String>(json['defaultTaxType']),
      invoiceTerms: serializer.fromJson<String?>(json['invoiceTerms']),
      enablePriceConflictAlerts: serializer.fromJson<bool>(
        json['enablePriceConflictAlerts'],
      ),
      creditLimitAction: serializer.fromJson<String>(json['creditLimitAction']),
      pricingTierLabels: serializer.fromJson<String?>(
        json['pricingTierLabels'],
      ),
      defaultInvoiceTaxRate: serializer.fromJson<String?>(
        json['defaultInvoiceTaxRate'],
      ),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'valuationMethod': serializer.toJson<String>(valuationMethod),
      'defaultTaxType': serializer.toJson<String>(defaultTaxType),
      'invoiceTerms': serializer.toJson<String?>(invoiceTerms),
      'enablePriceConflictAlerts': serializer.toJson<bool>(
        enablePriceConflictAlerts,
      ),
      'creditLimitAction': serializer.toJson<String>(creditLimitAction),
      'pricingTierLabels': serializer.toJson<String?>(pricingTierLabels),
      'defaultInvoiceTaxRate': serializer.toJson<String?>(
        defaultInvoiceTaxRate,
      ),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  BusinessSettingsTableData copyWith({
    String? id,
    String? businessId,
    String? valuationMethod,
    String? defaultTaxType,
    Value<String?> invoiceTerms = const Value.absent(),
    bool? enablePriceConflictAlerts,
    String? creditLimitAction,
    Value<String?> pricingTierLabels = const Value.absent(),
    Value<String?> defaultInvoiceTaxRate = const Value.absent(),
    int? syncVersion,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
  }) => BusinessSettingsTableData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    valuationMethod: valuationMethod ?? this.valuationMethod,
    defaultTaxType: defaultTaxType ?? this.defaultTaxType,
    invoiceTerms: invoiceTerms.present ? invoiceTerms.value : this.invoiceTerms,
    enablePriceConflictAlerts:
        enablePriceConflictAlerts ?? this.enablePriceConflictAlerts,
    creditLimitAction: creditLimitAction ?? this.creditLimitAction,
    pricingTierLabels: pricingTierLabels.present
        ? pricingTierLabels.value
        : this.pricingTierLabels,
    defaultInvoiceTaxRate: defaultInvoiceTaxRate.present
        ? defaultInvoiceTaxRate.value
        : this.defaultInvoiceTaxRate,
    syncVersion: syncVersion ?? this.syncVersion,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  BusinessSettingsTableData copyWithCompanion(
    BusinessSettingsLocalCompanion data,
  ) {
    return BusinessSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      valuationMethod: data.valuationMethod.present
          ? data.valuationMethod.value
          : this.valuationMethod,
      defaultTaxType: data.defaultTaxType.present
          ? data.defaultTaxType.value
          : this.defaultTaxType,
      invoiceTerms: data.invoiceTerms.present
          ? data.invoiceTerms.value
          : this.invoiceTerms,
      enablePriceConflictAlerts: data.enablePriceConflictAlerts.present
          ? data.enablePriceConflictAlerts.value
          : this.enablePriceConflictAlerts,
      creditLimitAction: data.creditLimitAction.present
          ? data.creditLimitAction.value
          : this.creditLimitAction,
      pricingTierLabels: data.pricingTierLabels.present
          ? data.pricingTierLabels.value
          : this.pricingTierLabels,
      defaultInvoiceTaxRate: data.defaultInvoiceTaxRate.present
          ? data.defaultInvoiceTaxRate.value
          : this.defaultInvoiceTaxRate,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessSettingsTableData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('valuationMethod: $valuationMethod, ')
          ..write('defaultTaxType: $defaultTaxType, ')
          ..write('invoiceTerms: $invoiceTerms, ')
          ..write('enablePriceConflictAlerts: $enablePriceConflictAlerts, ')
          ..write('creditLimitAction: $creditLimitAction, ')
          ..write('pricingTierLabels: $pricingTierLabels, ')
          ..write('defaultInvoiceTaxRate: $defaultInvoiceTaxRate, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    valuationMethod,
    defaultTaxType,
    invoiceTerms,
    enablePriceConflictAlerts,
    creditLimitAction,
    pricingTierLabels,
    defaultInvoiceTaxRate,
    syncVersion,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessSettingsTableData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.valuationMethod == this.valuationMethod &&
          other.defaultTaxType == this.defaultTaxType &&
          other.invoiceTerms == this.invoiceTerms &&
          other.enablePriceConflictAlerts == this.enablePriceConflictAlerts &&
          other.creditLimitAction == this.creditLimitAction &&
          other.pricingTierLabels == this.pricingTierLabels &&
          other.defaultInvoiceTaxRate == this.defaultInvoiceTaxRate &&
          other.syncVersion == this.syncVersion &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class BusinessSettingsLocalCompanion
    extends UpdateCompanion<BusinessSettingsTableData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> valuationMethod;
  final Value<String> defaultTaxType;
  final Value<String?> invoiceTerms;
  final Value<bool> enablePriceConflictAlerts;
  final Value<String> creditLimitAction;
  final Value<String?> pricingTierLabels;
  final Value<String?> defaultInvoiceTaxRate;
  final Value<int> syncVersion;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const BusinessSettingsLocalCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.valuationMethod = const Value.absent(),
    this.defaultTaxType = const Value.absent(),
    this.invoiceTerms = const Value.absent(),
    this.enablePriceConflictAlerts = const Value.absent(),
    this.creditLimitAction = const Value.absent(),
    this.pricingTierLabels = const Value.absent(),
    this.defaultInvoiceTaxRate = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BusinessSettingsLocalCompanion.insert({
    required String id,
    required String businessId,
    this.valuationMethod = const Value.absent(),
    this.defaultTaxType = const Value.absent(),
    this.invoiceTerms = const Value.absent(),
    this.enablePriceConflictAlerts = const Value.absent(),
    this.creditLimitAction = const Value.absent(),
    this.pricingTierLabels = const Value.absent(),
    this.defaultInvoiceTaxRate = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BusinessSettingsTableData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? valuationMethod,
    Expression<String>? defaultTaxType,
    Expression<String>? invoiceTerms,
    Expression<bool>? enablePriceConflictAlerts,
    Expression<String>? creditLimitAction,
    Expression<String>? pricingTierLabels,
    Expression<String>? defaultInvoiceTaxRate,
    Expression<int>? syncVersion,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (valuationMethod != null) 'valuation_method': valuationMethod,
      if (defaultTaxType != null) 'default_tax_type': defaultTaxType,
      if (invoiceTerms != null) 'invoice_terms': invoiceTerms,
      if (enablePriceConflictAlerts != null)
        'enable_price_conflict_alerts': enablePriceConflictAlerts,
      if (creditLimitAction != null) 'credit_limit_action': creditLimitAction,
      if (pricingTierLabels != null) 'pricing_tier_labels': pricingTierLabels,
      if (defaultInvoiceTaxRate != null)
        'default_invoice_tax_rate': defaultInvoiceTaxRate,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BusinessSettingsLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? valuationMethod,
    Value<String>? defaultTaxType,
    Value<String?>? invoiceTerms,
    Value<bool>? enablePriceConflictAlerts,
    Value<String>? creditLimitAction,
    Value<String?>? pricingTierLabels,
    Value<String?>? defaultInvoiceTaxRate,
    Value<int>? syncVersion,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return BusinessSettingsLocalCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      valuationMethod: valuationMethod ?? this.valuationMethod,
      defaultTaxType: defaultTaxType ?? this.defaultTaxType,
      invoiceTerms: invoiceTerms ?? this.invoiceTerms,
      enablePriceConflictAlerts:
          enablePriceConflictAlerts ?? this.enablePriceConflictAlerts,
      creditLimitAction: creditLimitAction ?? this.creditLimitAction,
      pricingTierLabels: pricingTierLabels ?? this.pricingTierLabels,
      defaultInvoiceTaxRate:
          defaultInvoiceTaxRate ?? this.defaultInvoiceTaxRate,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (valuationMethod.present) {
      map['valuation_method'] = Variable<String>(valuationMethod.value);
    }
    if (defaultTaxType.present) {
      map['default_tax_type'] = Variable<String>(defaultTaxType.value);
    }
    if (invoiceTerms.present) {
      map['invoice_terms'] = Variable<String>(invoiceTerms.value);
    }
    if (enablePriceConflictAlerts.present) {
      map['enable_price_conflict_alerts'] = Variable<bool>(
        enablePriceConflictAlerts.value,
      );
    }
    if (creditLimitAction.present) {
      map['credit_limit_action'] = Variable<String>(creditLimitAction.value);
    }
    if (pricingTierLabels.present) {
      map['pricing_tier_labels'] = Variable<String>(pricingTierLabels.value);
    }
    if (defaultInvoiceTaxRate.present) {
      map['default_invoice_tax_rate'] = Variable<String>(
        defaultInvoiceTaxRate.value,
      );
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessSettingsLocalCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('valuationMethod: $valuationMethod, ')
          ..write('defaultTaxType: $defaultTaxType, ')
          ..write('invoiceTerms: $invoiceTerms, ')
          ..write('enablePriceConflictAlerts: $enablePriceConflictAlerts, ')
          ..write('creditLimitAction: $creditLimitAction, ')
          ..write('pricingTierLabels: $pricingTierLabels, ')
          ..write('defaultInvoiceTaxRate: $defaultInvoiceTaxRate, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SalesLocalTable salesLocal = $SalesLocalTable(this);
  late final $SalesLineLocalTable salesLineLocal = $SalesLineLocalTable(this);
  late final $HeldBillsLocalTable heldBillsLocal = $HeldBillsLocalTable(this);
  late final $LeadsTable leads = $LeadsTable(this);
  late final $LeadActivitiesTable leadActivities = $LeadActivitiesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $ContactActivitiesTable contactActivities =
      $ContactActivitiesTable(this);
  late final $DealsTable deals = $DealsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $CategoriesLocalTable categoriesLocal = $CategoriesLocalTable(
    this,
  );
  late final $PartiesLocalTable partiesLocal = $PartiesLocalTable(this);
  late final $ItemsLocalTable itemsLocal = $ItemsLocalTable(this);
  late final $UnitDefinitionsLocalTable unitDefinitionsLocal =
      $UnitDefinitionsLocalTable(this);
  late final $TaxRatesLocalTable taxRatesLocal = $TaxRatesLocalTable(this);
  late final $GodownsLocalTable godownsLocal = $GodownsLocalTable(this);
  late final $BusinessSettingsLocalTable businessSettingsLocal =
      $BusinessSettingsLocalTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    salesLocal,
    salesLineLocal,
    heldBillsLocal,
    leads,
    leadActivities,
    contacts,
    contactActivities,
    deals,
    syncQueue,
    categoriesLocal,
    partiesLocal,
    itemsLocal,
    unitDefinitionsLocal,
    taxRatesLocal,
    godownsLocal,
    businessSettingsLocal,
  ];
}

typedef $$SalesLocalTableCreateCompanionBuilder =
    SalesLocalCompanion Function({
      required String id,
      required String businessId,
      required String docNumber,
      Value<String?> partyId,
      required double totalAmount,
      required double taxAmount,
      required double finalAmount,
      required DateTime createdAt,
      Value<DateTime> savedAt,
      required String paymentMethod,
      required String apiResponseJson,
      Value<int> rowid,
    });
typedef $$SalesLocalTableUpdateCompanionBuilder =
    SalesLocalCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> docNumber,
      Value<String?> partyId,
      Value<double> totalAmount,
      Value<double> taxAmount,
      Value<double> finalAmount,
      Value<DateTime> createdAt,
      Value<DateTime> savedAt,
      Value<String> paymentMethod,
      Value<String> apiResponseJson,
      Value<int> rowid,
    });

final class $$SalesLocalTableReferences
    extends BaseReferences<_$AppDatabase, $SalesLocalTable, SaleLocal> {
  $$SalesLocalTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesLineLocalTable, List<SaleLineLocal>>
  _salesLineLocalRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.salesLineLocal,
    aliasName: 'sales_local__id__sales_line_local__sale_id',
  );

  $$SalesLineLocalTableProcessedTableManager get salesLineLocalRefs {
    final manager = $$SalesLineLocalTableTableManager(
      $_db,
      $_db.salesLineLocal,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesLineLocalRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $SalesLocalTable> {
  $$SalesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docNumber => $composableBuilder(
    column: $table.docNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get finalAmount => $composableBuilder(
    column: $table.finalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiResponseJson => $composableBuilder(
    column: $table.apiResponseJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> salesLineLocalRefs(
    Expression<bool> Function($$SalesLineLocalTableFilterComposer f) f,
  ) {
    final $$SalesLineLocalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesLineLocal,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesLineLocalTableFilterComposer(
            $db: $db,
            $table: $db.salesLineLocal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesLocalTable> {
  $$SalesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docNumber => $composableBuilder(
    column: $table.docNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get finalAmount => $composableBuilder(
    column: $table.finalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiResponseJson => $composableBuilder(
    column: $table.apiResponseJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesLocalTable> {
  $$SalesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get docNumber =>
      $composableBuilder(column: $table.docNumber, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get finalAmount => $composableBuilder(
    column: $table.finalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get apiResponseJson => $composableBuilder(
    column: $table.apiResponseJson,
    builder: (column) => column,
  );

  Expression<T> salesLineLocalRefs<T extends Object>(
    Expression<T> Function($$SalesLineLocalTableAnnotationComposer a) f,
  ) {
    final $$SalesLineLocalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesLineLocal,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesLineLocalTableAnnotationComposer(
            $db: $db,
            $table: $db.salesLineLocal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesLocalTable,
          SaleLocal,
          $$SalesLocalTableFilterComposer,
          $$SalesLocalTableOrderingComposer,
          $$SalesLocalTableAnnotationComposer,
          $$SalesLocalTableCreateCompanionBuilder,
          $$SalesLocalTableUpdateCompanionBuilder,
          (SaleLocal, $$SalesLocalTableReferences),
          SaleLocal,
          PrefetchHooks Function({bool salesLineLocalRefs})
        > {
  $$SalesLocalTableTableManager(_$AppDatabase db, $SalesLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> docNumber = const Value.absent(),
                Value<String?> partyId = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> finalAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> apiResponseJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesLocalCompanion(
                id: id,
                businessId: businessId,
                docNumber: docNumber,
                partyId: partyId,
                totalAmount: totalAmount,
                taxAmount: taxAmount,
                finalAmount: finalAmount,
                createdAt: createdAt,
                savedAt: savedAt,
                paymentMethod: paymentMethod,
                apiResponseJson: apiResponseJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String docNumber,
                Value<String?> partyId = const Value.absent(),
                required double totalAmount,
                required double taxAmount,
                required double finalAmount,
                required DateTime createdAt,
                Value<DateTime> savedAt = const Value.absent(),
                required String paymentMethod,
                required String apiResponseJson,
                Value<int> rowid = const Value.absent(),
              }) => SalesLocalCompanion.insert(
                id: id,
                businessId: businessId,
                docNumber: docNumber,
                partyId: partyId,
                totalAmount: totalAmount,
                taxAmount: taxAmount,
                finalAmount: finalAmount,
                createdAt: createdAt,
                savedAt: savedAt,
                paymentMethod: paymentMethod,
                apiResponseJson: apiResponseJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SalesLocalTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({salesLineLocalRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (salesLineLocalRefs) db.salesLineLocal,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesLineLocalRefs)
                    await $_getPrefetchedData<
                      SaleLocal,
                      $SalesLocalTable,
                      SaleLineLocal
                    >(
                      currentTable: table,
                      referencedTable: $$SalesLocalTableReferences
                          ._salesLineLocalRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SalesLocalTableReferences(
                            db,
                            table,
                            p0,
                          ).salesLineLocalRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.saleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SalesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesLocalTable,
      SaleLocal,
      $$SalesLocalTableFilterComposer,
      $$SalesLocalTableOrderingComposer,
      $$SalesLocalTableAnnotationComposer,
      $$SalesLocalTableCreateCompanionBuilder,
      $$SalesLocalTableUpdateCompanionBuilder,
      (SaleLocal, $$SalesLocalTableReferences),
      SaleLocal,
      PrefetchHooks Function({bool salesLineLocalRefs})
    >;
typedef $$SalesLineLocalTableCreateCompanionBuilder =
    SalesLineLocalCompanion Function({
      required String id,
      required String businessId,
      required String saleId,
      required String itemId,
      required String itemName,
      required int quantity,
      required double rate,
      required double lineTotal,
      required double cgstAmount,
      required double sgstAmount,
      required double igstAmount,
      Value<int> rowid,
    });
typedef $$SalesLineLocalTableUpdateCompanionBuilder =
    SalesLineLocalCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> saleId,
      Value<String> itemId,
      Value<String> itemName,
      Value<int> quantity,
      Value<double> rate,
      Value<double> lineTotal,
      Value<double> cgstAmount,
      Value<double> sgstAmount,
      Value<double> igstAmount,
      Value<int> rowid,
    });

final class $$SalesLineLocalTableReferences
    extends BaseReferences<_$AppDatabase, $SalesLineLocalTable, SaleLineLocal> {
  $$SalesLineLocalTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SalesLocalTable _saleIdTable(_$AppDatabase db) =>
      db.salesLocal.createAlias('sales_line_local__sale_id__sales_local__id');

  $$SalesLocalTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<String>('sale_id')!;

    final manager = $$SalesLocalTableTableManager(
      $_db,
      $_db.salesLocal,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SalesLineLocalTableFilterComposer
    extends Composer<_$AppDatabase, $SalesLineLocalTable> {
  $$SalesLineLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lineTotal => $composableBuilder(
    column: $table.lineTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesLocalTableFilterComposer get saleId {
    final $$SalesLocalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesLocal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesLocalTableFilterComposer(
            $db: $db,
            $table: $db.salesLocal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesLineLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesLineLocalTable> {
  $$SalesLineLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lineTotal => $composableBuilder(
    column: $table.lineTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesLocalTableOrderingComposer get saleId {
    final $$SalesLocalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesLocal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesLocalTableOrderingComposer(
            $db: $db,
            $table: $db.salesLocal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesLineLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesLineLocalTable> {
  $$SalesLineLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<double> get lineTotal =>
      $composableBuilder(column: $table.lineTotal, builder: (column) => column);

  GeneratedColumn<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => column,
  );

  $$SalesLocalTableAnnotationComposer get saleId {
    final $$SalesLocalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesLocal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesLocalTableAnnotationComposer(
            $db: $db,
            $table: $db.salesLocal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesLineLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesLineLocalTable,
          SaleLineLocal,
          $$SalesLineLocalTableFilterComposer,
          $$SalesLineLocalTableOrderingComposer,
          $$SalesLineLocalTableAnnotationComposer,
          $$SalesLineLocalTableCreateCompanionBuilder,
          $$SalesLineLocalTableUpdateCompanionBuilder,
          (SaleLineLocal, $$SalesLineLocalTableReferences),
          SaleLineLocal,
          PrefetchHooks Function({bool saleId})
        > {
  $$SalesLineLocalTableTableManager(
    _$AppDatabase db,
    $SalesLineLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesLineLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesLineLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesLineLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<double> lineTotal = const Value.absent(),
                Value<double> cgstAmount = const Value.absent(),
                Value<double> sgstAmount = const Value.absent(),
                Value<double> igstAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesLineLocalCompanion(
                id: id,
                businessId: businessId,
                saleId: saleId,
                itemId: itemId,
                itemName: itemName,
                quantity: quantity,
                rate: rate,
                lineTotal: lineTotal,
                cgstAmount: cgstAmount,
                sgstAmount: sgstAmount,
                igstAmount: igstAmount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String saleId,
                required String itemId,
                required String itemName,
                required int quantity,
                required double rate,
                required double lineTotal,
                required double cgstAmount,
                required double sgstAmount,
                required double igstAmount,
                Value<int> rowid = const Value.absent(),
              }) => SalesLineLocalCompanion.insert(
                id: id,
                businessId: businessId,
                saleId: saleId,
                itemId: itemId,
                itemName: itemName,
                quantity: quantity,
                rate: rate,
                lineTotal: lineTotal,
                cgstAmount: cgstAmount,
                sgstAmount: sgstAmount,
                igstAmount: igstAmount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SalesLineLocalTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (saleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.saleId,
                                referencedTable: $$SalesLineLocalTableReferences
                                    ._saleIdTable(db),
                                referencedColumn:
                                    $$SalesLineLocalTableReferences
                                        ._saleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SalesLineLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesLineLocalTable,
      SaleLineLocal,
      $$SalesLineLocalTableFilterComposer,
      $$SalesLineLocalTableOrderingComposer,
      $$SalesLineLocalTableAnnotationComposer,
      $$SalesLineLocalTableCreateCompanionBuilder,
      $$SalesLineLocalTableUpdateCompanionBuilder,
      (SaleLineLocal, $$SalesLineLocalTableReferences),
      SaleLineLocal,
      PrefetchHooks Function({bool saleId})
    >;
typedef $$HeldBillsLocalTableCreateCompanionBuilder =
    HeldBillsLocalCompanion Function({
      required String id,
      required String businessId,
      required String itemsJson,
      Value<String> paymentsJson,
      Value<String?> customerName,
      Value<String?> notes,
      required DateTime heldAt,
      Value<int> rowid,
    });
typedef $$HeldBillsLocalTableUpdateCompanionBuilder =
    HeldBillsLocalCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> itemsJson,
      Value<String> paymentsJson,
      Value<String?> customerName,
      Value<String?> notes,
      Value<DateTime> heldAt,
      Value<int> rowid,
    });

class $$HeldBillsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $HeldBillsLocalTable> {
  $$HeldBillsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentsJson => $composableBuilder(
    column: $table.paymentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get heldAt => $composableBuilder(
    column: $table.heldAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HeldBillsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $HeldBillsLocalTable> {
  $$HeldBillsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentsJson => $composableBuilder(
    column: $table.paymentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get heldAt => $composableBuilder(
    column: $table.heldAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HeldBillsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeldBillsLocalTable> {
  $$HeldBillsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<String> get paymentsJson => $composableBuilder(
    column: $table.paymentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get heldAt =>
      $composableBuilder(column: $table.heldAt, builder: (column) => column);
}

class $$HeldBillsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HeldBillsLocalTable,
          HeldBillsLocalData,
          $$HeldBillsLocalTableFilterComposer,
          $$HeldBillsLocalTableOrderingComposer,
          $$HeldBillsLocalTableAnnotationComposer,
          $$HeldBillsLocalTableCreateCompanionBuilder,
          $$HeldBillsLocalTableUpdateCompanionBuilder,
          (
            HeldBillsLocalData,
            BaseReferences<
              _$AppDatabase,
              $HeldBillsLocalTable,
              HeldBillsLocalData
            >,
          ),
          HeldBillsLocalData,
          PrefetchHooks Function()
        > {
  $$HeldBillsLocalTableTableManager(
    _$AppDatabase db,
    $HeldBillsLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeldBillsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeldBillsLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeldBillsLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<String> paymentsJson = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> heldAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HeldBillsLocalCompanion(
                id: id,
                businessId: businessId,
                itemsJson: itemsJson,
                paymentsJson: paymentsJson,
                customerName: customerName,
                notes: notes,
                heldAt: heldAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String itemsJson,
                Value<String> paymentsJson = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime heldAt,
                Value<int> rowid = const Value.absent(),
              }) => HeldBillsLocalCompanion.insert(
                id: id,
                businessId: businessId,
                itemsJson: itemsJson,
                paymentsJson: paymentsJson,
                customerName: customerName,
                notes: notes,
                heldAt: heldAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HeldBillsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HeldBillsLocalTable,
      HeldBillsLocalData,
      $$HeldBillsLocalTableFilterComposer,
      $$HeldBillsLocalTableOrderingComposer,
      $$HeldBillsLocalTableAnnotationComposer,
      $$HeldBillsLocalTableCreateCompanionBuilder,
      $$HeldBillsLocalTableUpdateCompanionBuilder,
      (
        HeldBillsLocalData,
        BaseReferences<_$AppDatabase, $HeldBillsLocalTable, HeldBillsLocalData>,
      ),
      HeldBillsLocalData,
      PrefetchHooks Function()
    >;
typedef $$LeadsTableCreateCompanionBuilder =
    LeadsCompanion Function({
      required String id,
      required String businessId,
      required String name,
      Value<String?> company,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> leadSource,
      Value<String> status,
      Value<String?> assignedTo,
      Value<String?> notes,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String> deviceId,
      Value<String> syncStatus,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$LeadsTableUpdateCompanionBuilder =
    LeadsCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> name,
      Value<String?> company,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> leadSource,
      Value<String> status,
      Value<String?> assignedTo,
      Value<String?> notes,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> deviceId,
      Value<String> syncStatus,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$LeadsTableFilterComposer extends Composer<_$AppDatabase, $LeadsTable> {
  $$LeadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leadSource => $composableBuilder(
    column: $table.leadSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeadsTableOrderingComposer
    extends Composer<_$AppDatabase, $LeadsTable> {
  $$LeadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leadSource => $composableBuilder(
    column: $table.leadSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeadsTable> {
  $$LeadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get leadSource => $composableBuilder(
    column: $table.leadSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LeadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeadsTable,
          LeadTableData,
          $$LeadsTableFilterComposer,
          $$LeadsTableOrderingComposer,
          $$LeadsTableAnnotationComposer,
          $$LeadsTableCreateCompanionBuilder,
          $$LeadsTableUpdateCompanionBuilder,
          (
            LeadTableData,
            BaseReferences<_$AppDatabase, $LeadsTable, LeadTableData>,
          ),
          LeadTableData,
          PrefetchHooks Function()
        > {
  $$LeadsTableTableManager(_$AppDatabase db, $LeadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> leadSource = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeadsCompanion(
                id: id,
                businessId: businessId,
                name: name,
                company: company,
                phone: phone,
                email: email,
                leadSource: leadSource,
                status: status,
                assignedTo: assignedTo,
                notes: notes,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String name,
                Value<String?> company = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> leadSource = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LeadsCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                company: company,
                phone: phone,
                email: email,
                leadSource: leadSource,
                status: status,
                assignedTo: assignedTo,
                notes: notes,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeadsTable,
      LeadTableData,
      $$LeadsTableFilterComposer,
      $$LeadsTableOrderingComposer,
      $$LeadsTableAnnotationComposer,
      $$LeadsTableCreateCompanionBuilder,
      $$LeadsTableUpdateCompanionBuilder,
      (
        LeadTableData,
        BaseReferences<_$AppDatabase, $LeadsTable, LeadTableData>,
      ),
      LeadTableData,
      PrefetchHooks Function()
    >;
typedef $$LeadActivitiesTableCreateCompanionBuilder =
    LeadActivitiesCompanion Function({
      required String id,
      required String leadId,
      required String businessId,
      required String type,
      Value<String?> notes,
      Value<String?> addedBy,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String> deviceId,
      Value<String> syncStatus,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$LeadActivitiesTableUpdateCompanionBuilder =
    LeadActivitiesCompanion Function({
      Value<String> id,
      Value<String> leadId,
      Value<String> businessId,
      Value<String> type,
      Value<String?> notes,
      Value<String?> addedBy,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> deviceId,
      Value<String> syncStatus,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$LeadActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $LeadActivitiesTable> {
  $$LeadActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leadId => $composableBuilder(
    column: $table.leadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedBy => $composableBuilder(
    column: $table.addedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeadActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $LeadActivitiesTable> {
  $$LeadActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leadId => $composableBuilder(
    column: $table.leadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedBy => $composableBuilder(
    column: $table.addedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeadActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeadActivitiesTable> {
  $$LeadActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get leadId =>
      $composableBuilder(column: $table.leadId, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get addedBy =>
      $composableBuilder(column: $table.addedBy, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LeadActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeadActivitiesTable,
          LeadActivityTableData,
          $$LeadActivitiesTableFilterComposer,
          $$LeadActivitiesTableOrderingComposer,
          $$LeadActivitiesTableAnnotationComposer,
          $$LeadActivitiesTableCreateCompanionBuilder,
          $$LeadActivitiesTableUpdateCompanionBuilder,
          (
            LeadActivityTableData,
            BaseReferences<
              _$AppDatabase,
              $LeadActivitiesTable,
              LeadActivityTableData
            >,
          ),
          LeadActivityTableData,
          PrefetchHooks Function()
        > {
  $$LeadActivitiesTableTableManager(
    _$AppDatabase db,
    $LeadActivitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeadActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeadActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeadActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> leadId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> addedBy = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeadActivitiesCompanion(
                id: id,
                leadId: leadId,
                businessId: businessId,
                type: type,
                notes: notes,
                addedBy: addedBy,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String leadId,
                required String businessId,
                required String type,
                Value<String?> notes = const Value.absent(),
                Value<String?> addedBy = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LeadActivitiesCompanion.insert(
                id: id,
                leadId: leadId,
                businessId: businessId,
                type: type,
                notes: notes,
                addedBy: addedBy,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeadActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeadActivitiesTable,
      LeadActivityTableData,
      $$LeadActivitiesTableFilterComposer,
      $$LeadActivitiesTableOrderingComposer,
      $$LeadActivitiesTableAnnotationComposer,
      $$LeadActivitiesTableCreateCompanionBuilder,
      $$LeadActivitiesTableUpdateCompanionBuilder,
      (
        LeadActivityTableData,
        BaseReferences<
          _$AppDatabase,
          $LeadActivitiesTable,
          LeadActivityTableData
        >,
      ),
      LeadActivityTableData,
      PrefetchHooks Function()
    >;
typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      required String id,
      required String businessId,
      required String name,
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String?> salutation,
      Value<String?> accountName,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> assignedTo,
      Value<String?> title,
      Value<String?> description,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String> deviceId,
      Value<String> syncStatus,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> name,
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String?> salutation,
      Value<String?> accountName,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> assignedTo,
      Value<String?> title,
      Value<String?> description,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> deviceId,
      Value<String> syncStatus,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salutation => $composableBuilder(
    column: $table.salutation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salutation => $composableBuilder(
    column: $table.salutation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get salutation => $composableBuilder(
    column: $table.salutation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          ContactTableData,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (
            ContactTableData,
            BaseReferences<_$AppDatabase, $ContactsTable, ContactTableData>,
          ),
          ContactTableData,
          PrefetchHooks Function()
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> salutation = const Value.absent(),
                Value<String?> accountName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                businessId: businessId,
                name: name,
                firstName: firstName,
                lastName: lastName,
                salutation: salutation,
                accountName: accountName,
                phone: phone,
                email: email,
                assignedTo: assignedTo,
                title: title,
                description: description,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String name,
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> salutation = const Value.absent(),
                Value<String?> accountName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                firstName: firstName,
                lastName: lastName,
                salutation: salutation,
                accountName: accountName,
                phone: phone,
                email: email,
                assignedTo: assignedTo,
                title: title,
                description: description,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      ContactTableData,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (
        ContactTableData,
        BaseReferences<_$AppDatabase, $ContactsTable, ContactTableData>,
      ),
      ContactTableData,
      PrefetchHooks Function()
    >;
typedef $$ContactActivitiesTableCreateCompanionBuilder =
    ContactActivitiesCompanion Function({
      required String id,
      required String contactId,
      required String businessId,
      required String type,
      Value<String?> notes,
      Value<String?> addedBy,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String> deviceId,
      Value<String> syncStatus,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$ContactActivitiesTableUpdateCompanionBuilder =
    ContactActivitiesCompanion Function({
      Value<String> id,
      Value<String> contactId,
      Value<String> businessId,
      Value<String> type,
      Value<String?> notes,
      Value<String?> addedBy,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> deviceId,
      Value<String> syncStatus,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$ContactActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ContactActivitiesTable> {
  $$ContactActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedBy => $composableBuilder(
    column: $table.addedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactActivitiesTable> {
  $$ContactActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedBy => $composableBuilder(
    column: $table.addedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactActivitiesTable> {
  $$ContactActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get addedBy =>
      $composableBuilder(column: $table.addedBy, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ContactActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactActivitiesTable,
          ContactActivityTableData,
          $$ContactActivitiesTableFilterComposer,
          $$ContactActivitiesTableOrderingComposer,
          $$ContactActivitiesTableAnnotationComposer,
          $$ContactActivitiesTableCreateCompanionBuilder,
          $$ContactActivitiesTableUpdateCompanionBuilder,
          (
            ContactActivityTableData,
            BaseReferences<
              _$AppDatabase,
              $ContactActivitiesTable,
              ContactActivityTableData
            >,
          ),
          ContactActivityTableData,
          PrefetchHooks Function()
        > {
  $$ContactActivitiesTableTableManager(
    _$AppDatabase db,
    $ContactActivitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactActivitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contactId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> addedBy = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactActivitiesCompanion(
                id: id,
                contactId: contactId,
                businessId: businessId,
                type: type,
                notes: notes,
                addedBy: addedBy,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String contactId,
                required String businessId,
                required String type,
                Value<String?> notes = const Value.absent(),
                Value<String?> addedBy = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ContactActivitiesCompanion.insert(
                id: id,
                contactId: contactId,
                businessId: businessId,
                type: type,
                notes: notes,
                addedBy: addedBy,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactActivitiesTable,
      ContactActivityTableData,
      $$ContactActivitiesTableFilterComposer,
      $$ContactActivitiesTableOrderingComposer,
      $$ContactActivitiesTableAnnotationComposer,
      $$ContactActivitiesTableCreateCompanionBuilder,
      $$ContactActivitiesTableUpdateCompanionBuilder,
      (
        ContactActivityTableData,
        BaseReferences<
          _$AppDatabase,
          $ContactActivitiesTable,
          ContactActivityTableData
        >,
      ),
      ContactActivityTableData,
      PrefetchHooks Function()
    >;
typedef $$DealsTableCreateCompanionBuilder =
    DealsCompanion Function({
      required String id,
      required String businessId,
      required String name,
      required String stage,
      Value<String?> accountName,
      Value<String?> assignedTo,
      Value<double> amount,
      Value<String?> expectedCloseDate,
      Value<String?> description,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String> deviceId,
      Value<String> syncStatus,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$DealsTableUpdateCompanionBuilder =
    DealsCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> name,
      Value<String> stage,
      Value<String?> accountName,
      Value<String?> assignedTo,
      Value<double> amount,
      Value<String?> expectedCloseDate,
      Value<String?> description,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> deviceId,
      Value<String> syncStatus,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$DealsTableFilterComposer extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedCloseDate => $composableBuilder(
    column: $table.expectedCloseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DealsTableOrderingComposer
    extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedCloseDate => $composableBuilder(
    column: $table.expectedCloseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DealsTable> {
  $$DealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get expectedCloseDate => $composableBuilder(
    column: $table.expectedCloseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DealsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DealsTable,
          DealTableData,
          $$DealsTableFilterComposer,
          $$DealsTableOrderingComposer,
          $$DealsTableAnnotationComposer,
          $$DealsTableCreateCompanionBuilder,
          $$DealsTableUpdateCompanionBuilder,
          (
            DealTableData,
            BaseReferences<_$AppDatabase, $DealsTable, DealTableData>,
          ),
          DealTableData,
          PrefetchHooks Function()
        > {
  $$DealsTableTableManager(_$AppDatabase db, $DealsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String?> accountName = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> expectedCloseDate = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DealsCompanion(
                id: id,
                businessId: businessId,
                name: name,
                stage: stage,
                accountName: accountName,
                assignedTo: assignedTo,
                amount: amount,
                expectedCloseDate: expectedCloseDate,
                description: description,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String name,
                required String stage,
                Value<String?> accountName = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> expectedCloseDate = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DealsCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                stage: stage,
                accountName: accountName,
                assignedTo: assignedTo,
                amount: amount,
                expectedCloseDate: expectedCloseDate,
                description: description,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DealsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DealsTable,
      DealTableData,
      $$DealsTableFilterComposer,
      $$DealsTableOrderingComposer,
      $$DealsTableAnnotationComposer,
      $$DealsTableCreateCompanionBuilder,
      $$DealsTableUpdateCompanionBuilder,
      (
        DealTableData,
        BaseReferences<_$AppDatabase, $DealsTable, DealTableData>,
      ),
      DealTableData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      required String id,
      required String mutationId,
      required String kind,
      required String entityType,
      Value<String?> entityId,
      required String operation,
      required String payload,
      required String businessId,
      Value<String?> deviceId,
      Value<String?> commandId,
      required String status,
      Value<int> priority,
      Value<int> attemptCount,
      required DateTime createdAt,
      Value<DateTime?> scheduledAt,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> id,
      Value<String> mutationId,
      Value<String> kind,
      Value<String> entityType,
      Value<String?> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<String> businessId,
      Value<String?> deviceId,
      Value<String?> commandId,
      Value<String> status,
      Value<int> priority,
      Value<int> attemptCount,
      Value<DateTime> createdAt,
      Value<DateTime?> scheduledAt,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get commandId =>
      $composableBuilder(column: $table.commandId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> commandId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                mutationId: mutationId,
                kind: kind,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                businessId: businessId,
                deviceId: deviceId,
                commandId: commandId,
                status: status,
                priority: priority,
                attemptCount: attemptCount,
                createdAt: createdAt,
                scheduledAt: scheduledAt,
                lastAttemptAt: lastAttemptAt,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mutationId,
                required String kind,
                required String entityType,
                Value<String?> entityId = const Value.absent(),
                required String operation,
                required String payload,
                required String businessId,
                Value<String?> deviceId = const Value.absent(),
                Value<String?> commandId = const Value.absent(),
                required String status,
                Value<int> priority = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                mutationId: mutationId,
                kind: kind,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                businessId: businessId,
                deviceId: deviceId,
                commandId: commandId,
                status: status,
                priority: priority,
                attemptCount: attemptCount,
                createdAt: createdAt,
                scheduledAt: scheduledAt,
                lastAttemptAt: lastAttemptAt,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$CategoriesLocalTableCreateCompanionBuilder =
    CategoriesLocalCompanion Function({
      required String id,
      required String businessId,
      required String name,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> itemCount,
      Value<int> rowid,
    });
typedef $$CategoriesLocalTableUpdateCompanionBuilder =
    CategoriesLocalCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> name,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> itemCount,
      Value<int> rowid,
    });

class $$CategoriesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesLocalTable> {
  $$CategoriesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesLocalTable> {
  $$CategoriesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesLocalTable> {
  $$CategoriesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);
}

class $$CategoriesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesLocalTable,
          CategoryTableData,
          $$CategoriesLocalTableFilterComposer,
          $$CategoriesLocalTableOrderingComposer,
          $$CategoriesLocalTableAnnotationComposer,
          $$CategoriesLocalTableCreateCompanionBuilder,
          $$CategoriesLocalTableUpdateCompanionBuilder,
          (
            CategoryTableData,
            BaseReferences<
              _$AppDatabase,
              $CategoriesLocalTable,
              CategoryTableData
            >,
          ),
          CategoryTableData,
          PrefetchHooks Function()
        > {
  $$CategoriesLocalTableTableManager(
    _$AppDatabase db,
    $CategoriesLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesLocalCompanion(
                id: id,
                businessId: businessId,
                name: name,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                itemCount: itemCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String name,
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesLocalCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                itemCount: itemCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesLocalTable,
      CategoryTableData,
      $$CategoriesLocalTableFilterComposer,
      $$CategoriesLocalTableOrderingComposer,
      $$CategoriesLocalTableAnnotationComposer,
      $$CategoriesLocalTableCreateCompanionBuilder,
      $$CategoriesLocalTableUpdateCompanionBuilder,
      (
        CategoryTableData,
        BaseReferences<_$AppDatabase, $CategoriesLocalTable, CategoryTableData>,
      ),
      CategoryTableData,
      PrefetchHooks Function()
    >;
typedef $$PartiesLocalTableCreateCompanionBuilder =
    PartiesLocalCompanion Function({
      required String id,
      required String businessId,
      required String name,
      Value<String?> legalName,
      Value<String?> alias,
      Value<String?> mobile,
      Value<String?> email,
      Value<String?> partyGroup,
      Value<String?> areaCode,
      Value<String> partyType,
      Value<String?> partyCategory,
      Value<String> pricingTier,
      Value<String?> gstin,
      Value<String?> stateCode,
      Value<String?> areaId,
      Value<String> creditLimit,
      Value<String> openingBalance,
      Value<String> hiddenLedgerBalance,
      Value<String?> profileImageUrl,
      Value<String?> profileMediaAssetId,
      Value<String?> connectedSince,
      Value<String?> notes,
      Value<bool> isActive,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$PartiesLocalTableUpdateCompanionBuilder =
    PartiesLocalCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> name,
      Value<String?> legalName,
      Value<String?> alias,
      Value<String?> mobile,
      Value<String?> email,
      Value<String?> partyGroup,
      Value<String?> areaCode,
      Value<String> partyType,
      Value<String?> partyCategory,
      Value<String> pricingTier,
      Value<String?> gstin,
      Value<String?> stateCode,
      Value<String?> areaId,
      Value<String> creditLimit,
      Value<String> openingBalance,
      Value<String> hiddenLedgerBalance,
      Value<String?> profileImageUrl,
      Value<String?> profileMediaAssetId,
      Value<String?> connectedSince,
      Value<String?> notes,
      Value<bool> isActive,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$PartiesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesLocalTable> {
  $$PartiesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalName => $composableBuilder(
    column: $table.legalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyGroup => $composableBuilder(
    column: $table.partyGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaCode => $composableBuilder(
    column: $table.areaCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyType => $composableBuilder(
    column: $table.partyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyCategory => $composableBuilder(
    column: $table.partyCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pricingTier => $composableBuilder(
    column: $table.pricingTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hiddenLedgerBalance => $composableBuilder(
    column: $table.hiddenLedgerBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileImageUrl => $composableBuilder(
    column: $table.profileImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileMediaAssetId => $composableBuilder(
    column: $table.profileMediaAssetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectedSince => $composableBuilder(
    column: $table.connectedSince,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartiesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesLocalTable> {
  $$PartiesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalName => $composableBuilder(
    column: $table.legalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyGroup => $composableBuilder(
    column: $table.partyGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaCode => $composableBuilder(
    column: $table.areaCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyType => $composableBuilder(
    column: $table.partyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyCategory => $composableBuilder(
    column: $table.partyCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricingTier => $composableBuilder(
    column: $table.pricingTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hiddenLedgerBalance => $composableBuilder(
    column: $table.hiddenLedgerBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileImageUrl => $composableBuilder(
    column: $table.profileImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileMediaAssetId => $composableBuilder(
    column: $table.profileMediaAssetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectedSince => $composableBuilder(
    column: $table.connectedSince,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartiesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesLocalTable> {
  $$PartiesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get legalName =>
      $composableBuilder(column: $table.legalName, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get mobile =>
      $composableBuilder(column: $table.mobile, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get partyGroup => $composableBuilder(
    column: $table.partyGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get areaCode =>
      $composableBuilder(column: $table.areaCode, builder: (column) => column);

  GeneratedColumn<String> get partyType =>
      $composableBuilder(column: $table.partyType, builder: (column) => column);

  GeneratedColumn<String> get partyCategory => $composableBuilder(
    column: $table.partyCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pricingTier => $composableBuilder(
    column: $table.pricingTier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<String> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hiddenLedgerBalance => $composableBuilder(
    column: $table.hiddenLedgerBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileImageUrl => $composableBuilder(
    column: $table.profileImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileMediaAssetId => $composableBuilder(
    column: $table.profileMediaAssetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get connectedSince => $composableBuilder(
    column: $table.connectedSince,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$PartiesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartiesLocalTable,
          PartyTableData,
          $$PartiesLocalTableFilterComposer,
          $$PartiesLocalTableOrderingComposer,
          $$PartiesLocalTableAnnotationComposer,
          $$PartiesLocalTableCreateCompanionBuilder,
          $$PartiesLocalTableUpdateCompanionBuilder,
          (
            PartyTableData,
            BaseReferences<_$AppDatabase, $PartiesLocalTable, PartyTableData>,
          ),
          PartyTableData,
          PrefetchHooks Function()
        > {
  $$PartiesLocalTableTableManager(_$AppDatabase db, $PartiesLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartiesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartiesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartiesLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> legalName = const Value.absent(),
                Value<String?> alias = const Value.absent(),
                Value<String?> mobile = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> partyGroup = const Value.absent(),
                Value<String?> areaCode = const Value.absent(),
                Value<String> partyType = const Value.absent(),
                Value<String?> partyCategory = const Value.absent(),
                Value<String> pricingTier = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> stateCode = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<String> creditLimit = const Value.absent(),
                Value<String> openingBalance = const Value.absent(),
                Value<String> hiddenLedgerBalance = const Value.absent(),
                Value<String?> profileImageUrl = const Value.absent(),
                Value<String?> profileMediaAssetId = const Value.absent(),
                Value<String?> connectedSince = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesLocalCompanion(
                id: id,
                businessId: businessId,
                name: name,
                legalName: legalName,
                alias: alias,
                mobile: mobile,
                email: email,
                partyGroup: partyGroup,
                areaCode: areaCode,
                partyType: partyType,
                partyCategory: partyCategory,
                pricingTier: pricingTier,
                gstin: gstin,
                stateCode: stateCode,
                areaId: areaId,
                creditLimit: creditLimit,
                openingBalance: openingBalance,
                hiddenLedgerBalance: hiddenLedgerBalance,
                profileImageUrl: profileImageUrl,
                profileMediaAssetId: profileMediaAssetId,
                connectedSince: connectedSince,
                notes: notes,
                isActive: isActive,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String name,
                Value<String?> legalName = const Value.absent(),
                Value<String?> alias = const Value.absent(),
                Value<String?> mobile = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> partyGroup = const Value.absent(),
                Value<String?> areaCode = const Value.absent(),
                Value<String> partyType = const Value.absent(),
                Value<String?> partyCategory = const Value.absent(),
                Value<String> pricingTier = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> stateCode = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<String> creditLimit = const Value.absent(),
                Value<String> openingBalance = const Value.absent(),
                Value<String> hiddenLedgerBalance = const Value.absent(),
                Value<String?> profileImageUrl = const Value.absent(),
                Value<String?> profileMediaAssetId = const Value.absent(),
                Value<String?> connectedSince = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesLocalCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                legalName: legalName,
                alias: alias,
                mobile: mobile,
                email: email,
                partyGroup: partyGroup,
                areaCode: areaCode,
                partyType: partyType,
                partyCategory: partyCategory,
                pricingTier: pricingTier,
                gstin: gstin,
                stateCode: stateCode,
                areaId: areaId,
                creditLimit: creditLimit,
                openingBalance: openingBalance,
                hiddenLedgerBalance: hiddenLedgerBalance,
                profileImageUrl: profileImageUrl,
                profileMediaAssetId: profileMediaAssetId,
                connectedSince: connectedSince,
                notes: notes,
                isActive: isActive,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartiesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartiesLocalTable,
      PartyTableData,
      $$PartiesLocalTableFilterComposer,
      $$PartiesLocalTableOrderingComposer,
      $$PartiesLocalTableAnnotationComposer,
      $$PartiesLocalTableCreateCompanionBuilder,
      $$PartiesLocalTableUpdateCompanionBuilder,
      (
        PartyTableData,
        BaseReferences<_$AppDatabase, $PartiesLocalTable, PartyTableData>,
      ),
      PartyTableData,
      PrefetchHooks Function()
    >;
typedef $$ItemsLocalTableCreateCompanionBuilder =
    ItemsLocalCompanion Function({
      required String id,
      required String businessId,
      required String name,
      Value<String?> shortName,
      Value<String?> alias,
      Value<String?> searchKeywords,
      Value<String?> description,
      Value<String> itemType,
      Value<bool> hasStockTracking,
      Value<String?> categoryId,
      Value<String?> brandId,
      Value<String?> hsnCode,
      Value<String?> barcode,
      Value<String> baseUnit,
      Value<String?> mrp,
      Value<bool> isMrpOnly,
      Value<String?> marketPrice,
      Value<String> salePrice,
      Value<String> purchasePrice,
      Value<String?> reorderLevel,
      Value<String?> defaultTaxRate,
      Value<String?> primaryImageUrl,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$ItemsLocalTableUpdateCompanionBuilder =
    ItemsLocalCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> name,
      Value<String?> shortName,
      Value<String?> alias,
      Value<String?> searchKeywords,
      Value<String?> description,
      Value<String> itemType,
      Value<bool> hasStockTracking,
      Value<String?> categoryId,
      Value<String?> brandId,
      Value<String?> hsnCode,
      Value<String?> barcode,
      Value<String> baseUnit,
      Value<String?> mrp,
      Value<bool> isMrpOnly,
      Value<String?> marketPrice,
      Value<String> salePrice,
      Value<String> purchasePrice,
      Value<String?> reorderLevel,
      Value<String?> defaultTaxRate,
      Value<String?> primaryImageUrl,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$ItemsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $ItemsLocalTable> {
  $$ItemsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKeywords => $composableBuilder(
    column: $table.searchKeywords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasStockTracking => $composableBuilder(
    column: $table.hasStockTracking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandId => $composableBuilder(
    column: $table.brandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hsnCode => $composableBuilder(
    column: $table.hsnCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mrp => $composableBuilder(
    column: $table.mrp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMrpOnly => $composableBuilder(
    column: $table.isMrpOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marketPrice => $composableBuilder(
    column: $table.marketPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultTaxRate => $composableBuilder(
    column: $table.defaultTaxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryImageUrl => $composableBuilder(
    column: $table.primaryImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsLocalTable> {
  $$ItemsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKeywords => $composableBuilder(
    column: $table.searchKeywords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasStockTracking => $composableBuilder(
    column: $table.hasStockTracking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandId => $composableBuilder(
    column: $table.brandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hsnCode => $composableBuilder(
    column: $table.hsnCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mrp => $composableBuilder(
    column: $table.mrp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMrpOnly => $composableBuilder(
    column: $table.isMrpOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marketPrice => $composableBuilder(
    column: $table.marketPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultTaxRate => $composableBuilder(
    column: $table.defaultTaxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryImageUrl => $composableBuilder(
    column: $table.primaryImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsLocalTable> {
  $$ItemsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get searchKeywords => $composableBuilder(
    column: $table.searchKeywords,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<bool> get hasStockTracking => $composableBuilder(
    column: $table.hasStockTracking,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brandId =>
      $composableBuilder(column: $table.brandId, builder: (column) => column);

  GeneratedColumn<String> get hsnCode =>
      $composableBuilder(column: $table.hsnCode, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get baseUnit =>
      $composableBuilder(column: $table.baseUnit, builder: (column) => column);

  GeneratedColumn<String> get mrp =>
      $composableBuilder(column: $table.mrp, builder: (column) => column);

  GeneratedColumn<bool> get isMrpOnly =>
      $composableBuilder(column: $table.isMrpOnly, builder: (column) => column);

  GeneratedColumn<String> get marketPrice => $composableBuilder(
    column: $table.marketPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<String> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultTaxRate => $composableBuilder(
    column: $table.defaultTaxRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryImageUrl => $composableBuilder(
    column: $table.primaryImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$ItemsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsLocalTable,
          ItemTableData,
          $$ItemsLocalTableFilterComposer,
          $$ItemsLocalTableOrderingComposer,
          $$ItemsLocalTableAnnotationComposer,
          $$ItemsLocalTableCreateCompanionBuilder,
          $$ItemsLocalTableUpdateCompanionBuilder,
          (
            ItemTableData,
            BaseReferences<_$AppDatabase, $ItemsLocalTable, ItemTableData>,
          ),
          ItemTableData,
          PrefetchHooks Function()
        > {
  $$ItemsLocalTableTableManager(_$AppDatabase db, $ItemsLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> shortName = const Value.absent(),
                Value<String?> alias = const Value.absent(),
                Value<String?> searchKeywords = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<bool> hasStockTracking = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> brandId = const Value.absent(),
                Value<String?> hsnCode = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> baseUnit = const Value.absent(),
                Value<String?> mrp = const Value.absent(),
                Value<bool> isMrpOnly = const Value.absent(),
                Value<String?> marketPrice = const Value.absent(),
                Value<String> salePrice = const Value.absent(),
                Value<String> purchasePrice = const Value.absent(),
                Value<String?> reorderLevel = const Value.absent(),
                Value<String?> defaultTaxRate = const Value.absent(),
                Value<String?> primaryImageUrl = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsLocalCompanion(
                id: id,
                businessId: businessId,
                name: name,
                shortName: shortName,
                alias: alias,
                searchKeywords: searchKeywords,
                description: description,
                itemType: itemType,
                hasStockTracking: hasStockTracking,
                categoryId: categoryId,
                brandId: brandId,
                hsnCode: hsnCode,
                barcode: barcode,
                baseUnit: baseUnit,
                mrp: mrp,
                isMrpOnly: isMrpOnly,
                marketPrice: marketPrice,
                salePrice: salePrice,
                purchasePrice: purchasePrice,
                reorderLevel: reorderLevel,
                defaultTaxRate: defaultTaxRate,
                primaryImageUrl: primaryImageUrl,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String name,
                Value<String?> shortName = const Value.absent(),
                Value<String?> alias = const Value.absent(),
                Value<String?> searchKeywords = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<bool> hasStockTracking = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> brandId = const Value.absent(),
                Value<String?> hsnCode = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> baseUnit = const Value.absent(),
                Value<String?> mrp = const Value.absent(),
                Value<bool> isMrpOnly = const Value.absent(),
                Value<String?> marketPrice = const Value.absent(),
                Value<String> salePrice = const Value.absent(),
                Value<String> purchasePrice = const Value.absent(),
                Value<String?> reorderLevel = const Value.absent(),
                Value<String?> defaultTaxRate = const Value.absent(),
                Value<String?> primaryImageUrl = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsLocalCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                shortName: shortName,
                alias: alias,
                searchKeywords: searchKeywords,
                description: description,
                itemType: itemType,
                hasStockTracking: hasStockTracking,
                categoryId: categoryId,
                brandId: brandId,
                hsnCode: hsnCode,
                barcode: barcode,
                baseUnit: baseUnit,
                mrp: mrp,
                isMrpOnly: isMrpOnly,
                marketPrice: marketPrice,
                salePrice: salePrice,
                purchasePrice: purchasePrice,
                reorderLevel: reorderLevel,
                defaultTaxRate: defaultTaxRate,
                primaryImageUrl: primaryImageUrl,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsLocalTable,
      ItemTableData,
      $$ItemsLocalTableFilterComposer,
      $$ItemsLocalTableOrderingComposer,
      $$ItemsLocalTableAnnotationComposer,
      $$ItemsLocalTableCreateCompanionBuilder,
      $$ItemsLocalTableUpdateCompanionBuilder,
      (
        ItemTableData,
        BaseReferences<_$AppDatabase, $ItemsLocalTable, ItemTableData>,
      ),
      ItemTableData,
      PrefetchHooks Function()
    >;
typedef $$UnitDefinitionsLocalTableCreateCompanionBuilder =
    UnitDefinitionsLocalCompanion Function({
      required String id,
      required String businessId,
      required String name,
      required String shortName,
      Value<String?> symbol,
      Value<int> decimalPlaces,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$UnitDefinitionsLocalTableUpdateCompanionBuilder =
    UnitDefinitionsLocalCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> name,
      Value<String> shortName,
      Value<String?> symbol,
      Value<int> decimalPlaces,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$UnitDefinitionsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UnitDefinitionsLocalTable> {
  $$UnitDefinitionsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decimalPlaces => $composableBuilder(
    column: $table.decimalPlaces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnitDefinitionsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitDefinitionsLocalTable> {
  $$UnitDefinitionsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decimalPlaces => $composableBuilder(
    column: $table.decimalPlaces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitDefinitionsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitDefinitionsLocalTable> {
  $$UnitDefinitionsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<int> get decimalPlaces => $composableBuilder(
    column: $table.decimalPlaces,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$UnitDefinitionsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitDefinitionsLocalTable,
          UnitDefinitionTableData,
          $$UnitDefinitionsLocalTableFilterComposer,
          $$UnitDefinitionsLocalTableOrderingComposer,
          $$UnitDefinitionsLocalTableAnnotationComposer,
          $$UnitDefinitionsLocalTableCreateCompanionBuilder,
          $$UnitDefinitionsLocalTableUpdateCompanionBuilder,
          (
            UnitDefinitionTableData,
            BaseReferences<
              _$AppDatabase,
              $UnitDefinitionsLocalTable,
              UnitDefinitionTableData
            >,
          ),
          UnitDefinitionTableData,
          PrefetchHooks Function()
        > {
  $$UnitDefinitionsLocalTableTableManager(
    _$AppDatabase db,
    $UnitDefinitionsLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitDefinitionsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitDefinitionsLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UnitDefinitionsLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<String?> symbol = const Value.absent(),
                Value<int> decimalPlaces = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitDefinitionsLocalCompanion(
                id: id,
                businessId: businessId,
                name: name,
                shortName: shortName,
                symbol: symbol,
                decimalPlaces: decimalPlaces,
                isSystem: isSystem,
                isActive: isActive,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String name,
                required String shortName,
                Value<String?> symbol = const Value.absent(),
                Value<int> decimalPlaces = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitDefinitionsLocalCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                shortName: shortName,
                symbol: symbol,
                decimalPlaces: decimalPlaces,
                isSystem: isSystem,
                isActive: isActive,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnitDefinitionsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitDefinitionsLocalTable,
      UnitDefinitionTableData,
      $$UnitDefinitionsLocalTableFilterComposer,
      $$UnitDefinitionsLocalTableOrderingComposer,
      $$UnitDefinitionsLocalTableAnnotationComposer,
      $$UnitDefinitionsLocalTableCreateCompanionBuilder,
      $$UnitDefinitionsLocalTableUpdateCompanionBuilder,
      (
        UnitDefinitionTableData,
        BaseReferences<
          _$AppDatabase,
          $UnitDefinitionsLocalTable,
          UnitDefinitionTableData
        >,
      ),
      UnitDefinitionTableData,
      PrefetchHooks Function()
    >;
typedef $$TaxRatesLocalTableCreateCompanionBuilder =
    TaxRatesLocalCompanion Function({
      required String id,
      required String businessId,
      required String name,
      required String rate,
      Value<bool> isDefault,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$TaxRatesLocalTableUpdateCompanionBuilder =
    TaxRatesLocalCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> name,
      Value<String> rate,
      Value<bool> isDefault,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$TaxRatesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $TaxRatesLocalTable> {
  $$TaxRatesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaxRatesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $TaxRatesLocalTable> {
  $$TaxRatesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaxRatesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaxRatesLocalTable> {
  $$TaxRatesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$TaxRatesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaxRatesLocalTable,
          TaxRateTableData,
          $$TaxRatesLocalTableFilterComposer,
          $$TaxRatesLocalTableOrderingComposer,
          $$TaxRatesLocalTableAnnotationComposer,
          $$TaxRatesLocalTableCreateCompanionBuilder,
          $$TaxRatesLocalTableUpdateCompanionBuilder,
          (
            TaxRateTableData,
            BaseReferences<
              _$AppDatabase,
              $TaxRatesLocalTable,
              TaxRateTableData
            >,
          ),
          TaxRateTableData,
          PrefetchHooks Function()
        > {
  $$TaxRatesLocalTableTableManager(_$AppDatabase db, $TaxRatesLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaxRatesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaxRatesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaxRatesLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> rate = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxRatesLocalCompanion(
                id: id,
                businessId: businessId,
                name: name,
                rate: rate,
                isDefault: isDefault,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String name,
                required String rate,
                Value<bool> isDefault = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxRatesLocalCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                rate: rate,
                isDefault: isDefault,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaxRatesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaxRatesLocalTable,
      TaxRateTableData,
      $$TaxRatesLocalTableFilterComposer,
      $$TaxRatesLocalTableOrderingComposer,
      $$TaxRatesLocalTableAnnotationComposer,
      $$TaxRatesLocalTableCreateCompanionBuilder,
      $$TaxRatesLocalTableUpdateCompanionBuilder,
      (
        TaxRateTableData,
        BaseReferences<_$AppDatabase, $TaxRatesLocalTable, TaxRateTableData>,
      ),
      TaxRateTableData,
      PrefetchHooks Function()
    >;
typedef $$GodownsLocalTableCreateCompanionBuilder =
    GodownsLocalCompanion Function({
      required String id,
      required String businessId,
      required String name,
      Value<String?> address,
      Value<bool> isDefault,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$GodownsLocalTableUpdateCompanionBuilder =
    GodownsLocalCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> name,
      Value<String?> address,
      Value<bool> isDefault,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$GodownsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $GodownsLocalTable> {
  $$GodownsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GodownsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $GodownsLocalTable> {
  $$GodownsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GodownsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $GodownsLocalTable> {
  $$GodownsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$GodownsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GodownsLocalTable,
          GodownTableData,
          $$GodownsLocalTableFilterComposer,
          $$GodownsLocalTableOrderingComposer,
          $$GodownsLocalTableAnnotationComposer,
          $$GodownsLocalTableCreateCompanionBuilder,
          $$GodownsLocalTableUpdateCompanionBuilder,
          (
            GodownTableData,
            BaseReferences<_$AppDatabase, $GodownsLocalTable, GodownTableData>,
          ),
          GodownTableData,
          PrefetchHooks Function()
        > {
  $$GodownsLocalTableTableManager(_$AppDatabase db, $GodownsLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GodownsLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GodownsLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GodownsLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GodownsLocalCompanion(
                id: id,
                businessId: businessId,
                name: name,
                address: address,
                isDefault: isDefault,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String name,
                Value<String?> address = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GodownsLocalCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                address: address,
                isDefault: isDefault,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GodownsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GodownsLocalTable,
      GodownTableData,
      $$GodownsLocalTableFilterComposer,
      $$GodownsLocalTableOrderingComposer,
      $$GodownsLocalTableAnnotationComposer,
      $$GodownsLocalTableCreateCompanionBuilder,
      $$GodownsLocalTableUpdateCompanionBuilder,
      (
        GodownTableData,
        BaseReferences<_$AppDatabase, $GodownsLocalTable, GodownTableData>,
      ),
      GodownTableData,
      PrefetchHooks Function()
    >;
typedef $$BusinessSettingsLocalTableCreateCompanionBuilder =
    BusinessSettingsLocalCompanion Function({
      required String id,
      required String businessId,
      Value<String> valuationMethod,
      Value<String> defaultTaxType,
      Value<String?> invoiceTerms,
      Value<bool> enablePriceConflictAlerts,
      Value<String> creditLimitAction,
      Value<String?> pricingTierLabels,
      Value<String?> defaultInvoiceTaxRate,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });
typedef $$BusinessSettingsLocalTableUpdateCompanionBuilder =
    BusinessSettingsLocalCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> valuationMethod,
      Value<String> defaultTaxType,
      Value<String?> invoiceTerms,
      Value<bool> enablePriceConflictAlerts,
      Value<String> creditLimitAction,
      Value<String?> pricingTierLabels,
      Value<String?> defaultInvoiceTaxRate,
      Value<int> syncVersion,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> rowid,
    });

class $$BusinessSettingsLocalTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessSettingsLocalTable> {
  $$BusinessSettingsLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valuationMethod => $composableBuilder(
    column: $table.valuationMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultTaxType => $composableBuilder(
    column: $table.defaultTaxType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceTerms => $composableBuilder(
    column: $table.invoiceTerms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enablePriceConflictAlerts => $composableBuilder(
    column: $table.enablePriceConflictAlerts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creditLimitAction => $composableBuilder(
    column: $table.creditLimitAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pricingTierLabels => $composableBuilder(
    column: $table.pricingTierLabels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultInvoiceTaxRate => $composableBuilder(
    column: $table.defaultInvoiceTaxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BusinessSettingsLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessSettingsLocalTable> {
  $$BusinessSettingsLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valuationMethod => $composableBuilder(
    column: $table.valuationMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultTaxType => $composableBuilder(
    column: $table.defaultTaxType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceTerms => $composableBuilder(
    column: $table.invoiceTerms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enablePriceConflictAlerts => $composableBuilder(
    column: $table.enablePriceConflictAlerts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creditLimitAction => $composableBuilder(
    column: $table.creditLimitAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricingTierLabels => $composableBuilder(
    column: $table.pricingTierLabels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultInvoiceTaxRate => $composableBuilder(
    column: $table.defaultInvoiceTaxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BusinessSettingsLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessSettingsLocalTable> {
  $$BusinessSettingsLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valuationMethod => $composableBuilder(
    column: $table.valuationMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultTaxType => $composableBuilder(
    column: $table.defaultTaxType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceTerms => $composableBuilder(
    column: $table.invoiceTerms,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enablePriceConflictAlerts => $composableBuilder(
    column: $table.enablePriceConflictAlerts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get creditLimitAction => $composableBuilder(
    column: $table.creditLimitAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pricingTierLabels => $composableBuilder(
    column: $table.pricingTierLabels,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultInvoiceTaxRate => $composableBuilder(
    column: $table.defaultInvoiceTaxRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$BusinessSettingsLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusinessSettingsLocalTable,
          BusinessSettingsTableData,
          $$BusinessSettingsLocalTableFilterComposer,
          $$BusinessSettingsLocalTableOrderingComposer,
          $$BusinessSettingsLocalTableAnnotationComposer,
          $$BusinessSettingsLocalTableCreateCompanionBuilder,
          $$BusinessSettingsLocalTableUpdateCompanionBuilder,
          (
            BusinessSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $BusinessSettingsLocalTable,
              BusinessSettingsTableData
            >,
          ),
          BusinessSettingsTableData,
          PrefetchHooks Function()
        > {
  $$BusinessSettingsLocalTableTableManager(
    _$AppDatabase db,
    $BusinessSettingsLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessSettingsLocalTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BusinessSettingsLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BusinessSettingsLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> valuationMethod = const Value.absent(),
                Value<String> defaultTaxType = const Value.absent(),
                Value<String?> invoiceTerms = const Value.absent(),
                Value<bool> enablePriceConflictAlerts = const Value.absent(),
                Value<String> creditLimitAction = const Value.absent(),
                Value<String?> pricingTierLabels = const Value.absent(),
                Value<String?> defaultInvoiceTaxRate = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessSettingsLocalCompanion(
                id: id,
                businessId: businessId,
                valuationMethod: valuationMethod,
                defaultTaxType: defaultTaxType,
                invoiceTerms: invoiceTerms,
                enablePriceConflictAlerts: enablePriceConflictAlerts,
                creditLimitAction: creditLimitAction,
                pricingTierLabels: pricingTierLabels,
                defaultInvoiceTaxRate: defaultInvoiceTaxRate,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                Value<String> valuationMethod = const Value.absent(),
                Value<String> defaultTaxType = const Value.absent(),
                Value<String?> invoiceTerms = const Value.absent(),
                Value<bool> enablePriceConflictAlerts = const Value.absent(),
                Value<String> creditLimitAction = const Value.absent(),
                Value<String?> pricingTierLabels = const Value.absent(),
                Value<String?> defaultInvoiceTaxRate = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessSettingsLocalCompanion.insert(
                id: id,
                businessId: businessId,
                valuationMethod: valuationMethod,
                defaultTaxType: defaultTaxType,
                invoiceTerms: invoiceTerms,
                enablePriceConflictAlerts: enablePriceConflictAlerts,
                creditLimitAction: creditLimitAction,
                pricingTierLabels: pricingTierLabels,
                defaultInvoiceTaxRate: defaultInvoiceTaxRate,
                syncVersion: syncVersion,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BusinessSettingsLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusinessSettingsLocalTable,
      BusinessSettingsTableData,
      $$BusinessSettingsLocalTableFilterComposer,
      $$BusinessSettingsLocalTableOrderingComposer,
      $$BusinessSettingsLocalTableAnnotationComposer,
      $$BusinessSettingsLocalTableCreateCompanionBuilder,
      $$BusinessSettingsLocalTableUpdateCompanionBuilder,
      (
        BusinessSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $BusinessSettingsLocalTable,
          BusinessSettingsTableData
        >,
      ),
      BusinessSettingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SalesLocalTableTableManager get salesLocal =>
      $$SalesLocalTableTableManager(_db, _db.salesLocal);
  $$SalesLineLocalTableTableManager get salesLineLocal =>
      $$SalesLineLocalTableTableManager(_db, _db.salesLineLocal);
  $$HeldBillsLocalTableTableManager get heldBillsLocal =>
      $$HeldBillsLocalTableTableManager(_db, _db.heldBillsLocal);
  $$LeadsTableTableManager get leads =>
      $$LeadsTableTableManager(_db, _db.leads);
  $$LeadActivitiesTableTableManager get leadActivities =>
      $$LeadActivitiesTableTableManager(_db, _db.leadActivities);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$ContactActivitiesTableTableManager get contactActivities =>
      $$ContactActivitiesTableTableManager(_db, _db.contactActivities);
  $$DealsTableTableManager get deals =>
      $$DealsTableTableManager(_db, _db.deals);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$CategoriesLocalTableTableManager get categoriesLocal =>
      $$CategoriesLocalTableTableManager(_db, _db.categoriesLocal);
  $$PartiesLocalTableTableManager get partiesLocal =>
      $$PartiesLocalTableTableManager(_db, _db.partiesLocal);
  $$ItemsLocalTableTableManager get itemsLocal =>
      $$ItemsLocalTableTableManager(_db, _db.itemsLocal);
  $$UnitDefinitionsLocalTableTableManager get unitDefinitionsLocal =>
      $$UnitDefinitionsLocalTableTableManager(_db, _db.unitDefinitionsLocal);
  $$TaxRatesLocalTableTableManager get taxRatesLocal =>
      $$TaxRatesLocalTableTableManager(_db, _db.taxRatesLocal);
  $$GodownsLocalTableTableManager get godownsLocal =>
      $$GodownsLocalTableTableManager(_db, _db.godownsLocal);
  $$BusinessSettingsLocalTableTableManager get businessSettingsLocal =>
      $$BusinessSettingsLocalTableTableManager(_db, _db.businessSettingsLocal);
}
