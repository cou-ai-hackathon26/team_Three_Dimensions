// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CasesTable extends Cases with TableInfo<$CasesTable, Case> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, title, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cases';
  @override
  VerificationContext validateIntegrity(Insertable<Case> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Case map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Case(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CasesTable createAlias(String alias) {
    return $CasesTable(attachedDatabase, alias);
  }
}

class Case extends DataClass implements Insertable<Case> {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Case(
      {required this.id,
      required this.title,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CasesCompanion toCompanion(bool nullToAbsent) {
    return CasesCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Case.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Case(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Case copyWith(
          {String? id,
          String? title,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Case(
        id: id ?? this.id,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Case copyWithCompanion(CasesCompanion data) {
    return Case(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Case(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Case &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CasesCompanion extends UpdateCompanion<Case> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CasesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CasesCompanion.insert({
    required String id,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Case> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CasesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CasesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CasesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatTurnsTable extends ChatTurns
    with TableInfo<$ChatTurnsTable, ChatTurn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatTurnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
      'case_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textContentMeta =
      const VerificationMeta('textContent');
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
      'text_content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _responseJsonMeta =
      const VerificationMeta('responseJson');
  @override
  late final GeneratedColumn<String> responseJson = GeneratedColumn<String>(
      'response_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSupersededMeta =
      const VerificationMeta('isSuperseded');
  @override
  late final GeneratedColumn<bool> isSuperseded = GeneratedColumn<bool>(
      'is_superseded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_superseded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, caseId, role, textContent, responseJson, isSuperseded, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_turns';
  @override
  VerificationContext validateIntegrity(Insertable<ChatTurn> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('case_id')) {
      context.handle(_caseIdMeta,
          caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta));
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
          _textContentMeta,
          textContent.isAcceptableOrUnknown(
              data['text_content']!, _textContentMeta));
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('response_json')) {
      context.handle(
          _responseJsonMeta,
          responseJson.isAcceptableOrUnknown(
              data['response_json']!, _responseJsonMeta));
    }
    if (data.containsKey('is_superseded')) {
      context.handle(
          _isSupersededMeta,
          isSuperseded.isAcceptableOrUnknown(
              data['is_superseded']!, _isSupersededMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatTurn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatTurn(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      caseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      textContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_content'])!,
      responseJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}response_json']),
      isSuperseded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_superseded'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $ChatTurnsTable createAlias(String alias) {
    return $ChatTurnsTable(attachedDatabase, alias);
  }
}

class ChatTurn extends DataClass implements Insertable<ChatTurn> {
  final String id;
  final String caseId;
  final String role;
  final String textContent;
  final String? responseJson;
  final bool isSuperseded;
  final DateTime timestamp;
  const ChatTurn(
      {required this.id,
      required this.caseId,
      required this.role,
      required this.textContent,
      this.responseJson,
      required this.isSuperseded,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['case_id'] = Variable<String>(caseId);
    map['role'] = Variable<String>(role);
    map['text_content'] = Variable<String>(textContent);
    if (!nullToAbsent || responseJson != null) {
      map['response_json'] = Variable<String>(responseJson);
    }
    map['is_superseded'] = Variable<bool>(isSuperseded);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  ChatTurnsCompanion toCompanion(bool nullToAbsent) {
    return ChatTurnsCompanion(
      id: Value(id),
      caseId: Value(caseId),
      role: Value(role),
      textContent: Value(textContent),
      responseJson: responseJson == null && nullToAbsent
          ? const Value.absent()
          : Value(responseJson),
      isSuperseded: Value(isSuperseded),
      timestamp: Value(timestamp),
    );
  }

  factory ChatTurn.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatTurn(
      id: serializer.fromJson<String>(json['id']),
      caseId: serializer.fromJson<String>(json['caseId']),
      role: serializer.fromJson<String>(json['role']),
      textContent: serializer.fromJson<String>(json['textContent']),
      responseJson: serializer.fromJson<String?>(json['responseJson']),
      isSuperseded: serializer.fromJson<bool>(json['isSuperseded']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'caseId': serializer.toJson<String>(caseId),
      'role': serializer.toJson<String>(role),
      'textContent': serializer.toJson<String>(textContent),
      'responseJson': serializer.toJson<String?>(responseJson),
      'isSuperseded': serializer.toJson<bool>(isSuperseded),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  ChatTurn copyWith(
          {String? id,
          String? caseId,
          String? role,
          String? textContent,
          Value<String?> responseJson = const Value.absent(),
          bool? isSuperseded,
          DateTime? timestamp}) =>
      ChatTurn(
        id: id ?? this.id,
        caseId: caseId ?? this.caseId,
        role: role ?? this.role,
        textContent: textContent ?? this.textContent,
        responseJson:
            responseJson.present ? responseJson.value : this.responseJson,
        isSuperseded: isSuperseded ?? this.isSuperseded,
        timestamp: timestamp ?? this.timestamp,
      );
  ChatTurn copyWithCompanion(ChatTurnsCompanion data) {
    return ChatTurn(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      role: data.role.present ? data.role.value : this.role,
      textContent:
          data.textContent.present ? data.textContent.value : this.textContent,
      responseJson: data.responseJson.present
          ? data.responseJson.value
          : this.responseJson,
      isSuperseded: data.isSuperseded.present
          ? data.isSuperseded.value
          : this.isSuperseded,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatTurn(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('role: $role, ')
          ..write('textContent: $textContent, ')
          ..write('responseJson: $responseJson, ')
          ..write('isSuperseded: $isSuperseded, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, caseId, role, textContent, responseJson, isSuperseded, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatTurn &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.role == this.role &&
          other.textContent == this.textContent &&
          other.responseJson == this.responseJson &&
          other.isSuperseded == this.isSuperseded &&
          other.timestamp == this.timestamp);
}

class ChatTurnsCompanion extends UpdateCompanion<ChatTurn> {
  final Value<String> id;
  final Value<String> caseId;
  final Value<String> role;
  final Value<String> textContent;
  final Value<String?> responseJson;
  final Value<bool> isSuperseded;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const ChatTurnsCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.role = const Value.absent(),
    this.textContent = const Value.absent(),
    this.responseJson = const Value.absent(),
    this.isSuperseded = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatTurnsCompanion.insert({
    required String id,
    required String caseId,
    required String role,
    required String textContent,
    this.responseJson = const Value.absent(),
    this.isSuperseded = const Value.absent(),
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        caseId = Value(caseId),
        role = Value(role),
        textContent = Value(textContent),
        timestamp = Value(timestamp);
  static Insertable<ChatTurn> custom({
    Expression<String>? id,
    Expression<String>? caseId,
    Expression<String>? role,
    Expression<String>? textContent,
    Expression<String>? responseJson,
    Expression<bool>? isSuperseded,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (caseId != null) 'case_id': caseId,
      if (role != null) 'role': role,
      if (textContent != null) 'text_content': textContent,
      if (responseJson != null) 'response_json': responseJson,
      if (isSuperseded != null) 'is_superseded': isSuperseded,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatTurnsCompanion copyWith(
      {Value<String>? id,
      Value<String>? caseId,
      Value<String>? role,
      Value<String>? textContent,
      Value<String?>? responseJson,
      Value<bool>? isSuperseded,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return ChatTurnsCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      role: role ?? this.role,
      textContent: textContent ?? this.textContent,
      responseJson: responseJson ?? this.responseJson,
      isSuperseded: isSuperseded ?? this.isSuperseded,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (responseJson.present) {
      map['response_json'] = Variable<String>(responseJson.value);
    }
    if (isSuperseded.present) {
      map['is_superseded'] = Variable<bool>(isSuperseded.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatTurnsCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('role: $role, ')
          ..write('textContent: $textContent, ')
          ..write('responseJson: $responseJson, ')
          ..write('isSuperseded: $isSuperseded, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDraftsTable extends LocalDrafts
    with TableInfo<$LocalDraftsTable, LocalDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
      'case_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recipientMeta =
      const VerificationMeta('recipient');
  @override
  late final GeneratedColumn<String> recipient = GeneratedColumn<String>(
      'recipient', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _factsJsonMeta =
      const VerificationMeta('factsJson');
  @override
  late final GeneratedColumn<String> factsJson = GeneratedColumn<String>(
      'facts_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _applicantNameMeta =
      const VerificationMeta('applicantName');
  @override
  late final GeneratedColumn<String> applicantName = GeneratedColumn<String>(
      'applicant_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _applicantPhoneMeta =
      const VerificationMeta('applicantPhone');
  @override
  late final GeneratedColumn<String> applicantPhone = GeneratedColumn<String>(
      'applicant_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _applicantAddressMeta =
      const VerificationMeta('applicantAddress');
  @override
  late final GeneratedColumn<String> applicantAddress = GeneratedColumn<String>(
      'applicant_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _officeNameMeta =
      const VerificationMeta('officeName');
  @override
  late final GeneratedColumn<String> officeName = GeneratedColumn<String>(
      'office_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        caseId,
        type,
        title,
        recipient,
        subject,
        body,
        factsJson,
        applicantName,
        applicantPhone,
        applicantAddress,
        officeName,
        status,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_drafts';
  @override
  VerificationContext validateIntegrity(Insertable<LocalDraft> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('case_id')) {
      context.handle(_caseIdMeta,
          caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('recipient')) {
      context.handle(_recipientMeta,
          recipient.isAcceptableOrUnknown(data['recipient']!, _recipientMeta));
    } else if (isInserting) {
      context.missing(_recipientMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('facts_json')) {
      context.handle(_factsJsonMeta,
          factsJson.isAcceptableOrUnknown(data['facts_json']!, _factsJsonMeta));
    } else if (isInserting) {
      context.missing(_factsJsonMeta);
    }
    if (data.containsKey('applicant_name')) {
      context.handle(
          _applicantNameMeta,
          applicantName.isAcceptableOrUnknown(
              data['applicant_name']!, _applicantNameMeta));
    }
    if (data.containsKey('applicant_phone')) {
      context.handle(
          _applicantPhoneMeta,
          applicantPhone.isAcceptableOrUnknown(
              data['applicant_phone']!, _applicantPhoneMeta));
    }
    if (data.containsKey('applicant_address')) {
      context.handle(
          _applicantAddressMeta,
          applicantAddress.isAcceptableOrUnknown(
              data['applicant_address']!, _applicantAddressMeta));
    }
    if (data.containsKey('office_name')) {
      context.handle(
          _officeNameMeta,
          officeName.isAcceptableOrUnknown(
              data['office_name']!, _officeNameMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDraft(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      caseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      recipient: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipient'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      factsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}facts_json'])!,
      applicantName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}applicant_name']),
      applicantPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}applicant_phone']),
      applicantAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}applicant_address']),
      officeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}office_name']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalDraftsTable createAlias(String alias) {
    return $LocalDraftsTable(attachedDatabase, alias);
  }
}

class LocalDraft extends DataClass implements Insertable<LocalDraft> {
  final String id;
  final String? caseId;
  final String type;
  final String title;
  final String recipient;
  final String subject;
  final String body;
  final String factsJson;
  final String? applicantName;
  final String? applicantPhone;
  final String? applicantAddress;
  final String? officeName;
  final String status;
  final DateTime updatedAt;
  const LocalDraft(
      {required this.id,
      this.caseId,
      required this.type,
      required this.title,
      required this.recipient,
      required this.subject,
      required this.body,
      required this.factsJson,
      this.applicantName,
      this.applicantPhone,
      this.applicantAddress,
      this.officeName,
      required this.status,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || caseId != null) {
      map['case_id'] = Variable<String>(caseId);
    }
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['recipient'] = Variable<String>(recipient);
    map['subject'] = Variable<String>(subject);
    map['body'] = Variable<String>(body);
    map['facts_json'] = Variable<String>(factsJson);
    if (!nullToAbsent || applicantName != null) {
      map['applicant_name'] = Variable<String>(applicantName);
    }
    if (!nullToAbsent || applicantPhone != null) {
      map['applicant_phone'] = Variable<String>(applicantPhone);
    }
    if (!nullToAbsent || applicantAddress != null) {
      map['applicant_address'] = Variable<String>(applicantAddress);
    }
    if (!nullToAbsent || officeName != null) {
      map['office_name'] = Variable<String>(officeName);
    }
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalDraftsCompanion toCompanion(bool nullToAbsent) {
    return LocalDraftsCompanion(
      id: Value(id),
      caseId:
          caseId == null && nullToAbsent ? const Value.absent() : Value(caseId),
      type: Value(type),
      title: Value(title),
      recipient: Value(recipient),
      subject: Value(subject),
      body: Value(body),
      factsJson: Value(factsJson),
      applicantName: applicantName == null && nullToAbsent
          ? const Value.absent()
          : Value(applicantName),
      applicantPhone: applicantPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(applicantPhone),
      applicantAddress: applicantAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(applicantAddress),
      officeName: officeName == null && nullToAbsent
          ? const Value.absent()
          : Value(officeName),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalDraft.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDraft(
      id: serializer.fromJson<String>(json['id']),
      caseId: serializer.fromJson<String?>(json['caseId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      recipient: serializer.fromJson<String>(json['recipient']),
      subject: serializer.fromJson<String>(json['subject']),
      body: serializer.fromJson<String>(json['body']),
      factsJson: serializer.fromJson<String>(json['factsJson']),
      applicantName: serializer.fromJson<String?>(json['applicantName']),
      applicantPhone: serializer.fromJson<String?>(json['applicantPhone']),
      applicantAddress: serializer.fromJson<String?>(json['applicantAddress']),
      officeName: serializer.fromJson<String?>(json['officeName']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'caseId': serializer.toJson<String?>(caseId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'recipient': serializer.toJson<String>(recipient),
      'subject': serializer.toJson<String>(subject),
      'body': serializer.toJson<String>(body),
      'factsJson': serializer.toJson<String>(factsJson),
      'applicantName': serializer.toJson<String?>(applicantName),
      'applicantPhone': serializer.toJson<String?>(applicantPhone),
      'applicantAddress': serializer.toJson<String?>(applicantAddress),
      'officeName': serializer.toJson<String?>(officeName),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalDraft copyWith(
          {String? id,
          Value<String?> caseId = const Value.absent(),
          String? type,
          String? title,
          String? recipient,
          String? subject,
          String? body,
          String? factsJson,
          Value<String?> applicantName = const Value.absent(),
          Value<String?> applicantPhone = const Value.absent(),
          Value<String?> applicantAddress = const Value.absent(),
          Value<String?> officeName = const Value.absent(),
          String? status,
          DateTime? updatedAt}) =>
      LocalDraft(
        id: id ?? this.id,
        caseId: caseId.present ? caseId.value : this.caseId,
        type: type ?? this.type,
        title: title ?? this.title,
        recipient: recipient ?? this.recipient,
        subject: subject ?? this.subject,
        body: body ?? this.body,
        factsJson: factsJson ?? this.factsJson,
        applicantName:
            applicantName.present ? applicantName.value : this.applicantName,
        applicantPhone:
            applicantPhone.present ? applicantPhone.value : this.applicantPhone,
        applicantAddress: applicantAddress.present
            ? applicantAddress.value
            : this.applicantAddress,
        officeName: officeName.present ? officeName.value : this.officeName,
        status: status ?? this.status,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalDraft copyWithCompanion(LocalDraftsCompanion data) {
    return LocalDraft(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      recipient: data.recipient.present ? data.recipient.value : this.recipient,
      subject: data.subject.present ? data.subject.value : this.subject,
      body: data.body.present ? data.body.value : this.body,
      factsJson: data.factsJson.present ? data.factsJson.value : this.factsJson,
      applicantName: data.applicantName.present
          ? data.applicantName.value
          : this.applicantName,
      applicantPhone: data.applicantPhone.present
          ? data.applicantPhone.value
          : this.applicantPhone,
      applicantAddress: data.applicantAddress.present
          ? data.applicantAddress.value
          : this.applicantAddress,
      officeName:
          data.officeName.present ? data.officeName.value : this.officeName,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDraft(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('recipient: $recipient, ')
          ..write('subject: $subject, ')
          ..write('body: $body, ')
          ..write('factsJson: $factsJson, ')
          ..write('applicantName: $applicantName, ')
          ..write('applicantPhone: $applicantPhone, ')
          ..write('applicantAddress: $applicantAddress, ')
          ..write('officeName: $officeName, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      caseId,
      type,
      title,
      recipient,
      subject,
      body,
      factsJson,
      applicantName,
      applicantPhone,
      applicantAddress,
      officeName,
      status,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDraft &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.type == this.type &&
          other.title == this.title &&
          other.recipient == this.recipient &&
          other.subject == this.subject &&
          other.body == this.body &&
          other.factsJson == this.factsJson &&
          other.applicantName == this.applicantName &&
          other.applicantPhone == this.applicantPhone &&
          other.applicantAddress == this.applicantAddress &&
          other.officeName == this.officeName &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class LocalDraftsCompanion extends UpdateCompanion<LocalDraft> {
  final Value<String> id;
  final Value<String?> caseId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> recipient;
  final Value<String> subject;
  final Value<String> body;
  final Value<String> factsJson;
  final Value<String?> applicantName;
  final Value<String?> applicantPhone;
  final Value<String?> applicantAddress;
  final Value<String?> officeName;
  final Value<String> status;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalDraftsCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.recipient = const Value.absent(),
    this.subject = const Value.absent(),
    this.body = const Value.absent(),
    this.factsJson = const Value.absent(),
    this.applicantName = const Value.absent(),
    this.applicantPhone = const Value.absent(),
    this.applicantAddress = const Value.absent(),
    this.officeName = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDraftsCompanion.insert({
    required String id,
    this.caseId = const Value.absent(),
    required String type,
    required String title,
    required String recipient,
    required String subject,
    required String body,
    required String factsJson,
    this.applicantName = const Value.absent(),
    this.applicantPhone = const Value.absent(),
    this.applicantAddress = const Value.absent(),
    this.officeName = const Value.absent(),
    required String status,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        title = Value(title),
        recipient = Value(recipient),
        subject = Value(subject),
        body = Value(body),
        factsJson = Value(factsJson),
        status = Value(status),
        updatedAt = Value(updatedAt);
  static Insertable<LocalDraft> custom({
    Expression<String>? id,
    Expression<String>? caseId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? recipient,
    Expression<String>? subject,
    Expression<String>? body,
    Expression<String>? factsJson,
    Expression<String>? applicantName,
    Expression<String>? applicantPhone,
    Expression<String>? applicantAddress,
    Expression<String>? officeName,
    Expression<String>? status,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (caseId != null) 'case_id': caseId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (recipient != null) 'recipient': recipient,
      if (subject != null) 'subject': subject,
      if (body != null) 'body': body,
      if (factsJson != null) 'facts_json': factsJson,
      if (applicantName != null) 'applicant_name': applicantName,
      if (applicantPhone != null) 'applicant_phone': applicantPhone,
      if (applicantAddress != null) 'applicant_address': applicantAddress,
      if (officeName != null) 'office_name': officeName,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDraftsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? caseId,
      Value<String>? type,
      Value<String>? title,
      Value<String>? recipient,
      Value<String>? subject,
      Value<String>? body,
      Value<String>? factsJson,
      Value<String?>? applicantName,
      Value<String?>? applicantPhone,
      Value<String?>? applicantAddress,
      Value<String?>? officeName,
      Value<String>? status,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalDraftsCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      type: type ?? this.type,
      title: title ?? this.title,
      recipient: recipient ?? this.recipient,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      factsJson: factsJson ?? this.factsJson,
      applicantName: applicantName ?? this.applicantName,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      applicantAddress: applicantAddress ?? this.applicantAddress,
      officeName: officeName ?? this.officeName,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (recipient.present) {
      map['recipient'] = Variable<String>(recipient.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (factsJson.present) {
      map['facts_json'] = Variable<String>(factsJson.value);
    }
    if (applicantName.present) {
      map['applicant_name'] = Variable<String>(applicantName.value);
    }
    if (applicantPhone.present) {
      map['applicant_phone'] = Variable<String>(applicantPhone.value);
    }
    if (applicantAddress.present) {
      map['applicant_address'] = Variable<String>(applicantAddress.value);
    }
    if (officeName.present) {
      map['office_name'] = Variable<String>(officeName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDraftsCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('recipient: $recipient, ')
          ..write('subject: $subject, ')
          ..write('body: $body, ')
          ..write('factsJson: $factsJson, ')
          ..write('applicantName: $applicantName, ')
          ..write('applicantPhone: $applicantPhone, ')
          ..write('applicantAddress: $applicantAddress, ')
          ..write('officeName: $officeName, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatutoryProvisionsTable extends StatutoryProvisions
    with TableInfo<$StatutoryProvisionsTable, StatutoryProvision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatutoryProvisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _provisionPathMeta =
      const VerificationMeta('provisionPath');
  @override
  late final GeneratedColumn<String> provisionPath = GeneratedColumn<String>(
      'provision_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originalTextMeta =
      const VerificationMeta('originalText');
  @override
  late final GeneratedColumn<String> originalText = GeneratedColumn<String>(
      'original_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plainExplanationMeta =
      const VerificationMeta('plainExplanation');
  @override
  late final GeneratedColumn<String> plainExplanation = GeneratedColumn<String>(
      'plain_explanation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _officialUrlMeta =
      const VerificationMeta('officialUrl');
  @override
  late final GeneratedColumn<String> officialUrl = GeneratedColumn<String>(
      'official_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordVersionMeta =
      const VerificationMeta('recordVersion');
  @override
  late final GeneratedColumn<String> recordVersion = GeneratedColumn<String>(
      'record_version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('1.0'));
  static const VerificationMeta _packVersionMeta =
      const VerificationMeta('packVersion');
  @override
  late final GeneratedColumn<String> packVersion = GeneratedColumn<String>(
      'pack_version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('bd-pilot-2026-10-27.1'));
  static const VerificationMeta _legalStatusMeta =
      const VerificationMeta('legalStatus');
  @override
  late final GeneratedColumn<String> legalStatus = GeneratedColumn<String>(
      'legal_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('in_force'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        provisionPath,
        originalText,
        plainExplanation,
        officialUrl,
        category,
        recordVersion,
        packVersion,
        legalStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statutory_provisions';
  @override
  VerificationContext validateIntegrity(Insertable<StatutoryProvision> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('provision_path')) {
      context.handle(
          _provisionPathMeta,
          provisionPath.isAcceptableOrUnknown(
              data['provision_path']!, _provisionPathMeta));
    } else if (isInserting) {
      context.missing(_provisionPathMeta);
    }
    if (data.containsKey('original_text')) {
      context.handle(
          _originalTextMeta,
          originalText.isAcceptableOrUnknown(
              data['original_text']!, _originalTextMeta));
    } else if (isInserting) {
      context.missing(_originalTextMeta);
    }
    if (data.containsKey('plain_explanation')) {
      context.handle(
          _plainExplanationMeta,
          plainExplanation.isAcceptableOrUnknown(
              data['plain_explanation']!, _plainExplanationMeta));
    }
    if (data.containsKey('official_url')) {
      context.handle(
          _officialUrlMeta,
          officialUrl.isAcceptableOrUnknown(
              data['official_url']!, _officialUrlMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('record_version')) {
      context.handle(
          _recordVersionMeta,
          recordVersion.isAcceptableOrUnknown(
              data['record_version']!, _recordVersionMeta));
    }
    if (data.containsKey('pack_version')) {
      context.handle(
          _packVersionMeta,
          packVersion.isAcceptableOrUnknown(
              data['pack_version']!, _packVersionMeta));
    }
    if (data.containsKey('legal_status')) {
      context.handle(
          _legalStatusMeta,
          legalStatus.isAcceptableOrUnknown(
              data['legal_status']!, _legalStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StatutoryProvision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatutoryProvision(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      provisionPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provision_path'])!,
      originalText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_text'])!,
      plainExplanation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}plain_explanation']),
      officialUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}official_url']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      recordVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_version'])!,
      packVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pack_version'])!,
      legalStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}legal_status'])!,
    );
  }

  @override
  $StatutoryProvisionsTable createAlias(String alias) {
    return $StatutoryProvisionsTable(attachedDatabase, alias);
  }
}

class StatutoryProvision extends DataClass
    implements Insertable<StatutoryProvision> {
  final String id;
  final String title;
  final String provisionPath;
  final String originalText;
  final String? plainExplanation;
  final String? officialUrl;
  final String category;
  final String recordVersion;
  final String packVersion;
  final String legalStatus;
  const StatutoryProvision(
      {required this.id,
      required this.title,
      required this.provisionPath,
      required this.originalText,
      this.plainExplanation,
      this.officialUrl,
      required this.category,
      required this.recordVersion,
      required this.packVersion,
      required this.legalStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['provision_path'] = Variable<String>(provisionPath);
    map['original_text'] = Variable<String>(originalText);
    if (!nullToAbsent || plainExplanation != null) {
      map['plain_explanation'] = Variable<String>(plainExplanation);
    }
    if (!nullToAbsent || officialUrl != null) {
      map['official_url'] = Variable<String>(officialUrl);
    }
    map['category'] = Variable<String>(category);
    map['record_version'] = Variable<String>(recordVersion);
    map['pack_version'] = Variable<String>(packVersion);
    map['legal_status'] = Variable<String>(legalStatus);
    return map;
  }

  StatutoryProvisionsCompanion toCompanion(bool nullToAbsent) {
    return StatutoryProvisionsCompanion(
      id: Value(id),
      title: Value(title),
      provisionPath: Value(provisionPath),
      originalText: Value(originalText),
      plainExplanation: plainExplanation == null && nullToAbsent
          ? const Value.absent()
          : Value(plainExplanation),
      officialUrl: officialUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(officialUrl),
      category: Value(category),
      recordVersion: Value(recordVersion),
      packVersion: Value(packVersion),
      legalStatus: Value(legalStatus),
    );
  }

  factory StatutoryProvision.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatutoryProvision(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      provisionPath: serializer.fromJson<String>(json['provisionPath']),
      originalText: serializer.fromJson<String>(json['originalText']),
      plainExplanation: serializer.fromJson<String?>(json['plainExplanation']),
      officialUrl: serializer.fromJson<String?>(json['officialUrl']),
      category: serializer.fromJson<String>(json['category']),
      recordVersion: serializer.fromJson<String>(json['recordVersion']),
      packVersion: serializer.fromJson<String>(json['packVersion']),
      legalStatus: serializer.fromJson<String>(json['legalStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'provisionPath': serializer.toJson<String>(provisionPath),
      'originalText': serializer.toJson<String>(originalText),
      'plainExplanation': serializer.toJson<String?>(plainExplanation),
      'officialUrl': serializer.toJson<String?>(officialUrl),
      'category': serializer.toJson<String>(category),
      'recordVersion': serializer.toJson<String>(recordVersion),
      'packVersion': serializer.toJson<String>(packVersion),
      'legalStatus': serializer.toJson<String>(legalStatus),
    };
  }

  StatutoryProvision copyWith(
          {String? id,
          String? title,
          String? provisionPath,
          String? originalText,
          Value<String?> plainExplanation = const Value.absent(),
          Value<String?> officialUrl = const Value.absent(),
          String? category,
          String? recordVersion,
          String? packVersion,
          String? legalStatus}) =>
      StatutoryProvision(
        id: id ?? this.id,
        title: title ?? this.title,
        provisionPath: provisionPath ?? this.provisionPath,
        originalText: originalText ?? this.originalText,
        plainExplanation: plainExplanation.present
            ? plainExplanation.value
            : this.plainExplanation,
        officialUrl: officialUrl.present ? officialUrl.value : this.officialUrl,
        category: category ?? this.category,
        recordVersion: recordVersion ?? this.recordVersion,
        packVersion: packVersion ?? this.packVersion,
        legalStatus: legalStatus ?? this.legalStatus,
      );
  StatutoryProvision copyWithCompanion(StatutoryProvisionsCompanion data) {
    return StatutoryProvision(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      provisionPath: data.provisionPath.present
          ? data.provisionPath.value
          : this.provisionPath,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      plainExplanation: data.plainExplanation.present
          ? data.plainExplanation.value
          : this.plainExplanation,
      officialUrl:
          data.officialUrl.present ? data.officialUrl.value : this.officialUrl,
      category: data.category.present ? data.category.value : this.category,
      recordVersion: data.recordVersion.present
          ? data.recordVersion.value
          : this.recordVersion,
      packVersion:
          data.packVersion.present ? data.packVersion.value : this.packVersion,
      legalStatus:
          data.legalStatus.present ? data.legalStatus.value : this.legalStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatutoryProvision(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('provisionPath: $provisionPath, ')
          ..write('originalText: $originalText, ')
          ..write('plainExplanation: $plainExplanation, ')
          ..write('officialUrl: $officialUrl, ')
          ..write('category: $category, ')
          ..write('recordVersion: $recordVersion, ')
          ..write('packVersion: $packVersion, ')
          ..write('legalStatus: $legalStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      provisionPath,
      originalText,
      plainExplanation,
      officialUrl,
      category,
      recordVersion,
      packVersion,
      legalStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatutoryProvision &&
          other.id == this.id &&
          other.title == this.title &&
          other.provisionPath == this.provisionPath &&
          other.originalText == this.originalText &&
          other.plainExplanation == this.plainExplanation &&
          other.officialUrl == this.officialUrl &&
          other.category == this.category &&
          other.recordVersion == this.recordVersion &&
          other.packVersion == this.packVersion &&
          other.legalStatus == this.legalStatus);
}

class StatutoryProvisionsCompanion extends UpdateCompanion<StatutoryProvision> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> provisionPath;
  final Value<String> originalText;
  final Value<String?> plainExplanation;
  final Value<String?> officialUrl;
  final Value<String> category;
  final Value<String> recordVersion;
  final Value<String> packVersion;
  final Value<String> legalStatus;
  final Value<int> rowid;
  const StatutoryProvisionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.provisionPath = const Value.absent(),
    this.originalText = const Value.absent(),
    this.plainExplanation = const Value.absent(),
    this.officialUrl = const Value.absent(),
    this.category = const Value.absent(),
    this.recordVersion = const Value.absent(),
    this.packVersion = const Value.absent(),
    this.legalStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatutoryProvisionsCompanion.insert({
    required String id,
    required String title,
    required String provisionPath,
    required String originalText,
    this.plainExplanation = const Value.absent(),
    this.officialUrl = const Value.absent(),
    required String category,
    this.recordVersion = const Value.absent(),
    this.packVersion = const Value.absent(),
    this.legalStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        provisionPath = Value(provisionPath),
        originalText = Value(originalText),
        category = Value(category);
  static Insertable<StatutoryProvision> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? provisionPath,
    Expression<String>? originalText,
    Expression<String>? plainExplanation,
    Expression<String>? officialUrl,
    Expression<String>? category,
    Expression<String>? recordVersion,
    Expression<String>? packVersion,
    Expression<String>? legalStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (provisionPath != null) 'provision_path': provisionPath,
      if (originalText != null) 'original_text': originalText,
      if (plainExplanation != null) 'plain_explanation': plainExplanation,
      if (officialUrl != null) 'official_url': officialUrl,
      if (category != null) 'category': category,
      if (recordVersion != null) 'record_version': recordVersion,
      if (packVersion != null) 'pack_version': packVersion,
      if (legalStatus != null) 'legal_status': legalStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatutoryProvisionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? provisionPath,
      Value<String>? originalText,
      Value<String?>? plainExplanation,
      Value<String?>? officialUrl,
      Value<String>? category,
      Value<String>? recordVersion,
      Value<String>? packVersion,
      Value<String>? legalStatus,
      Value<int>? rowid}) {
    return StatutoryProvisionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      provisionPath: provisionPath ?? this.provisionPath,
      originalText: originalText ?? this.originalText,
      plainExplanation: plainExplanation ?? this.plainExplanation,
      officialUrl: officialUrl ?? this.officialUrl,
      category: category ?? this.category,
      recordVersion: recordVersion ?? this.recordVersion,
      packVersion: packVersion ?? this.packVersion,
      legalStatus: legalStatus ?? this.legalStatus,
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
    if (provisionPath.present) {
      map['provision_path'] = Variable<String>(provisionPath.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (plainExplanation.present) {
      map['plain_explanation'] = Variable<String>(plainExplanation.value);
    }
    if (officialUrl.present) {
      map['official_url'] = Variable<String>(officialUrl.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (recordVersion.present) {
      map['record_version'] = Variable<String>(recordVersion.value);
    }
    if (packVersion.present) {
      map['pack_version'] = Variable<String>(packVersion.value);
    }
    if (legalStatus.present) {
      map['legal_status'] = Variable<String>(legalStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatutoryProvisionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('provisionPath: $provisionPath, ')
          ..write('originalText: $originalText, ')
          ..write('plainExplanation: $plainExplanation, ')
          ..write('officialUrl: $officialUrl, ')
          ..write('category: $category, ')
          ..write('recordVersion: $recordVersion, ')
          ..write('packVersion: $packVersion, ')
          ..write('legalStatus: $legalStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GovernmentOfficesTable extends GovernmentOffices
    with TableInfo<$GovernmentOfficesTable, GovernmentOffice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GovernmentOfficesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _territoryMeta =
      const VerificationMeta('territory');
  @override
  late final GeneratedColumn<String> territory = GeneratedColumn<String>(
      'territory', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _issueScopeMeta =
      const VerificationMeta('issueScope');
  @override
  late final GeneratedColumn<String> issueScope = GeneratedColumn<String>(
      'issue_scope', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('authoritative'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, address, phone, territory, issueScope, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'government_offices';
  @override
  VerificationContext validateIntegrity(Insertable<GovernmentOffice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('territory')) {
      context.handle(_territoryMeta,
          territory.isAcceptableOrUnknown(data['territory']!, _territoryMeta));
    }
    if (data.containsKey('issue_scope')) {
      context.handle(
          _issueScopeMeta,
          issueScope.isAcceptableOrUnknown(
              data['issue_scope']!, _issueScopeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GovernmentOffice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GovernmentOffice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      territory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}territory']),
      issueScope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}issue_scope']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $GovernmentOfficesTable createAlias(String alias) {
    return $GovernmentOfficesTable(attachedDatabase, alias);
  }
}

class GovernmentOffice extends DataClass
    implements Insertable<GovernmentOffice> {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? territory;
  final String? issueScope;
  final String status;
  const GovernmentOffice(
      {required this.id,
      required this.name,
      this.address,
      this.phone,
      this.territory,
      this.issueScope,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || territory != null) {
      map['territory'] = Variable<String>(territory);
    }
    if (!nullToAbsent || issueScope != null) {
      map['issue_scope'] = Variable<String>(issueScope);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  GovernmentOfficesCompanion toCompanion(bool nullToAbsent) {
    return GovernmentOfficesCompanion(
      id: Value(id),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      territory: territory == null && nullToAbsent
          ? const Value.absent()
          : Value(territory),
      issueScope: issueScope == null && nullToAbsent
          ? const Value.absent()
          : Value(issueScope),
      status: Value(status),
    );
  }

  factory GovernmentOffice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GovernmentOffice(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      territory: serializer.fromJson<String?>(json['territory']),
      issueScope: serializer.fromJson<String?>(json['issueScope']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'territory': serializer.toJson<String?>(territory),
      'issueScope': serializer.toJson<String?>(issueScope),
      'status': serializer.toJson<String>(status),
    };
  }

  GovernmentOffice copyWith(
          {String? id,
          String? name,
          Value<String?> address = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> territory = const Value.absent(),
          Value<String?> issueScope = const Value.absent(),
          String? status}) =>
      GovernmentOffice(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address.present ? address.value : this.address,
        phone: phone.present ? phone.value : this.phone,
        territory: territory.present ? territory.value : this.territory,
        issueScope: issueScope.present ? issueScope.value : this.issueScope,
        status: status ?? this.status,
      );
  GovernmentOffice copyWithCompanion(GovernmentOfficesCompanion data) {
    return GovernmentOffice(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      territory: data.territory.present ? data.territory.value : this.territory,
      issueScope:
          data.issueScope.present ? data.issueScope.value : this.issueScope,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GovernmentOffice(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('territory: $territory, ')
          ..write('issueScope: $issueScope, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, address, phone, territory, issueScope, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GovernmentOffice &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.territory == this.territory &&
          other.issueScope == this.issueScope &&
          other.status == this.status);
}

class GovernmentOfficesCompanion extends UpdateCompanion<GovernmentOffice> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<String?> territory;
  final Value<String?> issueScope;
  final Value<String> status;
  final Value<int> rowid;
  const GovernmentOfficesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.territory = const Value.absent(),
    this.issueScope = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GovernmentOfficesCompanion.insert({
    required String id,
    required String name,
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.territory = const Value.absent(),
    this.issueScope = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<GovernmentOffice> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? territory,
    Expression<String>? issueScope,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (territory != null) 'territory': territory,
      if (issueScope != null) 'issue_scope': issueScope,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GovernmentOfficesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? address,
      Value<String?>? phone,
      Value<String?>? territory,
      Value<String?>? issueScope,
      Value<String>? status,
      Value<int>? rowid}) {
    return GovernmentOfficesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      territory: territory ?? this.territory,
      issueScope: issueScope ?? this.issueScope,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (territory.present) {
      map['territory'] = Variable<String>(territory.value);
    }
    if (issueScope.present) {
      map['issue_scope'] = Variable<String>(issueScope.value);
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
    return (StringBuffer('GovernmentOfficesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('territory: $territory, ')
          ..write('issueScope: $issueScope, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CasesTable cases = $CasesTable(this);
  late final $ChatTurnsTable chatTurns = $ChatTurnsTable(this);
  late final $LocalDraftsTable localDrafts = $LocalDraftsTable(this);
  late final $StatutoryProvisionsTable statutoryProvisions =
      $StatutoryProvisionsTable(this);
  late final $GovernmentOfficesTable governmentOffices =
      $GovernmentOfficesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cases, chatTurns, localDrafts, statutoryProvisions, governmentOffices];
}

typedef $$CasesTableCreateCompanionBuilder = CasesCompanion Function({
  required String id,
  required String title,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CasesTableUpdateCompanionBuilder = CasesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CasesTableFilterComposer extends Composer<_$AppDatabase, $CasesTable> {
  $$CasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CasesTableOrderingComposer
    extends Composer<_$AppDatabase, $CasesTable> {
  $$CasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CasesTable> {
  $$CasesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CasesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CasesTable,
    Case,
    $$CasesTableFilterComposer,
    $$CasesTableOrderingComposer,
    $$CasesTableAnnotationComposer,
    $$CasesTableCreateCompanionBuilder,
    $$CasesTableUpdateCompanionBuilder,
    (Case, BaseReferences<_$AppDatabase, $CasesTable, Case>),
    Case,
    PrefetchHooks Function()> {
  $$CasesTableTableManager(_$AppDatabase db, $CasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CasesCompanion(
            id: id,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CasesCompanion.insert(
            id: id,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CasesTable, Case>(table),
                    BaseReferences<_$AppDatabase, $CasesTable, Case>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CasesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CasesTable,
    Case,
    $$CasesTableFilterComposer,
    $$CasesTableOrderingComposer,
    $$CasesTableAnnotationComposer,
    $$CasesTableCreateCompanionBuilder,
    $$CasesTableUpdateCompanionBuilder,
    (Case, BaseReferences<_$AppDatabase, $CasesTable, Case>),
    Case,
    PrefetchHooks Function()>;
typedef $$ChatTurnsTableCreateCompanionBuilder = ChatTurnsCompanion Function({
  required String id,
  required String caseId,
  required String role,
  required String textContent,
  Value<String?> responseJson,
  Value<bool> isSuperseded,
  required DateTime timestamp,
  Value<int> rowid,
});
typedef $$ChatTurnsTableUpdateCompanionBuilder = ChatTurnsCompanion Function({
  Value<String> id,
  Value<String> caseId,
  Value<String> role,
  Value<String> textContent,
  Value<String?> responseJson,
  Value<bool> isSuperseded,
  Value<DateTime> timestamp,
  Value<int> rowid,
});

class $$ChatTurnsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatTurnsTable> {
  $$ChatTurnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caseId => $composableBuilder(
      column: $table.caseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responseJson => $composableBuilder(
      column: $table.responseJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSuperseded => $composableBuilder(
      column: $table.isSuperseded, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$ChatTurnsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatTurnsTable> {
  $$ChatTurnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caseId => $composableBuilder(
      column: $table.caseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responseJson => $composableBuilder(
      column: $table.responseJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSuperseded => $composableBuilder(
      column: $table.isSuperseded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$ChatTurnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatTurnsTable> {
  $$ChatTurnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => column);

  GeneratedColumn<String> get responseJson => $composableBuilder(
      column: $table.responseJson, builder: (column) => column);

  GeneratedColumn<bool> get isSuperseded => $composableBuilder(
      column: $table.isSuperseded, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$ChatTurnsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatTurnsTable,
    ChatTurn,
    $$ChatTurnsTableFilterComposer,
    $$ChatTurnsTableOrderingComposer,
    $$ChatTurnsTableAnnotationComposer,
    $$ChatTurnsTableCreateCompanionBuilder,
    $$ChatTurnsTableUpdateCompanionBuilder,
    (ChatTurn, BaseReferences<_$AppDatabase, $ChatTurnsTable, ChatTurn>),
    ChatTurn,
    PrefetchHooks Function()> {
  $$ChatTurnsTableTableManager(_$AppDatabase db, $ChatTurnsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatTurnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatTurnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatTurnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> caseId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> textContent = const Value.absent(),
            Value<String?> responseJson = const Value.absent(),
            Value<bool> isSuperseded = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatTurnsCompanion(
            id: id,
            caseId: caseId,
            role: role,
            textContent: textContent,
            responseJson: responseJson,
            isSuperseded: isSuperseded,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String caseId,
            required String role,
            required String textContent,
            Value<String?> responseJson = const Value.absent(),
            Value<bool> isSuperseded = const Value.absent(),
            required DateTime timestamp,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatTurnsCompanion.insert(
            id: id,
            caseId: caseId,
            role: role,
            textContent: textContent,
            responseJson: responseJson,
            isSuperseded: isSuperseded,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ChatTurnsTable, ChatTurn>(table),
                    BaseReferences<_$AppDatabase, $ChatTurnsTable, ChatTurn>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatTurnsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatTurnsTable,
    ChatTurn,
    $$ChatTurnsTableFilterComposer,
    $$ChatTurnsTableOrderingComposer,
    $$ChatTurnsTableAnnotationComposer,
    $$ChatTurnsTableCreateCompanionBuilder,
    $$ChatTurnsTableUpdateCompanionBuilder,
    (ChatTurn, BaseReferences<_$AppDatabase, $ChatTurnsTable, ChatTurn>),
    ChatTurn,
    PrefetchHooks Function()>;
typedef $$LocalDraftsTableCreateCompanionBuilder = LocalDraftsCompanion
    Function({
  required String id,
  Value<String?> caseId,
  required String type,
  required String title,
  required String recipient,
  required String subject,
  required String body,
  required String factsJson,
  Value<String?> applicantName,
  Value<String?> applicantPhone,
  Value<String?> applicantAddress,
  Value<String?> officeName,
  required String status,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$LocalDraftsTableUpdateCompanionBuilder = LocalDraftsCompanion
    Function({
  Value<String> id,
  Value<String?> caseId,
  Value<String> type,
  Value<String> title,
  Value<String> recipient,
  Value<String> subject,
  Value<String> body,
  Value<String> factsJson,
  Value<String?> applicantName,
  Value<String?> applicantPhone,
  Value<String?> applicantAddress,
  Value<String?> officeName,
  Value<String> status,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LocalDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDraftsTable> {
  $$LocalDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caseId => $composableBuilder(
      column: $table.caseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recipient => $composableBuilder(
      column: $table.recipient, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get factsJson => $composableBuilder(
      column: $table.factsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get applicantName => $composableBuilder(
      column: $table.applicantName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get applicantPhone => $composableBuilder(
      column: $table.applicantPhone,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get applicantAddress => $composableBuilder(
      column: $table.applicantAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get officeName => $composableBuilder(
      column: $table.officeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDraftsTable> {
  $$LocalDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caseId => $composableBuilder(
      column: $table.caseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipient => $composableBuilder(
      column: $table.recipient, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get factsJson => $composableBuilder(
      column: $table.factsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get applicantName => $composableBuilder(
      column: $table.applicantName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get applicantPhone => $composableBuilder(
      column: $table.applicantPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get applicantAddress => $composableBuilder(
      column: $table.applicantAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get officeName => $composableBuilder(
      column: $table.officeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDraftsTable> {
  $$LocalDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get recipient =>
      $composableBuilder(column: $table.recipient, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get factsJson =>
      $composableBuilder(column: $table.factsJson, builder: (column) => column);

  GeneratedColumn<String> get applicantName => $composableBuilder(
      column: $table.applicantName, builder: (column) => column);

  GeneratedColumn<String> get applicantPhone => $composableBuilder(
      column: $table.applicantPhone, builder: (column) => column);

  GeneratedColumn<String> get applicantAddress => $composableBuilder(
      column: $table.applicantAddress, builder: (column) => column);

  GeneratedColumn<String> get officeName => $composableBuilder(
      column: $table.officeName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalDraftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalDraftsTable,
    LocalDraft,
    $$LocalDraftsTableFilterComposer,
    $$LocalDraftsTableOrderingComposer,
    $$LocalDraftsTableAnnotationComposer,
    $$LocalDraftsTableCreateCompanionBuilder,
    $$LocalDraftsTableUpdateCompanionBuilder,
    (LocalDraft, BaseReferences<_$AppDatabase, $LocalDraftsTable, LocalDraft>),
    LocalDraft,
    PrefetchHooks Function()> {
  $$LocalDraftsTableTableManager(_$AppDatabase db, $LocalDraftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> caseId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> recipient = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> factsJson = const Value.absent(),
            Value<String?> applicantName = const Value.absent(),
            Value<String?> applicantPhone = const Value.absent(),
            Value<String?> applicantAddress = const Value.absent(),
            Value<String?> officeName = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalDraftsCompanion(
            id: id,
            caseId: caseId,
            type: type,
            title: title,
            recipient: recipient,
            subject: subject,
            body: body,
            factsJson: factsJson,
            applicantName: applicantName,
            applicantPhone: applicantPhone,
            applicantAddress: applicantAddress,
            officeName: officeName,
            status: status,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> caseId = const Value.absent(),
            required String type,
            required String title,
            required String recipient,
            required String subject,
            required String body,
            required String factsJson,
            Value<String?> applicantName = const Value.absent(),
            Value<String?> applicantPhone = const Value.absent(),
            Value<String?> applicantAddress = const Value.absent(),
            Value<String?> officeName = const Value.absent(),
            required String status,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalDraftsCompanion.insert(
            id: id,
            caseId: caseId,
            type: type,
            title: title,
            recipient: recipient,
            subject: subject,
            body: body,
            factsJson: factsJson,
            applicantName: applicantName,
            applicantPhone: applicantPhone,
            applicantAddress: applicantAddress,
            officeName: officeName,
            status: status,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LocalDraftsTable, LocalDraft>(table),
                    BaseReferences<_$AppDatabase, $LocalDraftsTable,
                        LocalDraft>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalDraftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalDraftsTable,
    LocalDraft,
    $$LocalDraftsTableFilterComposer,
    $$LocalDraftsTableOrderingComposer,
    $$LocalDraftsTableAnnotationComposer,
    $$LocalDraftsTableCreateCompanionBuilder,
    $$LocalDraftsTableUpdateCompanionBuilder,
    (LocalDraft, BaseReferences<_$AppDatabase, $LocalDraftsTable, LocalDraft>),
    LocalDraft,
    PrefetchHooks Function()>;
typedef $$StatutoryProvisionsTableCreateCompanionBuilder
    = StatutoryProvisionsCompanion Function({
  required String id,
  required String title,
  required String provisionPath,
  required String originalText,
  Value<String?> plainExplanation,
  Value<String?> officialUrl,
  required String category,
  Value<String> recordVersion,
  Value<String> packVersion,
  Value<String> legalStatus,
  Value<int> rowid,
});
typedef $$StatutoryProvisionsTableUpdateCompanionBuilder
    = StatutoryProvisionsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> provisionPath,
  Value<String> originalText,
  Value<String?> plainExplanation,
  Value<String?> officialUrl,
  Value<String> category,
  Value<String> recordVersion,
  Value<String> packVersion,
  Value<String> legalStatus,
  Value<int> rowid,
});

class $$StatutoryProvisionsTableFilterComposer
    extends Composer<_$AppDatabase, $StatutoryProvisionsTable> {
  $$StatutoryProvisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provisionPath => $composableBuilder(
      column: $table.provisionPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalText => $composableBuilder(
      column: $table.originalText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plainExplanation => $composableBuilder(
      column: $table.plainExplanation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get officialUrl => $composableBuilder(
      column: $table.officialUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordVersion => $composableBuilder(
      column: $table.recordVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packVersion => $composableBuilder(
      column: $table.packVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get legalStatus => $composableBuilder(
      column: $table.legalStatus, builder: (column) => ColumnFilters(column));
}

class $$StatutoryProvisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StatutoryProvisionsTable> {
  $$StatutoryProvisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provisionPath => $composableBuilder(
      column: $table.provisionPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalText => $composableBuilder(
      column: $table.originalText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plainExplanation => $composableBuilder(
      column: $table.plainExplanation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get officialUrl => $composableBuilder(
      column: $table.officialUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordVersion => $composableBuilder(
      column: $table.recordVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packVersion => $composableBuilder(
      column: $table.packVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get legalStatus => $composableBuilder(
      column: $table.legalStatus, builder: (column) => ColumnOrderings(column));
}

class $$StatutoryProvisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatutoryProvisionsTable> {
  $$StatutoryProvisionsTableAnnotationComposer({
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

  GeneratedColumn<String> get provisionPath => $composableBuilder(
      column: $table.provisionPath, builder: (column) => column);

  GeneratedColumn<String> get originalText => $composableBuilder(
      column: $table.originalText, builder: (column) => column);

  GeneratedColumn<String> get plainExplanation => $composableBuilder(
      column: $table.plainExplanation, builder: (column) => column);

  GeneratedColumn<String> get officialUrl => $composableBuilder(
      column: $table.officialUrl, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get recordVersion => $composableBuilder(
      column: $table.recordVersion, builder: (column) => column);

  GeneratedColumn<String> get packVersion => $composableBuilder(
      column: $table.packVersion, builder: (column) => column);

  GeneratedColumn<String> get legalStatus => $composableBuilder(
      column: $table.legalStatus, builder: (column) => column);
}

class $$StatutoryProvisionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StatutoryProvisionsTable,
    StatutoryProvision,
    $$StatutoryProvisionsTableFilterComposer,
    $$StatutoryProvisionsTableOrderingComposer,
    $$StatutoryProvisionsTableAnnotationComposer,
    $$StatutoryProvisionsTableCreateCompanionBuilder,
    $$StatutoryProvisionsTableUpdateCompanionBuilder,
    (
      StatutoryProvision,
      BaseReferences<_$AppDatabase, $StatutoryProvisionsTable,
          StatutoryProvision>
    ),
    StatutoryProvision,
    PrefetchHooks Function()> {
  $$StatutoryProvisionsTableTableManager(
      _$AppDatabase db, $StatutoryProvisionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatutoryProvisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatutoryProvisionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatutoryProvisionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> provisionPath = const Value.absent(),
            Value<String> originalText = const Value.absent(),
            Value<String?> plainExplanation = const Value.absent(),
            Value<String?> officialUrl = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> recordVersion = const Value.absent(),
            Value<String> packVersion = const Value.absent(),
            Value<String> legalStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StatutoryProvisionsCompanion(
            id: id,
            title: title,
            provisionPath: provisionPath,
            originalText: originalText,
            plainExplanation: plainExplanation,
            officialUrl: officialUrl,
            category: category,
            recordVersion: recordVersion,
            packVersion: packVersion,
            legalStatus: legalStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String provisionPath,
            required String originalText,
            Value<String?> plainExplanation = const Value.absent(),
            Value<String?> officialUrl = const Value.absent(),
            required String category,
            Value<String> recordVersion = const Value.absent(),
            Value<String> packVersion = const Value.absent(),
            Value<String> legalStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StatutoryProvisionsCompanion.insert(
            id: id,
            title: title,
            provisionPath: provisionPath,
            originalText: originalText,
            plainExplanation: plainExplanation,
            officialUrl: officialUrl,
            category: category,
            recordVersion: recordVersion,
            packVersion: packVersion,
            legalStatus: legalStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$StatutoryProvisionsTable, StatutoryProvision>(
                        table),
                    BaseReferences<_$AppDatabase, $StatutoryProvisionsTable,
                        StatutoryProvision>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StatutoryProvisionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StatutoryProvisionsTable,
    StatutoryProvision,
    $$StatutoryProvisionsTableFilterComposer,
    $$StatutoryProvisionsTableOrderingComposer,
    $$StatutoryProvisionsTableAnnotationComposer,
    $$StatutoryProvisionsTableCreateCompanionBuilder,
    $$StatutoryProvisionsTableUpdateCompanionBuilder,
    (
      StatutoryProvision,
      BaseReferences<_$AppDatabase, $StatutoryProvisionsTable,
          StatutoryProvision>
    ),
    StatutoryProvision,
    PrefetchHooks Function()>;
typedef $$GovernmentOfficesTableCreateCompanionBuilder
    = GovernmentOfficesCompanion Function({
  required String id,
  required String name,
  Value<String?> address,
  Value<String?> phone,
  Value<String?> territory,
  Value<String?> issueScope,
  Value<String> status,
  Value<int> rowid,
});
typedef $$GovernmentOfficesTableUpdateCompanionBuilder
    = GovernmentOfficesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> address,
  Value<String?> phone,
  Value<String?> territory,
  Value<String?> issueScope,
  Value<String> status,
  Value<int> rowid,
});

class $$GovernmentOfficesTableFilterComposer
    extends Composer<_$AppDatabase, $GovernmentOfficesTable> {
  $$GovernmentOfficesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get territory => $composableBuilder(
      column: $table.territory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get issueScope => $composableBuilder(
      column: $table.issueScope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$GovernmentOfficesTableOrderingComposer
    extends Composer<_$AppDatabase, $GovernmentOfficesTable> {
  $$GovernmentOfficesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get territory => $composableBuilder(
      column: $table.territory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get issueScope => $composableBuilder(
      column: $table.issueScope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$GovernmentOfficesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GovernmentOfficesTable> {
  $$GovernmentOfficesTableAnnotationComposer({
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

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get territory =>
      $composableBuilder(column: $table.territory, builder: (column) => column);

  GeneratedColumn<String> get issueScope => $composableBuilder(
      column: $table.issueScope, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$GovernmentOfficesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GovernmentOfficesTable,
    GovernmentOffice,
    $$GovernmentOfficesTableFilterComposer,
    $$GovernmentOfficesTableOrderingComposer,
    $$GovernmentOfficesTableAnnotationComposer,
    $$GovernmentOfficesTableCreateCompanionBuilder,
    $$GovernmentOfficesTableUpdateCompanionBuilder,
    (
      GovernmentOffice,
      BaseReferences<_$AppDatabase, $GovernmentOfficesTable, GovernmentOffice>
    ),
    GovernmentOffice,
    PrefetchHooks Function()> {
  $$GovernmentOfficesTableTableManager(
      _$AppDatabase db, $GovernmentOfficesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GovernmentOfficesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GovernmentOfficesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GovernmentOfficesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> territory = const Value.absent(),
            Value<String?> issueScope = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GovernmentOfficesCompanion(
            id: id,
            name: name,
            address: address,
            phone: phone,
            territory: territory,
            issueScope: issueScope,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> territory = const Value.absent(),
            Value<String?> issueScope = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GovernmentOfficesCompanion.insert(
            id: id,
            name: name,
            address: address,
            phone: phone,
            territory: territory,
            issueScope: issueScope,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GovernmentOfficesTable, GovernmentOffice>(
                        table),
                    BaseReferences<_$AppDatabase, $GovernmentOfficesTable,
                        GovernmentOffice>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GovernmentOfficesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GovernmentOfficesTable,
    GovernmentOffice,
    $$GovernmentOfficesTableFilterComposer,
    $$GovernmentOfficesTableOrderingComposer,
    $$GovernmentOfficesTableAnnotationComposer,
    $$GovernmentOfficesTableCreateCompanionBuilder,
    $$GovernmentOfficesTableUpdateCompanionBuilder,
    (
      GovernmentOffice,
      BaseReferences<_$AppDatabase, $GovernmentOfficesTable, GovernmentOffice>
    ),
    GovernmentOffice,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CasesTableTableManager get cases =>
      $$CasesTableTableManager(_db, _db.cases);
  $$ChatTurnsTableTableManager get chatTurns =>
      $$ChatTurnsTableTableManager(_db, _db.chatTurns);
  $$LocalDraftsTableTableManager get localDrafts =>
      $$LocalDraftsTableTableManager(_db, _db.localDrafts);
  $$StatutoryProvisionsTableTableManager get statutoryProvisions =>
      $$StatutoryProvisionsTableTableManager(_db, _db.statutoryProvisions);
  $$GovernmentOfficesTableTableManager get governmentOffices =>
      $$GovernmentOfficesTableTableManager(_db, _db.governmentOffices);
}
