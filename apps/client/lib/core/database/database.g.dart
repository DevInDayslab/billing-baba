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
       docNumber = Value(docNumber),
       totalAmount = Value(totalAmount),
       taxAmount = Value(taxAmount),
       finalAmount = Value(finalAmount),
       createdAt = Value(createdAt),
       paymentMethod = Value(paymentMethod),
       apiResponseJson = Value(apiResponseJson);
  static Insertable<SaleLocal> custom({
    Expression<String>? id,
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
  final String itemsJson;
  final String paymentsJson;
  final String? customerName;
  final String? notes;
  final DateTime heldAt;
  const HeldBillsLocalData({
    required this.id,
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
      'itemsJson': serializer.toJson<String>(itemsJson),
      'paymentsJson': serializer.toJson<String>(paymentsJson),
      'customerName': serializer.toJson<String?>(customerName),
      'notes': serializer.toJson<String?>(notes),
      'heldAt': serializer.toJson<DateTime>(heldAt),
    };
  }

  HeldBillsLocalData copyWith({
    String? id,
    String? itemsJson,
    String? paymentsJson,
    Value<String?> customerName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? heldAt,
  }) => HeldBillsLocalData(
    id: id ?? this.id,
    itemsJson: itemsJson ?? this.itemsJson,
    paymentsJson: paymentsJson ?? this.paymentsJson,
    customerName: customerName.present ? customerName.value : this.customerName,
    notes: notes.present ? notes.value : this.notes,
    heldAt: heldAt ?? this.heldAt,
  );
  HeldBillsLocalData copyWithCompanion(HeldBillsLocalCompanion data) {
    return HeldBillsLocalData(
      id: data.id.present ? data.id.value : this.id,
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
          ..write('itemsJson: $itemsJson, ')
          ..write('paymentsJson: $paymentsJson, ')
          ..write('customerName: $customerName, ')
          ..write('notes: $notes, ')
          ..write('heldAt: $heldAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemsJson, paymentsJson, customerName, notes, heldAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeldBillsLocalData &&
          other.id == this.id &&
          other.itemsJson == this.itemsJson &&
          other.paymentsJson == this.paymentsJson &&
          other.customerName == this.customerName &&
          other.notes == this.notes &&
          other.heldAt == this.heldAt);
}

class HeldBillsLocalCompanion extends UpdateCompanion<HeldBillsLocalData> {
  final Value<String> id;
  final Value<String> itemsJson;
  final Value<String> paymentsJson;
  final Value<String?> customerName;
  final Value<String?> notes;
  final Value<DateTime> heldAt;
  final Value<int> rowid;
  const HeldBillsLocalCompanion({
    this.id = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.paymentsJson = const Value.absent(),
    this.customerName = const Value.absent(),
    this.notes = const Value.absent(),
    this.heldAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HeldBillsLocalCompanion.insert({
    required String id,
    required String itemsJson,
    this.paymentsJson = const Value.absent(),
    this.customerName = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime heldAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemsJson = Value(itemsJson),
       heldAt = Value(heldAt);
  static Insertable<HeldBillsLocalData> custom({
    Expression<String>? id,
    Expression<String>? itemsJson,
    Expression<String>? paymentsJson,
    Expression<String>? customerName,
    Expression<String>? notes,
    Expression<DateTime>? heldAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
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
    Value<String>? itemsJson,
    Value<String>? paymentsJson,
    Value<String?>? customerName,
    Value<String?>? notes,
    Value<DateTime>? heldAt,
    Value<int>? rowid,
  }) {
    return HeldBillsLocalCompanion(
      id: id ?? this.id,
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
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    entityType,
    entityId,
    operation,
    payload,
    createdAt,
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
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
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
    } else if (isInserting) {
      context.missing(_entityIdMeta);
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
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String businessId;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final String createdAt;
  const SyncQueueData({
    required this.id,
    required this.businessId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<String>(businessId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      businessId: Value(businessId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<String>(businessId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? businessId,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    String? createdAt,
  }) => SyncQueueData(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    entityType,
    entityId,
    operation,
    payload,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> businessId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String businessId,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required String createdAt,
  }) : businessId = Value(businessId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? businessId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? businessId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<String>? createdAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
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
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
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
  ];
}

typedef $$SalesLocalTableCreateCompanionBuilder =
    SalesLocalCompanion Function({
      required String id,
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
                Value<String> itemsJson = const Value.absent(),
                Value<String> paymentsJson = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> heldAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HeldBillsLocalCompanion(
                id: id,
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
                required String itemsJson,
                Value<String> paymentsJson = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime heldAt,
                Value<int> rowid = const Value.absent(),
              }) => HeldBillsLocalCompanion.insert(
                id: id,
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
      Value<int> id,
      required String businessId,
      required String entityType,
      required String entityId,
      required String operation,
      required String payload,
      required String createdAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> businessId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<String> createdAt,
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

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

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
                Value<int> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                businessId: businessId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String businessId,
                required String entityType,
                required String entityId,
                required String operation,
                required String payload,
                required String createdAt,
              }) => SyncQueueCompanion.insert(
                id: id,
                businessId: businessId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
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
}
