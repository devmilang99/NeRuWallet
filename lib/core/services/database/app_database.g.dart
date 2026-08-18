// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<double> fee = GeneratedColumn<double>(
    'fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxMeta = const VerificationMeta('tax');
  @override
  late final GeneratedColumn<double> tax = GeneratedColumn<double>(
    'tax',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Other'),
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
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
    defaultValue: const Constant('completed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    subtitle,
    amount,
    fee,
    tax,
    iconCode,
    colorValue,
    category,
    transactionType,
    createdAt,
    metadata,
    groupId,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('fee')) {
      context.handle(
        _feeMeta,
        fee.isAcceptableOrUnknown(data['fee']!, _feeMeta),
      );
    }
    if (data.containsKey('tax')) {
      context.handle(
        _taxMeta,
        tax.isAcceptableOrUnknown(data['tax']!, _taxMeta),
      );
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      fee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fee'],
      )!,
      tax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final double fee;
  final double tax;
  final int iconCode;
  final int colorValue;
  final String category;
  final String? transactionType;
  final DateTime createdAt;
  final String? metadata;
  final String? groupId;
  final String status;
  const Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.fee,
    required this.tax,
    required this.iconCode,
    required this.colorValue,
    required this.category,
    this.transactionType,
    required this.createdAt,
    this.metadata,
    this.groupId,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['amount'] = Variable<double>(amount);
    map['fee'] = Variable<double>(fee);
    map['tax'] = Variable<double>(tax);
    map['icon_code'] = Variable<int>(iconCode);
    map['color_value'] = Variable<int>(colorValue);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || transactionType != null) {
      map['transaction_type'] = Variable<String>(transactionType);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      title: Value(title),
      subtitle: Value(subtitle),
      amount: Value(amount),
      fee: Value(fee),
      tax: Value(tax),
      iconCode: Value(iconCode),
      colorValue: Value(colorValue),
      category: Value(category),
      transactionType: transactionType == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionType),
      createdAt: Value(createdAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      status: Value(status),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      amount: serializer.fromJson<double>(json['amount']),
      fee: serializer.fromJson<double>(json['fee']),
      tax: serializer.fromJson<double>(json['tax']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      category: serializer.fromJson<String>(json['category']),
      transactionType: serializer.fromJson<String?>(json['transactionType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'amount': serializer.toJson<double>(amount),
      'fee': serializer.toJson<double>(fee),
      'tax': serializer.toJson<double>(tax),
      'iconCode': serializer.toJson<int>(iconCode),
      'colorValue': serializer.toJson<int>(colorValue),
      'category': serializer.toJson<String>(category),
      'transactionType': serializer.toJson<String?>(transactionType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'metadata': serializer.toJson<String?>(metadata),
      'groupId': serializer.toJson<String?>(groupId),
      'status': serializer.toJson<String>(status),
    };
  }

  Transaction copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? amount,
    double? fee,
    double? tax,
    int? iconCode,
    int? colorValue,
    String? category,
    Value<String?> transactionType = const Value.absent(),
    DateTime? createdAt,
    Value<String?> metadata = const Value.absent(),
    Value<String?> groupId = const Value.absent(),
    String? status,
  }) => Transaction(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    amount: amount ?? this.amount,
    fee: fee ?? this.fee,
    tax: tax ?? this.tax,
    iconCode: iconCode ?? this.iconCode,
    colorValue: colorValue ?? this.colorValue,
    category: category ?? this.category,
    transactionType: transactionType.present
        ? transactionType.value
        : this.transactionType,
    createdAt: createdAt ?? this.createdAt,
    metadata: metadata.present ? metadata.value : this.metadata,
    groupId: groupId.present ? groupId.value : this.groupId,
    status: status ?? this.status,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      amount: data.amount.present ? data.amount.value : this.amount,
      fee: data.fee.present ? data.fee.value : this.fee,
      tax: data.tax.present ? data.tax.value : this.tax,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      category: data.category.present ? data.category.value : this.category,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('amount: $amount, ')
          ..write('fee: $fee, ')
          ..write('tax: $tax, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('category: $category, ')
          ..write('transactionType: $transactionType, ')
          ..write('createdAt: $createdAt, ')
          ..write('metadata: $metadata, ')
          ..write('groupId: $groupId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    amount,
    fee,
    tax,
    iconCode,
    colorValue,
    category,
    transactionType,
    createdAt,
    metadata,
    groupId,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.amount == this.amount &&
          other.fee == this.fee &&
          other.tax == this.tax &&
          other.iconCode == this.iconCode &&
          other.colorValue == this.colorValue &&
          other.category == this.category &&
          other.transactionType == this.transactionType &&
          other.createdAt == this.createdAt &&
          other.metadata == this.metadata &&
          other.groupId == this.groupId &&
          other.status == this.status);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<double> amount;
  final Value<double> fee;
  final Value<double> tax;
  final Value<int> iconCode;
  final Value<int> colorValue;
  final Value<String> category;
  final Value<String?> transactionType;
  final Value<DateTime> createdAt;
  final Value<String?> metadata;
  final Value<String?> groupId;
  final Value<String> status;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.amount = const Value.absent(),
    this.fee = const Value.absent(),
    this.tax = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.category = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.groupId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String title,
    required String subtitle,
    required double amount,
    this.fee = const Value.absent(),
    this.tax = const Value.absent(),
    required int iconCode,
    required int colorValue,
    this.category = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.groupId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       subtitle = Value(subtitle),
       amount = Value(amount),
       iconCode = Value(iconCode),
       colorValue = Value(colorValue);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<double>? amount,
    Expression<double>? fee,
    Expression<double>? tax,
    Expression<int>? iconCode,
    Expression<int>? colorValue,
    Expression<String>? category,
    Expression<String>? transactionType,
    Expression<DateTime>? createdAt,
    Expression<String>? metadata,
    Expression<String>? groupId,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (amount != null) 'amount': amount,
      if (fee != null) 'fee': fee,
      if (tax != null) 'tax': tax,
      if (iconCode != null) 'icon_code': iconCode,
      if (colorValue != null) 'color_value': colorValue,
      if (category != null) 'category': category,
      if (transactionType != null) 'transaction_type': transactionType,
      if (createdAt != null) 'created_at': createdAt,
      if (metadata != null) 'metadata': metadata,
      if (groupId != null) 'group_id': groupId,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? subtitle,
    Value<double>? amount,
    Value<double>? fee,
    Value<double>? tax,
    Value<int>? iconCode,
    Value<int>? colorValue,
    Value<String>? category,
    Value<String?>? transactionType,
    Value<DateTime>? createdAt,
    Value<String?>? metadata,
    Value<String?>? groupId,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      tax: tax ?? this.tax,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      category: category ?? this.category,
      transactionType: transactionType ?? this.transactionType,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      groupId: groupId ?? this.groupId,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (fee.present) {
      map['fee'] = Variable<double>(fee.value);
    }
    if (tax.present) {
      map['tax'] = Variable<double>(tax.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('amount: $amount, ')
          ..write('fee: $fee, ')
          ..write('tax: $tax, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('category: $category, ')
          ..write('transactionType: $transactionType, ')
          ..write('createdAt: $createdAt, ')
          ..write('metadata: $metadata, ')
          ..write('groupId: $groupId, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreference extends DataClass implements Insertable<AppPreference> {
  final String key;
  final String? value;
  const AppPreference({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppPreference copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppPreference(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppPreference copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreference &&
          other.key == this.key &&
          other.value == this.value);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreference> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppPreference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbNotificationsTable extends DbNotifications
    with TableInfo<$DbNotificationsTable, DbNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbNotificationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, body, receivedAt, isRead];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbNotification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbNotification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
    );
  }

  @override
  $DbNotificationsTable createAlias(String alias) {
    return $DbNotificationsTable(attachedDatabase, alias);
  }
}

class DbNotification extends DataClass implements Insertable<DbNotification> {
  final int id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool isRead;
  const DbNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.isRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  DbNotificationsCompanion toCompanion(bool nullToAbsent) {
    return DbNotificationsCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      receivedAt: Value(receivedAt),
      isRead: Value(isRead),
    );
  }

  factory DbNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbNotification(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  DbNotification copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? receivedAt,
    bool? isRead,
  }) => DbNotification(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    receivedAt: receivedAt ?? this.receivedAt,
    isRead: isRead ?? this.isRead,
  );
  DbNotification copyWithCompanion(DbNotificationsCompanion data) {
    return DbNotification(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbNotification(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, body, receivedAt, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbNotification &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.receivedAt == this.receivedAt &&
          other.isRead == this.isRead);
}

class DbNotificationsCompanion extends UpdateCompanion<DbNotification> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> receivedAt;
  final Value<bool> isRead;
  const DbNotificationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.isRead = const Value.absent(),
  });
  DbNotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String body,
    this.receivedAt = const Value.absent(),
    this.isRead = const Value.absent(),
  }) : title = Value(title),
       body = Value(body);
  static Insertable<DbNotification> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? receivedAt,
    Expression<bool>? isRead,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (receivedAt != null) 'received_at': receivedAt,
      if (isRead != null) 'is_read': isRead,
    });
  }

  DbNotificationsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? receivedAt,
    Value<bool>? isRead,
  }) {
    return DbNotificationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }
}

