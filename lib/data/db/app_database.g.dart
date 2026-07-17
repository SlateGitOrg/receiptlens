// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReceiptsTable extends Receipts
    with TableInfo<$ReceiptsTable, ReceiptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _vendorEncryptedMeta = const VerificationMeta(
    'vendorEncrypted',
  );
  @override
  late final GeneratedColumn<String> vendorEncrypted = GeneratedColumn<String>(
    'vendor_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasedAtMeta = const VerificationMeta(
    'purchasedAt',
  );
  @override
  late final GeneratedColumn<DateTime> purchasedAt = GeneratedColumn<DateTime>(
    'purchased_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalCentsMeta = const VerificationMeta(
    'subtotalCents',
  );
  @override
  late final GeneratedColumn<int> subtotalCents = GeneratedColumn<int>(
    'subtotal_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxCentsMeta = const VerificationMeta(
    'taxCents',
  );
  @override
  late final GeneratedColumn<int> taxCents = GeneratedColumn<int>(
    'tax_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawOcrTextEncryptedMeta =
      const VerificationMeta('rawOcrTextEncrypted');
  @override
  late final GeneratedColumn<String> rawOcrTextEncrypted =
      GeneratedColumn<String>(
        'raw_ocr_text_encrypted',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vendorEncrypted,
    purchasedAt,
    subtotalCents,
    taxCents,
    totalCents,
    rawOcrTextEncrypted,
    imagePath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vendor_encrypted')) {
      context.handle(
        _vendorEncryptedMeta,
        vendorEncrypted.isAcceptableOrUnknown(
          data['vendor_encrypted']!,
          _vendorEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vendorEncryptedMeta);
    }
    if (data.containsKey('purchased_at')) {
      context.handle(
        _purchasedAtMeta,
        purchasedAt.isAcceptableOrUnknown(
          data['purchased_at']!,
          _purchasedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasedAtMeta);
    }
    if (data.containsKey('subtotal_cents')) {
      context.handle(
        _subtotalCentsMeta,
        subtotalCents.isAcceptableOrUnknown(
          data['subtotal_cents']!,
          _subtotalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalCentsMeta);
    }
    if (data.containsKey('tax_cents')) {
      context.handle(
        _taxCentsMeta,
        taxCents.isAcceptableOrUnknown(data['tax_cents']!, _taxCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_taxCentsMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('raw_ocr_text_encrypted')) {
      context.handle(
        _rawOcrTextEncryptedMeta,
        rawOcrTextEncrypted.isAcceptableOrUnknown(
          data['raw_ocr_text_encrypted']!,
          _rawOcrTextEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawOcrTextEncryptedMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
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
  ReceiptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vendorEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vendor_encrypted'],
      )!,
      purchasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchased_at'],
      )!,
      subtotalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtotal_cents'],
      )!,
      taxCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_cents'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      rawOcrTextEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_ocr_text_encrypted'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReceiptsTable createAlias(String alias) {
    return $ReceiptsTable(attachedDatabase, alias);
  }
}

class ReceiptRow extends DataClass implements Insertable<ReceiptRow> {
  final int id;
  final String vendorEncrypted;
  final DateTime purchasedAt;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;
  final String rawOcrTextEncrypted;
  final String? imagePath;
  final DateTime createdAt;
  const ReceiptRow({
    required this.id,
    required this.vendorEncrypted,
    required this.purchasedAt,
    required this.subtotalCents,
    required this.taxCents,
    required this.totalCents,
    required this.rawOcrTextEncrypted,
    this.imagePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vendor_encrypted'] = Variable<String>(vendorEncrypted);
    map['purchased_at'] = Variable<DateTime>(purchasedAt);
    map['subtotal_cents'] = Variable<int>(subtotalCents);
    map['tax_cents'] = Variable<int>(taxCents);
    map['total_cents'] = Variable<int>(totalCents);
    map['raw_ocr_text_encrypted'] = Variable<String>(rawOcrTextEncrypted);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReceiptsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsCompanion(
      id: Value(id),
      vendorEncrypted: Value(vendorEncrypted),
      purchasedAt: Value(purchasedAt),
      subtotalCents: Value(subtotalCents),
      taxCents: Value(taxCents),
      totalCents: Value(totalCents),
      rawOcrTextEncrypted: Value(rawOcrTextEncrypted),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      createdAt: Value(createdAt),
    );
  }

  factory ReceiptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptRow(
      id: serializer.fromJson<int>(json['id']),
      vendorEncrypted: serializer.fromJson<String>(json['vendorEncrypted']),
      purchasedAt: serializer.fromJson<DateTime>(json['purchasedAt']),
      subtotalCents: serializer.fromJson<int>(json['subtotalCents']),
      taxCents: serializer.fromJson<int>(json['taxCents']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      rawOcrTextEncrypted: serializer.fromJson<String>(
        json['rawOcrTextEncrypted'],
      ),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vendorEncrypted': serializer.toJson<String>(vendorEncrypted),
      'purchasedAt': serializer.toJson<DateTime>(purchasedAt),
      'subtotalCents': serializer.toJson<int>(subtotalCents),
      'taxCents': serializer.toJson<int>(taxCents),
      'totalCents': serializer.toJson<int>(totalCents),
      'rawOcrTextEncrypted': serializer.toJson<String>(rawOcrTextEncrypted),
      'imagePath': serializer.toJson<String?>(imagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReceiptRow copyWith({
    int? id,
    String? vendorEncrypted,
    DateTime? purchasedAt,
    int? subtotalCents,
    int? taxCents,
    int? totalCents,
    String? rawOcrTextEncrypted,
    Value<String?> imagePath = const Value.absent(),
    DateTime? createdAt,
  }) => ReceiptRow(
    id: id ?? this.id,
    vendorEncrypted: vendorEncrypted ?? this.vendorEncrypted,
    purchasedAt: purchasedAt ?? this.purchasedAt,
    subtotalCents: subtotalCents ?? this.subtotalCents,
    taxCents: taxCents ?? this.taxCents,
    totalCents: totalCents ?? this.totalCents,
    rawOcrTextEncrypted: rawOcrTextEncrypted ?? this.rawOcrTextEncrypted,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    createdAt: createdAt ?? this.createdAt,
  );
  ReceiptRow copyWithCompanion(ReceiptsCompanion data) {
    return ReceiptRow(
      id: data.id.present ? data.id.value : this.id,
      vendorEncrypted: data.vendorEncrypted.present
          ? data.vendorEncrypted.value
          : this.vendorEncrypted,
      purchasedAt: data.purchasedAt.present
          ? data.purchasedAt.value
          : this.purchasedAt,
      subtotalCents: data.subtotalCents.present
          ? data.subtotalCents.value
          : this.subtotalCents,
      taxCents: data.taxCents.present ? data.taxCents.value : this.taxCents,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      rawOcrTextEncrypted: data.rawOcrTextEncrypted.present
          ? data.rawOcrTextEncrypted.value
          : this.rawOcrTextEncrypted,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptRow(')
          ..write('id: $id, ')
          ..write('vendorEncrypted: $vendorEncrypted, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('subtotalCents: $subtotalCents, ')
          ..write('taxCents: $taxCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('rawOcrTextEncrypted: $rawOcrTextEncrypted, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vendorEncrypted,
    purchasedAt,
    subtotalCents,
    taxCents,
    totalCents,
    rawOcrTextEncrypted,
    imagePath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptRow &&
          other.id == this.id &&
          other.vendorEncrypted == this.vendorEncrypted &&
          other.purchasedAt == this.purchasedAt &&
          other.subtotalCents == this.subtotalCents &&
          other.taxCents == this.taxCents &&
          other.totalCents == this.totalCents &&
          other.rawOcrTextEncrypted == this.rawOcrTextEncrypted &&
          other.imagePath == this.imagePath &&
          other.createdAt == this.createdAt);
}

class ReceiptsCompanion extends UpdateCompanion<ReceiptRow> {
  final Value<int> id;
  final Value<String> vendorEncrypted;
  final Value<DateTime> purchasedAt;
  final Value<int> subtotalCents;
  final Value<int> taxCents;
  final Value<int> totalCents;
  final Value<String> rawOcrTextEncrypted;
  final Value<String?> imagePath;
  final Value<DateTime> createdAt;
  const ReceiptsCompanion({
    this.id = const Value.absent(),
    this.vendorEncrypted = const Value.absent(),
    this.purchasedAt = const Value.absent(),
    this.subtotalCents = const Value.absent(),
    this.taxCents = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.rawOcrTextEncrypted = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReceiptsCompanion.insert({
    this.id = const Value.absent(),
    required String vendorEncrypted,
    required DateTime purchasedAt,
    required int subtotalCents,
    required int taxCents,
    required int totalCents,
    required String rawOcrTextEncrypted,
    this.imagePath = const Value.absent(),
    required DateTime createdAt,
  }) : vendorEncrypted = Value(vendorEncrypted),
       purchasedAt = Value(purchasedAt),
       subtotalCents = Value(subtotalCents),
       taxCents = Value(taxCents),
       totalCents = Value(totalCents),
       rawOcrTextEncrypted = Value(rawOcrTextEncrypted),
       createdAt = Value(createdAt);
  static Insertable<ReceiptRow> custom({
    Expression<int>? id,
    Expression<String>? vendorEncrypted,
    Expression<DateTime>? purchasedAt,
    Expression<int>? subtotalCents,
    Expression<int>? taxCents,
    Expression<int>? totalCents,
    Expression<String>? rawOcrTextEncrypted,
    Expression<String>? imagePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vendorEncrypted != null) 'vendor_encrypted': vendorEncrypted,
      if (purchasedAt != null) 'purchased_at': purchasedAt,
      if (subtotalCents != null) 'subtotal_cents': subtotalCents,
      if (taxCents != null) 'tax_cents': taxCents,
      if (totalCents != null) 'total_cents': totalCents,
      if (rawOcrTextEncrypted != null)
        'raw_ocr_text_encrypted': rawOcrTextEncrypted,
      if (imagePath != null) 'image_path': imagePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReceiptsCompanion copyWith({
    Value<int>? id,
    Value<String>? vendorEncrypted,
    Value<DateTime>? purchasedAt,
    Value<int>? subtotalCents,
    Value<int>? taxCents,
    Value<int>? totalCents,
    Value<String>? rawOcrTextEncrypted,
    Value<String?>? imagePath,
    Value<DateTime>? createdAt,
  }) {
    return ReceiptsCompanion(
      id: id ?? this.id,
      vendorEncrypted: vendorEncrypted ?? this.vendorEncrypted,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      subtotalCents: subtotalCents ?? this.subtotalCents,
      taxCents: taxCents ?? this.taxCents,
      totalCents: totalCents ?? this.totalCents,
      rawOcrTextEncrypted: rawOcrTextEncrypted ?? this.rawOcrTextEncrypted,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vendorEncrypted.present) {
      map['vendor_encrypted'] = Variable<String>(vendorEncrypted.value);
    }
    if (purchasedAt.present) {
      map['purchased_at'] = Variable<DateTime>(purchasedAt.value);
    }
    if (subtotalCents.present) {
      map['subtotal_cents'] = Variable<int>(subtotalCents.value);
    }
    if (taxCents.present) {
      map['tax_cents'] = Variable<int>(taxCents.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (rawOcrTextEncrypted.present) {
      map['raw_ocr_text_encrypted'] = Variable<String>(
        rawOcrTextEncrypted.value,
      );
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('vendorEncrypted: $vendorEncrypted, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('subtotalCents: $subtotalCents, ')
          ..write('taxCents: $taxCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('rawOcrTextEncrypted: $rawOcrTextEncrypted, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LineItemsTable extends LineItems
    with TableInfo<$LineItemsTable, LineItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _receiptIdMeta = const VerificationMeta(
    'receiptId',
  );
  @override
  late final GeneratedColumn<int> receiptId = GeneratedColumn<int>(
    'receipt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES receipts(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _descriptionEncryptedMeta =
      const VerificationMeta('descriptionEncrypted');
  @override
  late final GeneratedColumn<String> descriptionEncrypted =
      GeneratedColumn<String>(
        'description_encrypted',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    receiptId,
    descriptionEncrypted,
    amountCents,
    categoryId,
    confidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('receipt_id')) {
      context.handle(
        _receiptIdMeta,
        receiptId.isAcceptableOrUnknown(data['receipt_id']!, _receiptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptIdMeta);
    }
    if (data.containsKey('description_encrypted')) {
      context.handle(
        _descriptionEncryptedMeta,
        descriptionEncrypted.isAcceptableOrUnknown(
          data['description_encrypted']!,
          _descriptionEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionEncryptedMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LineItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      receiptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receipt_id'],
      )!,
      descriptionEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_encrypted'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
    );
  }

  @override
  $LineItemsTable createAlias(String alias) {
    return $LineItemsTable(attachedDatabase, alias);
  }
}

class LineItemRow extends DataClass implements Insertable<LineItemRow> {
  final int id;
  final int receiptId;
  final String descriptionEncrypted;
  final int amountCents;
  final String categoryId;
  final double confidence;
  const LineItemRow({
    required this.id,
    required this.receiptId,
    required this.descriptionEncrypted,
    required this.amountCents,
    required this.categoryId,
    required this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['receipt_id'] = Variable<int>(receiptId);
    map['description_encrypted'] = Variable<String>(descriptionEncrypted);
    map['amount_cents'] = Variable<int>(amountCents);
    map['category_id'] = Variable<String>(categoryId);
    map['confidence'] = Variable<double>(confidence);
    return map;
  }

  LineItemsCompanion toCompanion(bool nullToAbsent) {
    return LineItemsCompanion(
      id: Value(id),
      receiptId: Value(receiptId),
      descriptionEncrypted: Value(descriptionEncrypted),
      amountCents: Value(amountCents),
      categoryId: Value(categoryId),
      confidence: Value(confidence),
    );
  }

  factory LineItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineItemRow(
      id: serializer.fromJson<int>(json['id']),
      receiptId: serializer.fromJson<int>(json['receiptId']),
      descriptionEncrypted: serializer.fromJson<String>(
        json['descriptionEncrypted'],
      ),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      confidence: serializer.fromJson<double>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'receiptId': serializer.toJson<int>(receiptId),
      'descriptionEncrypted': serializer.toJson<String>(descriptionEncrypted),
      'amountCents': serializer.toJson<int>(amountCents),
      'categoryId': serializer.toJson<String>(categoryId),
      'confidence': serializer.toJson<double>(confidence),
    };
  }

  LineItemRow copyWith({
    int? id,
    int? receiptId,
    String? descriptionEncrypted,
    int? amountCents,
    String? categoryId,
    double? confidence,
  }) => LineItemRow(
    id: id ?? this.id,
    receiptId: receiptId ?? this.receiptId,
    descriptionEncrypted: descriptionEncrypted ?? this.descriptionEncrypted,
    amountCents: amountCents ?? this.amountCents,
    categoryId: categoryId ?? this.categoryId,
    confidence: confidence ?? this.confidence,
  );
  LineItemRow copyWithCompanion(LineItemsCompanion data) {
    return LineItemRow(
      id: data.id.present ? data.id.value : this.id,
      receiptId: data.receiptId.present ? data.receiptId.value : this.receiptId,
      descriptionEncrypted: data.descriptionEncrypted.present
          ? data.descriptionEncrypted.value
          : this.descriptionEncrypted,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineItemRow(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('descriptionEncrypted: $descriptionEncrypted, ')
          ..write('amountCents: $amountCents, ')
          ..write('categoryId: $categoryId, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    receiptId,
    descriptionEncrypted,
    amountCents,
    categoryId,
    confidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineItemRow &&
          other.id == this.id &&
          other.receiptId == this.receiptId &&
          other.descriptionEncrypted == this.descriptionEncrypted &&
          other.amountCents == this.amountCents &&
          other.categoryId == this.categoryId &&
          other.confidence == this.confidence);
}

class LineItemsCompanion extends UpdateCompanion<LineItemRow> {
  final Value<int> id;
  final Value<int> receiptId;
  final Value<String> descriptionEncrypted;
  final Value<int> amountCents;
  final Value<String> categoryId;
  final Value<double> confidence;
  const LineItemsCompanion({
    this.id = const Value.absent(),
    this.receiptId = const Value.absent(),
    this.descriptionEncrypted = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.confidence = const Value.absent(),
  });
  LineItemsCompanion.insert({
    this.id = const Value.absent(),
    required int receiptId,
    required String descriptionEncrypted,
    required int amountCents,
    required String categoryId,
    this.confidence = const Value.absent(),
  }) : receiptId = Value(receiptId),
       descriptionEncrypted = Value(descriptionEncrypted),
       amountCents = Value(amountCents),
       categoryId = Value(categoryId);
  static Insertable<LineItemRow> custom({
    Expression<int>? id,
    Expression<int>? receiptId,
    Expression<String>? descriptionEncrypted,
    Expression<int>? amountCents,
    Expression<String>? categoryId,
    Expression<double>? confidence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receiptId != null) 'receipt_id': receiptId,
      if (descriptionEncrypted != null)
        'description_encrypted': descriptionEncrypted,
      if (amountCents != null) 'amount_cents': amountCents,
      if (categoryId != null) 'category_id': categoryId,
      if (confidence != null) 'confidence': confidence,
    });
  }

  LineItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? receiptId,
    Value<String>? descriptionEncrypted,
    Value<int>? amountCents,
    Value<String>? categoryId,
    Value<double>? confidence,
  }) {
    return LineItemsCompanion(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      descriptionEncrypted: descriptionEncrypted ?? this.descriptionEncrypted,
      amountCents: amountCents ?? this.amountCents,
      categoryId: categoryId ?? this.categoryId,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (receiptId.present) {
      map['receipt_id'] = Variable<int>(receiptId.value);
    }
    if (descriptionEncrypted.present) {
      map['description_encrypted'] = Variable<String>(
        descriptionEncrypted.value,
      );
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineItemsCompanion(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('descriptionEncrypted: $descriptionEncrypted, ')
          ..write('amountCents: $amountCents, ')
          ..write('categoryId: $categoryId, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  late final $LineItemsTable lineItems = $LineItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [receipts, lineItems];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'receipts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('line_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ReceiptsTableCreateCompanionBuilder =
    ReceiptsCompanion Function({
      Value<int> id,
      required String vendorEncrypted,
      required DateTime purchasedAt,
      required int subtotalCents,
      required int taxCents,
      required int totalCents,
      required String rawOcrTextEncrypted,
      Value<String?> imagePath,
      required DateTime createdAt,
    });
typedef $$ReceiptsTableUpdateCompanionBuilder =
    ReceiptsCompanion Function({
      Value<int> id,
      Value<String> vendorEncrypted,
      Value<DateTime> purchasedAt,
      Value<int> subtotalCents,
      Value<int> taxCents,
      Value<int> totalCents,
      Value<String> rawOcrTextEncrypted,
      Value<String?> imagePath,
      Value<DateTime> createdAt,
    });

final class $$ReceiptsTableReferences
    extends BaseReferences<_$AppDatabase, $ReceiptsTable, ReceiptRow> {
  $$ReceiptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LineItemsTable, List<LineItemRow>>
  _lineItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lineItems,
    aliasName: $_aliasNameGenerator(db.receipts.id, db.lineItems.receiptId),
  );

  $$LineItemsTableProcessedTableManager get lineItemsRefs {
    final manager = $$LineItemsTableTableManager(
      $_db,
      $_db.lineItems,
    ).filter((f) => f.receiptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableFilterComposer({
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

  ColumnFilters<String> get vendorEncrypted => $composableBuilder(
    column: $table.vendorEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxCents => $composableBuilder(
    column: $table.taxCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawOcrTextEncrypted => $composableBuilder(
    column: $table.rawOcrTextEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lineItemsRefs(
    Expression<bool> Function($$LineItemsTableFilterComposer f) f,
  ) {
    final $$LineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineItems,
      getReferencedColumn: (t) => t.receiptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineItemsTableFilterComposer(
            $db: $db,
            $table: $db.lineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableOrderingComposer({
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

  ColumnOrderings<String> get vendorEncrypted => $composableBuilder(
    column: $table.vendorEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxCents => $composableBuilder(
    column: $table.taxCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawOcrTextEncrypted => $composableBuilder(
    column: $table.rawOcrTextEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vendorEncrypted => $composableBuilder(
    column: $table.vendorEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxCents =>
      $composableBuilder(column: $table.taxCents, builder: (column) => column);

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawOcrTextEncrypted => $composableBuilder(
    column: $table.rawOcrTextEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> lineItemsRefs<T extends Object>(
    Expression<T> Function($$LineItemsTableAnnotationComposer a) f,
  ) {
    final $$LineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineItems,
      getReferencedColumn: (t) => t.receiptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.lineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptsTable,
          ReceiptRow,
          $$ReceiptsTableFilterComposer,
          $$ReceiptsTableOrderingComposer,
          $$ReceiptsTableAnnotationComposer,
          $$ReceiptsTableCreateCompanionBuilder,
          $$ReceiptsTableUpdateCompanionBuilder,
          (ReceiptRow, $$ReceiptsTableReferences),
          ReceiptRow,
          PrefetchHooks Function({bool lineItemsRefs})
        > {
  $$ReceiptsTableTableManager(_$AppDatabase db, $ReceiptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> vendorEncrypted = const Value.absent(),
                Value<DateTime> purchasedAt = const Value.absent(),
                Value<int> subtotalCents = const Value.absent(),
                Value<int> taxCents = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<String> rawOcrTextEncrypted = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReceiptsCompanion(
                id: id,
                vendorEncrypted: vendorEncrypted,
                purchasedAt: purchasedAt,
                subtotalCents: subtotalCents,
                taxCents: taxCents,
                totalCents: totalCents,
                rawOcrTextEncrypted: rawOcrTextEncrypted,
                imagePath: imagePath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String vendorEncrypted,
                required DateTime purchasedAt,
                required int subtotalCents,
                required int taxCents,
                required int totalCents,
                required String rawOcrTextEncrypted,
                Value<String?> imagePath = const Value.absent(),
                required DateTime createdAt,
              }) => ReceiptsCompanion.insert(
                id: id,
                vendorEncrypted: vendorEncrypted,
                purchasedAt: purchasedAt,
                subtotalCents: subtotalCents,
                taxCents: taxCents,
                totalCents: totalCents,
                rawOcrTextEncrypted: rawOcrTextEncrypted,
                imagePath: imagePath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReceiptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lineItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (lineItemsRefs) db.lineItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lineItemsRefs)
                    await $_getPrefetchedData<
                      ReceiptRow,
                      $ReceiptsTable,
                      LineItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$ReceiptsTableReferences
                          ._lineItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ReceiptsTableReferences(
                        db,
                        table,
                        p0,
                      ).lineItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.receiptId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptsTable,
      ReceiptRow,
      $$ReceiptsTableFilterComposer,
      $$ReceiptsTableOrderingComposer,
      $$ReceiptsTableAnnotationComposer,
      $$ReceiptsTableCreateCompanionBuilder,
      $$ReceiptsTableUpdateCompanionBuilder,
      (ReceiptRow, $$ReceiptsTableReferences),
      ReceiptRow,
      PrefetchHooks Function({bool lineItemsRefs})
    >;
typedef $$LineItemsTableCreateCompanionBuilder =
    LineItemsCompanion Function({
      Value<int> id,
      required int receiptId,
      required String descriptionEncrypted,
      required int amountCents,
      required String categoryId,
      Value<double> confidence,
    });
typedef $$LineItemsTableUpdateCompanionBuilder =
    LineItemsCompanion Function({
      Value<int> id,
      Value<int> receiptId,
      Value<String> descriptionEncrypted,
      Value<int> amountCents,
      Value<String> categoryId,
      Value<double> confidence,
    });

final class $$LineItemsTableReferences
    extends BaseReferences<_$AppDatabase, $LineItemsTable, LineItemRow> {
  $$LineItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReceiptsTable _receiptIdTable(_$AppDatabase db) =>
      db.receipts.createAlias(
        $_aliasNameGenerator(db.lineItems.receiptId, db.receipts.id),
      );

  $$ReceiptsTableProcessedTableManager get receiptId {
    final $_column = $_itemColumn<int>('receipt_id')!;

    final manager = $$ReceiptsTableTableManager(
      $_db,
      $_db.receipts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_receiptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LineItemsTable> {
  $$LineItemsTableFilterComposer({
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

  ColumnFilters<String> get descriptionEncrypted => $composableBuilder(
    column: $table.descriptionEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  $$ReceiptsTableFilterComposer get receiptId {
    final $$ReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LineItemsTable> {
  $$LineItemsTableOrderingComposer({
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

  ColumnOrderings<String> get descriptionEncrypted => $composableBuilder(
    column: $table.descriptionEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReceiptsTableOrderingComposer get receiptId {
    final $$ReceiptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableOrderingComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineItemsTable> {
  $$LineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descriptionEncrypted => $composableBuilder(
    column: $table.descriptionEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  $$ReceiptsTableAnnotationComposer get receiptId {
    final $$ReceiptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableAnnotationComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineItemsTable,
          LineItemRow,
          $$LineItemsTableFilterComposer,
          $$LineItemsTableOrderingComposer,
          $$LineItemsTableAnnotationComposer,
          $$LineItemsTableCreateCompanionBuilder,
          $$LineItemsTableUpdateCompanionBuilder,
          (LineItemRow, $$LineItemsTableReferences),
          LineItemRow,
          PrefetchHooks Function({bool receiptId})
        > {
  $$LineItemsTableTableManager(_$AppDatabase db, $LineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> receiptId = const Value.absent(),
                Value<String> descriptionEncrypted = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<double> confidence = const Value.absent(),
              }) => LineItemsCompanion(
                id: id,
                receiptId: receiptId,
                descriptionEncrypted: descriptionEncrypted,
                amountCents: amountCents,
                categoryId: categoryId,
                confidence: confidence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int receiptId,
                required String descriptionEncrypted,
                required int amountCents,
                required String categoryId,
                Value<double> confidence = const Value.absent(),
              }) => LineItemsCompanion.insert(
                id: id,
                receiptId: receiptId,
                descriptionEncrypted: descriptionEncrypted,
                amountCents: amountCents,
                categoryId: categoryId,
                confidence: confidence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LineItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({receiptId = false}) {
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
                    if (receiptId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.receiptId,
                                referencedTable: $$LineItemsTableReferences
                                    ._receiptIdTable(db),
                                referencedColumn: $$LineItemsTableReferences
                                    ._receiptIdTable(db)
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

typedef $$LineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineItemsTable,
      LineItemRow,
      $$LineItemsTableFilterComposer,
      $$LineItemsTableOrderingComposer,
      $$LineItemsTableAnnotationComposer,
      $$LineItemsTableCreateCompanionBuilder,
      $$LineItemsTableUpdateCompanionBuilder,
      (LineItemRow, $$LineItemsTableReferences),
      LineItemRow,
      PrefetchHooks Function({bool receiptId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
  $$LineItemsTableTableManager get lineItems =>
      $$LineItemsTableTableManager(_db, _db.lineItems);
}
