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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SalesLocalTable salesLocal = $SalesLocalTable(this);
  late final $SalesLineLocalTable salesLineLocal = $SalesLineLocalTable(this);
  late final $HeldBillsLocalTable heldBillsLocal = $HeldBillsLocalTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    salesLocal,
    salesLineLocal,
    heldBillsLocal,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SalesLocalTableTableManager get salesLocal =>
      $$SalesLocalTableTableManager(_db, _db.salesLocal);
  $$SalesLineLocalTableTableManager get salesLineLocal =>
      $$SalesLineLocalTableTableManager(_db, _db.salesLineLocal);
  $$HeldBillsLocalTableTableManager get heldBillsLocal =>
      $$HeldBillsLocalTableTableManager(_db, _db.heldBillsLocal);
}