class $AiMemoriesTable extends AiMemories
    with TableInfo<$AiMemoriesTable, AiMemory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiMemoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, role, content, type, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiMemory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiMemory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiMemory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiMemoriesTable createAlias(String alias) {
    return $AiMemoriesTable(attachedDatabase, alias);
  }
}

class AiMemory extends DataClass implements Insertable<AiMemory> {
  final int id;
  final String role;
  final String content;
  final String type;
  final DateTime createdAt;
  const AiMemory({
    required this.id,
    required this.role,
    required this.content,
    required this.type,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiMemoriesCompanion toCompanion(bool nullToAbsent) {
    return AiMemoriesCompanion(
      id: Value(id),
      role: Value(role),
      content: Value(content),
      type: Value(type),
      createdAt: Value(createdAt),
    );
  }

  factory AiMemory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiMemory(
      id: serializer.fromJson<int>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiMemory copyWith({
    int? id,
    String? role,
    String? content,
    String? type,
    DateTime? createdAt,
  }) => AiMemory(
    id: id ?? this.id,
    role: role ?? this.role,
    content: content ?? this.content,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
  );
  AiMemory copyWithCompanion(AiMemoriesCompanion data) {
    return AiMemory(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiMemory(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, role, content, type, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiMemory &&
          other.id == this.id &&
          other.role == this.role &&
          other.content == this.content &&
          other.type == this.type &&
          other.createdAt == this.createdAt);
}

class AiMemoriesCompanion extends UpdateCompanion<AiMemory> {
  final Value<int> id;
  final Value<String> role;
  final Value<String> content;
  final Value<String> type;
  final Value<DateTime> createdAt;
  const AiMemoriesCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AiMemoriesCompanion.insert({
    this.id = const Value.absent(),
    required String role,
    required String content,
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : role = Value(role),
       content = Value(content);
  static Insertable<AiMemory> custom({
    Expression<int>? id,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AiMemoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? role,
    Value<String>? content,
    Value<String>? type,
    Value<DateTime>? createdAt,
  }) {
    return AiMemoriesCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiMemoriesCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MultiSigGroupsTable extends MultiSigGroups
    with TableInfo<$MultiSigGroupsTable, MultiSigGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MultiSigGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<String> creatorId = GeneratedColumn<String>(
    'creator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thresholdMeta = const VerificationMeta(
    'threshold',
  );
  @override
  late final GeneratedColumn<int> threshold = GeneratedColumn<int>(
    'threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMembersMeta = const VerificationMeta(
    'totalMembers',
  );
  @override
  late final GeneratedColumn<int> totalMembers = GeneratedColumn<int>(
    'total_members',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    creatorId,
    threshold,
    totalMembers,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'multi_sig_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<MultiSigGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creatorIdMeta);
    }
    if (data.containsKey('threshold')) {
      context.handle(
        _thresholdMeta,
        threshold.isAcceptableOrUnknown(data['threshold']!, _thresholdMeta),
      );
    } else if (isInserting) {
      context.missing(_thresholdMeta);
    }
    if (data.containsKey('total_members')) {
      context.handle(
        _totalMembersMeta,
        totalMembers.isAcceptableOrUnknown(
          data['total_members']!,
          _totalMembersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalMembersMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MultiSigGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MultiSigGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_id'],
      )!,
      threshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}threshold'],
      )!,
      totalMembers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_members'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MultiSigGroupsTable createAlias(String alias) {
    return $MultiSigGroupsTable(attachedDatabase, alias);
  }
}

class MultiSigGroup extends DataClass implements Insertable<MultiSigGroup> {
  final String id;
  final String name;
  final String creatorId;
  final int threshold;
  final int totalMembers;
  final DateTime createdAt;
  const MultiSigGroup({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.threshold,
    required this.totalMembers,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['creator_id'] = Variable<String>(creatorId);
    map['threshold'] = Variable<int>(threshold);
    map['total_members'] = Variable<int>(totalMembers);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MultiSigGroupsCompanion toCompanion(bool nullToAbsent) {
    return MultiSigGroupsCompanion(
      id: Value(id),
      name: Value(name),
      creatorId: Value(creatorId),
      threshold: Value(threshold),
      totalMembers: Value(totalMembers),
      createdAt: Value(createdAt),
    );
  }

  factory MultiSigGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MultiSigGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      creatorId: serializer.fromJson<String>(json['creatorId']),
      threshold: serializer.fromJson<int>(json['threshold']),
      totalMembers: serializer.fromJson<int>(json['totalMembers']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'creatorId': serializer.toJson<String>(creatorId),
      'threshold': serializer.toJson<int>(threshold),
      'totalMembers': serializer.toJson<int>(totalMembers),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MultiSigGroup copyWith({
    String? id,
    String? name,
    String? creatorId,
    int? threshold,
    int? totalMembers,
    DateTime? createdAt,
  }) => MultiSigGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    creatorId: creatorId ?? this.creatorId,
    threshold: threshold ?? this.threshold,
    totalMembers: totalMembers ?? this.totalMembers,
    createdAt: createdAt ?? this.createdAt,
  );
  MultiSigGroup copyWithCompanion(MultiSigGroupsCompanion data) {
    return MultiSigGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      threshold: data.threshold.present ? data.threshold.value : this.threshold,
      totalMembers: data.totalMembers.present
          ? data.totalMembers.value
          : this.totalMembers,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MultiSigGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorId: $creatorId, ')
          ..write('threshold: $threshold, ')
          ..write('totalMembers: $totalMembers, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, creatorId, threshold, totalMembers, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MultiSigGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.creatorId == this.creatorId &&
          other.threshold == this.threshold &&
          other.totalMembers == this.totalMembers &&
          other.createdAt == this.createdAt);
}

class MultiSigGroupsCompanion extends UpdateCompanion<MultiSigGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> creatorId;
  final Value<int> threshold;
  final Value<int> totalMembers;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MultiSigGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.threshold = const Value.absent(),
    this.totalMembers = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MultiSigGroupsCompanion.insert({
    required String id,
    required String name,
    required String creatorId,
    required int threshold,
    required int totalMembers,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       creatorId = Value(creatorId),
       threshold = Value(threshold),
       totalMembers = Value(totalMembers);
  static Insertable<MultiSigGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? creatorId,
    Expression<int>? threshold,
    Expression<int>? totalMembers,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (creatorId != null) 'creator_id': creatorId,
      if (threshold != null) 'threshold': threshold,
      if (totalMembers != null) 'total_members': totalMembers,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MultiSigGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? creatorId,
    Value<int>? threshold,
    Value<int>? totalMembers,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MultiSigGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      threshold: threshold ?? this.threshold,
      totalMembers: totalMembers ?? this.totalMembers,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<String>(creatorId.value);
    }
    if (threshold.present) {
      map['threshold'] = Variable<int>(threshold.value);
    }
    if (totalMembers.present) {
      map['total_members'] = Variable<int>(totalMembers.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MultiSigGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorId: $creatorId, ')
          ..write('threshold: $threshold, ')
          ..write('totalMembers: $totalMembers, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MultiSigMembersTable extends MultiSigMembers
    with TableInfo<$MultiSigMembersTable, MultiSigMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MultiSigMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES multi_sig_groups (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, userId, publicKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'multi_sig_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<MultiSigMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, userId};
  @override
  MultiSigMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MultiSigMember(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      )!,
    );
  }

  @override
  $MultiSigMembersTable createAlias(String alias) {
    return $MultiSigMembersTable(attachedDatabase, alias);
  }
}

class MultiSigMember extends DataClass implements Insertable<MultiSigMember> {
  final String groupId;
  final String userId;
  final String publicKey;
  const MultiSigMember({
    required this.groupId,
    required this.userId,
    required this.publicKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['user_id'] = Variable<String>(userId);
    map['public_key'] = Variable<String>(publicKey);
    return map;
  }

  MultiSigMembersCompanion toCompanion(bool nullToAbsent) {
    return MultiSigMembersCompanion(
      groupId: Value(groupId),
      userId: Value(userId),
      publicKey: Value(publicKey),
    );
  }

  factory MultiSigMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MultiSigMember(
      groupId: serializer.fromJson<String>(json['groupId']),
      userId: serializer.fromJson<String>(json['userId']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'userId': serializer.toJson<String>(userId),
      'publicKey': serializer.toJson<String>(publicKey),
    };
  }

  MultiSigMember copyWith({
    String? groupId,
    String? userId,
    String? publicKey,
  }) => MultiSigMember(
    groupId: groupId ?? this.groupId,
    userId: userId ?? this.userId,
    publicKey: publicKey ?? this.publicKey,
  );
  MultiSigMember copyWithCompanion(MultiSigMembersCompanion data) {
    return MultiSigMember(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      userId: data.userId.present ? data.userId.value : this.userId,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MultiSigMember(')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('publicKey: $publicKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, userId, publicKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MultiSigMember &&
          other.groupId == this.groupId &&
          other.userId == this.userId &&
          other.publicKey == this.publicKey);
}

class MultiSigMembersCompanion extends UpdateCompanion<MultiSigMember> {
  final Value<String> groupId;
  final Value<String> userId;
  final Value<String> publicKey;
  final Value<int> rowid;
  const MultiSigMembersCompanion({
    this.groupId = const Value.absent(),
    this.userId = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MultiSigMembersCompanion.insert({
    required String groupId,
    required String userId,
    required String publicKey,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       userId = Value(userId),
       publicKey = Value(publicKey);
  static Insertable<MultiSigMember> custom({
    Expression<String>? groupId,
    Expression<String>? userId,
    Expression<String>? publicKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (userId != null) 'user_id': userId,
      if (publicKey != null) 'public_key': publicKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MultiSigMembersCompanion copyWith({
    Value<String>? groupId,
    Value<String>? userId,
    Value<String>? publicKey,
    Value<int>? rowid,
  }) {
    return MultiSigMembersCompanion(
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      publicKey: publicKey ?? this.publicKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MultiSigMembersCompanion(')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('publicKey: $publicKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingSignaturesTable extends PendingSignatures
    with TableInfo<$PendingSignaturesTable, PendingSignature> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSignaturesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _signerIdMeta = const VerificationMeta(
    'signerId',
  );
  @override
  late final GeneratedColumn<String> signerId = GeneratedColumn<String>(
    'signer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
    'signature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signedAtMeta = const VerificationMeta(
    'signedAt',
  );
  @override
  late final GeneratedColumn<DateTime> signedAt = GeneratedColumn<DateTime>(
    'signed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    signerId,
    signature,
    signedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_signatures';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingSignature> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('signer_id')) {
      context.handle(
        _signerIdMeta,
        signerId.isAcceptableOrUnknown(data['signer_id']!, _signerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_signerIdMeta);
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    } else if (isInserting) {
      context.missing(_signatureMeta);
    }
    if (data.containsKey('signed_at')) {
      context.handle(
        _signedAtMeta,
        signedAt.isAcceptableOrUnknown(data['signed_at']!, _signedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSignature map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSignature(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      signerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signer_id'],
      )!,
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature'],
      )!,
      signedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}signed_at'],
      )!,
    );
  }

  @override
  $PendingSignaturesTable createAlias(String alias) {
    return $PendingSignaturesTable(attachedDatabase, alias);
  }
}

class PendingSignature extends DataClass
    implements Insertable<PendingSignature> {
  final int id;
  final String transactionId;
  final String signerId;
  final String signature;
  final DateTime signedAt;
  const PendingSignature({
    required this.id,
    required this.transactionId,
    required this.signerId,
    required this.signature,
    required this.signedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['signer_id'] = Variable<String>(signerId);
    map['signature'] = Variable<String>(signature);
    map['signed_at'] = Variable<DateTime>(signedAt);
    return map;
  }

  PendingSignaturesCompanion toCompanion(bool nullToAbsent) {
    return PendingSignaturesCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      signerId: Value(signerId),
      signature: Value(signature),
      signedAt: Value(signedAt),
    );
  }

  factory PendingSignature.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSignature(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      signerId: serializer.fromJson<String>(json['signerId']),
      signature: serializer.fromJson<String>(json['signature']),
      signedAt: serializer.fromJson<DateTime>(json['signedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'signerId': serializer.toJson<String>(signerId),
      'signature': serializer.toJson<String>(signature),
      'signedAt': serializer.toJson<DateTime>(signedAt),
    };
  }

  PendingSignature copyWith({
    int? id,
    String? transactionId,
    String? signerId,
    String? signature,
    DateTime? signedAt,
  }) => PendingSignature(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    signerId: signerId ?? this.signerId,
    signature: signature ?? this.signature,
    signedAt: signedAt ?? this.signedAt,
  );
  PendingSignature copyWithCompanion(PendingSignaturesCompanion data) {
    return PendingSignature(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      signerId: data.signerId.present ? data.signerId.value : this.signerId,
      signature: data.signature.present ? data.signature.value : this.signature,
      signedAt: data.signedAt.present ? data.signedAt.value : this.signedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSignature(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('signerId: $signerId, ')
          ..write('signature: $signature, ')
          ..write('signedAt: $signedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, transactionId, signerId, signature, signedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSignature &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.signerId == this.signerId &&
          other.signature == this.signature &&
          other.signedAt == this.signedAt);
}

class PendingSignaturesCompanion extends UpdateCompanion<PendingSignature> {
  final Value<int> id;
  final Value<String> transactionId;
  final Value<String> signerId;
  final Value<String> signature;
  final Value<DateTime> signedAt;
  const PendingSignaturesCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.signerId = const Value.absent(),
    this.signature = const Value.absent(),
    this.signedAt = const Value.absent(),
  });
  PendingSignaturesCompanion.insert({
    this.id = const Value.absent(),
    required String transactionId,
    required String signerId,
    required String signature,
    this.signedAt = const Value.absent(),
  }) : transactionId = Value(transactionId),
       signerId = Value(signerId),
       signature = Value(signature);
  static Insertable<PendingSignature> custom({
    Expression<int>? id,
    Expression<String>? transactionId,
    Expression<String>? signerId,
    Expression<String>? signature,
    Expression<DateTime>? signedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (signerId != null) 'signer_id': signerId,
      if (signature != null) 'signature': signature,
      if (signedAt != null) 'signed_at': signedAt,
    });
  }

  PendingSignaturesCompanion copyWith({
    Value<int>? id,
    Value<String>? transactionId,
    Value<String>? signerId,
    Value<String>? signature,
    Value<DateTime>? signedAt,
  }) {
    return PendingSignaturesCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      signerId: signerId ?? this.signerId,
      signature: signature ?? this.signature,
      signedAt: signedAt ?? this.signedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (signerId.present) {
      map['signer_id'] = Variable<String>(signerId.value);
    }
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
    }
    if (signedAt.present) {
      map['signed_at'] = Variable<DateTime>(signedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSignaturesCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('signerId: $signerId, ')
          ..write('signature: $signature, ')
          ..write('signedAt: $signedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final $DbNotificationsTable dbNotifications = $DbNotificationsTable(
    this,
  );
  late final $AiMemoriesTable aiMemories = $AiMemoriesTable(this);
  late final $MultiSigGroupsTable multiSigGroups = $MultiSigGroupsTable(this);
  late final $MultiSigMembersTable multiSigMembers = $MultiSigMembersTable(
    this,
  );
  late final $PendingSignaturesTable pendingSignatures =
      $PendingSignaturesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    appPreferences,
    dbNotifications,
    aiMemories,
    multiSigGroups,
    multiSigMembers,
    pendingSignatures,
  ];
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String title,
      required String subtitle,
      required double amount,
      Value<double> fee,
      Value<double> tax,
      required int iconCode,
      required int colorValue,
      Value<String> category,
      Value<String?> transactionType,
      Value<DateTime> createdAt,
      Value<String?> metadata,
      Value<String?> groupId,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> subtitle,
      Value<double> amount,
      Value<double> fee,
      Value<double> tax,
      Value<int> iconCode,
      Value<int> colorValue,
      Value<String> category,
      Value<String?> transactionType,
      Value<DateTime> createdAt,
      Value<String?> metadata,
      Value<String?> groupId,
      Value<String> status,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PendingSignaturesTable, List<PendingSignature>>
  _pendingSignaturesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pendingSignatures,
        aliasName: $_aliasNameGenerator(
          db.transactions.id,
          db.pendingSignatures.transactionId,
        ),
      );

  $$PendingSignaturesTableProcessedTableManager get pendingSignaturesRefs {
    final manager = $$PendingSignaturesTableTableManager(
      $_db,
      $_db.pendingSignatures,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pendingSignaturesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tax => $composableBuilder(
    column: $table.tax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pendingSignaturesRefs(
    Expression<bool> Function($$PendingSignaturesTableFilterComposer f) f,
  ) {
    final $$PendingSignaturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pendingSignatures,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PendingSignaturesTableFilterComposer(
            $db: $db,
            $table: $db.pendingSignatures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tax => $composableBuilder(
    column: $table.tax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumn<double> get tax =>
      $composableBuilder(column: $table.tax, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> pendingSignaturesRefs<T extends Object>(
    Expression<T> Function($$PendingSignaturesTableAnnotationComposer a) f,
  ) {
    final $$PendingSignaturesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pendingSignatures,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PendingSignaturesTableAnnotationComposer(
                $db: $db,
                $table: $db.pendingSignatures,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool pendingSignaturesRefs})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> fee = const Value.absent(),
                Value<double> tax = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> transactionType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                title: title,
                subtitle: subtitle,
                amount: amount,
                fee: fee,
                tax: tax,
                iconCode: iconCode,
                colorValue: colorValue,
                category: category,
                transactionType: transactionType,
                createdAt: createdAt,
                metadata: metadata,
                groupId: groupId,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String subtitle,
                required double amount,
                Value<double> fee = const Value.absent(),
                Value<double> tax = const Value.absent(),
                required int iconCode,
                required int colorValue,
                Value<String> category = const Value.absent(),
                Value<String?> transactionType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                title: title,
                subtitle: subtitle,
                amount: amount,
                fee: fee,
                tax: tax,
                iconCode: iconCode,
                colorValue: colorValue,
                category: category,
                transactionType: transactionType,
                createdAt: createdAt,
                metadata: metadata,
                groupId: groupId,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pendingSignaturesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pendingSignaturesRefs) db.pendingSignatures,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pendingSignaturesRefs)
                    await $_getPrefetchedData<
                      Transaction,
                      $TransactionsTable,
                      PendingSignature
                    >(
                      currentTable: table,
                      referencedTable: $$TransactionsTableReferences
                          ._pendingSignaturesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TransactionsTableReferences(
                            db,
                            table,
                            p0,
                          ).pendingSignaturesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.transactionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool pendingSignaturesRefs})
    >;
typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferencesTable,
          AppPreference,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreference,
            BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreference>,
          ),
          AppPreference,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$AppDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppPreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPreferencesTable,
      AppPreference,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreference,
        BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreference>,
      ),
      AppPreference,
      PrefetchHooks Function()
    >;
typedef $$DbNotificationsTableCreateCompanionBuilder =
    DbNotificationsCompanion Function({
      Value<int> id,
      required String title,
      required String body,
      Value<DateTime> receivedAt,
      Value<bool> isRead,
    });
typedef $$DbNotificationsTableUpdateCompanionBuilder =
    DbNotificationsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> body,
      Value<DateTime> receivedAt,
      Value<bool> isRead,
    });

class $$DbNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $DbNotificationsTable> {
  $$DbNotificationsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbNotificationsTable> {
  $$DbNotificationsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbNotificationsTable> {
  $$DbNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$DbNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbNotificationsTable,
          DbNotification,
          $$DbNotificationsTableFilterComposer,
          $$DbNotificationsTableOrderingComposer,
          $$DbNotificationsTableAnnotationComposer,
          $$DbNotificationsTableCreateCompanionBuilder,
          $$DbNotificationsTableUpdateCompanionBuilder,
          (
            DbNotification,
            BaseReferences<
              _$AppDatabase,
              $DbNotificationsTable,
              DbNotification
            >,
          ),
          DbNotification,
          PrefetchHooks Function()
        > {
  $$DbNotificationsTableTableManager(
    _$AppDatabase db,
    $DbNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbNotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
              }) => DbNotificationsCompanion(
                id: id,
                title: title,
                body: body,
                receivedAt: receivedAt,
                isRead: isRead,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String body,
                Value<DateTime> receivedAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
              }) => DbNotificationsCompanion.insert(
                id: id,
                title: title,
                body: body,
                receivedAt: receivedAt,
                isRead: isRead,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbNotificationsTable,
      DbNotification,
      $$DbNotificationsTableFilterComposer,
      $$DbNotificationsTableOrderingComposer,
      $$DbNotificationsTableAnnotationComposer,
      $$DbNotificationsTableCreateCompanionBuilder,
      $$DbNotificationsTableUpdateCompanionBuilder,
      (
        DbNotification,
        BaseReferences<_$AppDatabase, $DbNotificationsTable, DbNotification>,
      ),
      DbNotification,
      PrefetchHooks Function()
    >;
typedef $$AiMemoriesTableCreateCompanionBuilder =
    AiMemoriesCompanion Function({
      Value<int> id,
      required String role,
      required String content,
      Value<String> type,
      Value<DateTime> createdAt,
    });
typedef $$AiMemoriesTableUpdateCompanionBuilder =
    AiMemoriesCompanion Function({
      Value<int> id,
      Value<String> role,
      Value<String> content,
      Value<String> type,
      Value<DateTime> createdAt,
    });

class $$AiMemoriesTableFilterComposer
    extends Composer<_$AppDatabase, $AiMemoriesTable> {
  $$AiMemoriesTableFilterComposer({
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

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiMemoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiMemoriesTable> {
  $$AiMemoriesTableOrderingComposer({
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

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiMemoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiMemoriesTable> {
  $$AiMemoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiMemoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiMemoriesTable,
          AiMemory,
          $$AiMemoriesTableFilterComposer,
          $$AiMemoriesTableOrderingComposer,
          $$AiMemoriesTableAnnotationComposer,
          $$AiMemoriesTableCreateCompanionBuilder,
          $$AiMemoriesTableUpdateCompanionBuilder,
          (AiMemory, BaseReferences<_$AppDatabase, $AiMemoriesTable, AiMemory>),
          AiMemory,
          PrefetchHooks Function()
        > {
  $$AiMemoriesTableTableManager(_$AppDatabase db, $AiMemoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiMemoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiMemoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiMemoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AiMemoriesCompanion(
                id: id,
                role: role,
                content: content,
                type: type,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String role,
                required String content,
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AiMemoriesCompanion.insert(
                id: id,
                role: role,
                content: content,
                type: type,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiMemoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiMemoriesTable,
      AiMemory,
      $$AiMemoriesTableFilterComposer,
      $$AiMemoriesTableOrderingComposer,
      $$AiMemoriesTableAnnotationComposer,
      $$AiMemoriesTableCreateCompanionBuilder,
      $$AiMemoriesTableUpdateCompanionBuilder,
      (AiMemory, BaseReferences<_$AppDatabase, $AiMemoriesTable, AiMemory>),
      AiMemory,
      PrefetchHooks Function()
    >;
typedef $$MultiSigGroupsTableCreateCompanionBuilder =
    MultiSigGroupsCompanion Function({
      required String id,
      required String name,
      required String creatorId,
      required int threshold,
      required int totalMembers,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$MultiSigGroupsTableUpdateCompanionBuilder =
    MultiSigGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> creatorId,
      Value<int> threshold,
      Value<int> totalMembers,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MultiSigGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $MultiSigGroupsTable, MultiSigGroup> {
  $$MultiSigGroupsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MultiSigMembersTable, List<MultiSigMember>>
  _multiSigMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.multiSigMembers,
    aliasName: $_aliasNameGenerator(
      db.multiSigGroups.id,
      db.multiSigMembers.groupId,
    ),
  );

  $$MultiSigMembersTableProcessedTableManager get multiSigMembersRefs {
    final manager = $$MultiSigMembersTableTableManager(
      $_db,
      $_db.multiSigMembers,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _multiSigMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MultiSigGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $MultiSigGroupsTable> {
  $$MultiSigGroupsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMembers => $composableBuilder(
    column: $table.totalMembers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> multiSigMembersRefs(
    Expression<bool> Function($$MultiSigMembersTableFilterComposer f) f,
  ) {
    final $$MultiSigMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.multiSigMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MultiSigMembersTableFilterComposer(
            $db: $db,
            $table: $db.multiSigMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MultiSigGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $MultiSigGroupsTable> {
  $$MultiSigGroupsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMembers => $composableBuilder(
    column: $table.totalMembers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MultiSigGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MultiSigGroupsTable> {
  $$MultiSigGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<int> get threshold =>
      $composableBuilder(column: $table.threshold, builder: (column) => column);

  GeneratedColumn<int> get totalMembers => $composableBuilder(
    column: $table.totalMembers,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> multiSigMembersRefs<T extends Object>(
    Expression<T> Function($$MultiSigMembersTableAnnotationComposer a) f,
  ) {
    final $$MultiSigMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.multiSigMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MultiSigMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.multiSigMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MultiSigGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MultiSigGroupsTable,
          MultiSigGroup,
          $$MultiSigGroupsTableFilterComposer,
          $$MultiSigGroupsTableOrderingComposer,
          $$MultiSigGroupsTableAnnotationComposer,
          $$MultiSigGroupsTableCreateCompanionBuilder,
          $$MultiSigGroupsTableUpdateCompanionBuilder,
          (MultiSigGroup, $$MultiSigGroupsTableReferences),
          MultiSigGroup,
          PrefetchHooks Function({bool multiSigMembersRefs})
        > {
  $$MultiSigGroupsTableTableManager(
    _$AppDatabase db,
    $MultiSigGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MultiSigGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MultiSigGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MultiSigGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> creatorId = const Value.absent(),
                Value<int> threshold = const Value.absent(),
                Value<int> totalMembers = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MultiSigGroupsCompanion(
                id: id,
                name: name,
                creatorId: creatorId,
                threshold: threshold,
                totalMembers: totalMembers,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String creatorId,
                required int threshold,
                required int totalMembers,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MultiSigGroupsCompanion.insert(
                id: id,
                name: name,
                creatorId: creatorId,
                threshold: threshold,
                totalMembers: totalMembers,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MultiSigGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({multiSigMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (multiSigMembersRefs) db.multiSigMembers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (multiSigMembersRefs)
                    await $_getPrefetchedData<
                      MultiSigGroup,
                      $MultiSigGroupsTable,
                      MultiSigMember
                    >(
                      currentTable: table,
                      referencedTable: $$MultiSigGroupsTableReferences
                          ._multiSigMembersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MultiSigGroupsTableReferences(
                            db,
                            table,
                            p0,
                          ).multiSigMembersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.groupId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MultiSigGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MultiSigGroupsTable,
      MultiSigGroup,
      $$MultiSigGroupsTableFilterComposer,
      $$MultiSigGroupsTableOrderingComposer,
      $$MultiSigGroupsTableAnnotationComposer,
      $$MultiSigGroupsTableCreateCompanionBuilder,
      $$MultiSigGroupsTableUpdateCompanionBuilder,
      (MultiSigGroup, $$MultiSigGroupsTableReferences),
      MultiSigGroup,
      PrefetchHooks Function({bool multiSigMembersRefs})
    >;
typedef $$MultiSigMembersTableCreateCompanionBuilder =
    MultiSigMembersCompanion Function({
      required String groupId,
      required String userId,
      required String publicKey,
      Value<int> rowid,
    });
typedef $$MultiSigMembersTableUpdateCompanionBuilder =
    MultiSigMembersCompanion Function({
      Value<String> groupId,
      Value<String> userId,
      Value<String> publicKey,
      Value<int> rowid,
    });

final class $$MultiSigMembersTableReferences
    extends
        BaseReferences<_$AppDatabase, $MultiSigMembersTable, MultiSigMember> {
  $$MultiSigMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MultiSigGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.multiSigGroups.createAlias(
        $_aliasNameGenerator(db.multiSigMembers.groupId, db.multiSigGroups.id),
      );

  $$MultiSigGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$MultiSigGroupsTableTableManager(
      $_db,
      $_db.multiSigGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MultiSigMembersTableFilterComposer
    extends Composer<_$AppDatabase, $MultiSigMembersTable> {
  $$MultiSigMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  $$MultiSigGroupsTableFilterComposer get groupId {
    final $$MultiSigGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.multiSigGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MultiSigGroupsTableFilterComposer(
            $db: $db,
            $table: $db.multiSigGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MultiSigMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MultiSigMembersTable> {
  $$MultiSigMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$MultiSigGroupsTableOrderingComposer get groupId {
    final $$MultiSigGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.multiSigGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MultiSigGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.multiSigGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MultiSigMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MultiSigMembersTable> {
  $$MultiSigMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  $$MultiSigGroupsTableAnnotationComposer get groupId {
    final $$MultiSigGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.multiSigGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MultiSigGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.multiSigGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MultiSigMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MultiSigMembersTable,
          MultiSigMember,
          $$MultiSigMembersTableFilterComposer,
          $$MultiSigMembersTableOrderingComposer,
          $$MultiSigMembersTableAnnotationComposer,
          $$MultiSigMembersTableCreateCompanionBuilder,
          $$MultiSigMembersTableUpdateCompanionBuilder,
          (MultiSigMember, $$MultiSigMembersTableReferences),
          MultiSigMember,
          PrefetchHooks Function({bool groupId})
        > {
  $$MultiSigMembersTableTableManager(
    _$AppDatabase db,
    $MultiSigMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MultiSigMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MultiSigMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MultiSigMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> publicKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MultiSigMembersCompanion(
                groupId: groupId,
                userId: userId,
                publicKey: publicKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String userId,
                required String publicKey,
                Value<int> rowid = const Value.absent(),
              }) => MultiSigMembersCompanion.insert(
                groupId: groupId,
                userId: userId,
                publicKey: publicKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MultiSigMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
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
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable:
                                    $$MultiSigMembersTableReferences
                                        ._groupIdTable(db),
                                referencedColumn:
                                    $$MultiSigMembersTableReferences
                                        ._groupIdTable(db)
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

typedef $$MultiSigMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MultiSigMembersTable,
      MultiSigMember,
      $$MultiSigMembersTableFilterComposer,
      $$MultiSigMembersTableOrderingComposer,
      $$MultiSigMembersTableAnnotationComposer,
      $$MultiSigMembersTableCreateCompanionBuilder,
      $$MultiSigMembersTableUpdateCompanionBuilder,
      (MultiSigMember, $$MultiSigMembersTableReferences),
      MultiSigMember,
      PrefetchHooks Function({bool groupId})
    >;
typedef $$PendingSignaturesTableCreateCompanionBuilder =
    PendingSignaturesCompanion Function({
      Value<int> id,
      required String transactionId,
      required String signerId,
      required String signature,
      Value<DateTime> signedAt,
    });
typedef $$PendingSignaturesTableUpdateCompanionBuilder =
    PendingSignaturesCompanion Function({
      Value<int> id,
      Value<String> transactionId,
      Value<String> signerId,
      Value<String> signature,
      Value<DateTime> signedAt,
    });

final class $$PendingSignaturesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PendingSignaturesTable,
          PendingSignature
        > {
  $$PendingSignaturesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(
          db.pendingSignatures.transactionId,
          db.transactions.id,
        ),
      );

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PendingSignaturesTableFilterComposer
    extends Composer<_$AppDatabase, $PendingSignaturesTable> {
  $$PendingSignaturesTableFilterComposer({
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

  ColumnFilters<String> get signerId => $composableBuilder(
    column: $table.signerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get signedAt => $composableBuilder(
    column: $table.signedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingSignaturesTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingSignaturesTable> {
  $$PendingSignaturesTableOrderingComposer({
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

  ColumnOrderings<String> get signerId => $composableBuilder(
    column: $table.signerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get signedAt => $composableBuilder(
    column: $table.signedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingSignaturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingSignaturesTable> {
  $$PendingSignaturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get signerId =>
      $composableBuilder(column: $table.signerId, builder: (column) => column);

  GeneratedColumn<String> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<DateTime> get signedAt =>
      $composableBuilder(column: $table.signedAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingSignaturesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingSignaturesTable,
          PendingSignature,
          $$PendingSignaturesTableFilterComposer,
          $$PendingSignaturesTableOrderingComposer,
          $$PendingSignaturesTableAnnotationComposer,
          $$PendingSignaturesTableCreateCompanionBuilder,
          $$PendingSignaturesTableUpdateCompanionBuilder,
          (PendingSignature, $$PendingSignaturesTableReferences),
          PendingSignature,
          PrefetchHooks Function({bool transactionId})
        > {
  $$PendingSignaturesTableTableManager(
    _$AppDatabase db,
    $PendingSignaturesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSignaturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingSignaturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingSignaturesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> signerId = const Value.absent(),
                Value<String> signature = const Value.absent(),
                Value<DateTime> signedAt = const Value.absent(),
              }) => PendingSignaturesCompanion(
                id: id,
                transactionId: transactionId,
                signerId: signerId,
                signature: signature,
                signedAt: signedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String transactionId,
                required String signerId,
                required String signature,
                Value<DateTime> signedAt = const Value.absent(),
              }) => PendingSignaturesCompanion.insert(
                id: id,
                transactionId: transactionId,
                signerId: signerId,
                signature: signature,
                signedAt: signedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PendingSignaturesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
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
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$PendingSignaturesTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$PendingSignaturesTableReferences
                                        ._transactionIdTable(db)
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

typedef $$PendingSignaturesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingSignaturesTable,
      PendingSignature,
      $$PendingSignaturesTableFilterComposer,
      $$PendingSignaturesTableOrderingComposer,
      $$PendingSignaturesTableAnnotationComposer,
      $$PendingSignaturesTableCreateCompanionBuilder,
      $$PendingSignaturesTableUpdateCompanionBuilder,
      (PendingSignature, $$PendingSignaturesTableReferences),
      PendingSignature,
      PrefetchHooks Function({bool transactionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
  $$DbNotificationsTableTableManager get dbNotifications =>
      $$DbNotificationsTableTableManager(_db, _db.dbNotifications);
  $$AiMemoriesTableTableManager get aiMemories =>
      $$AiMemoriesTableTableManager(_db, _db.aiMemories);
  $$MultiSigGroupsTableTableManager get multiSigGroups =>
      $$MultiSigGroupsTableTableManager(_db, _db.multiSigGroups);
  $$MultiSigMembersTableTableManager get multiSigMembers =>
      $$MultiSigMembersTableTableManager(_db, _db.multiSigMembers);
  $$PendingSignaturesTableTableManager get pendingSignatures =>
      $$PendingSignaturesTableTableManager(_db, _db.pendingSignatures);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'617f2de64c84825b761f6451ce5df331a811c324';
