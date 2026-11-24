import 'dart:convert';
import 'package:drift/drift.dart';

import '../../domain/models/draft_document.dart';
import '../../domain/models/fact.dart';
import '../../domain/models/office_record.dart';
import '../../domain/models/source_record.dart';

part 'database.g.dart';

class Cases extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatTurns extends Table {
  TextColumn get id => text()();
  TextColumn get caseId => text()();
  TextColumn get role => text()(); // 'user' or 'assistant'
  TextColumn get textContent => text()();
  TextColumn get responseJson => text().nullable()();
  BoolColumn get isSuperseded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get caseId => text().nullable()();
  TextColumn get type => text()(); // 'gd', 'dife', 'dncrp'
  TextColumn get title => text()();
  TextColumn get recipient => text()();
  TextColumn get subject => text()();
  TextColumn get body => text()();
  TextColumn get factsJson => text()();
  TextColumn get applicantName => text().nullable()();
  TextColumn get applicantPhone => text().nullable()();
  TextColumn get applicantAddress => text().nullable()();
  TextColumn get officeName => text().nullable()();
  TextColumn get status => text()(); // 'inProgress', 'reviewed'
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class StatutoryProvisions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get provisionPath => text()();
  TextColumn get originalText => text()();
  TextColumn get plainExplanation => text().nullable()();
  TextColumn get officialUrl => text().nullable()();
  TextColumn get category => text()();
  TextColumn get recordVersion => text().withDefault(const Constant('1.0'))();
  TextColumn get packVersion =>
      text().withDefault(const Constant('bd-pilot-2026-10-27.1'))();
  TextColumn get legalStatus =>
      text().withDefault(const Constant('in_force'))();

  @override
  Set<Column> get primaryKey => {id};
}

class GovernmentOffices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get territory => text().nullable()();
  TextColumn get issueScope => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('authoritative'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Cases,
  ChatTurns,
  LocalDrafts,
  StatutoryProvisions,
  GovernmentOffices,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // Provision queries
  Future<List<SourceRecord>> searchProvisions(String query,
      {String? category}) async {
    final q = select(statutoryProvisions);
    if (category != null && category.isNotEmpty && category != 'all') {
      q.where((t) => t.category.equals(category));
    }
    if (query.isNotEmpty) {
      q.where((t) =>
          t.title.like('%$query%') |
          t.provisionPath.like('%$query%') |
          t.originalText.like('%$query%') |
          t.plainExplanation.like('%$query%'));
    }
    final rows = await q.get();
    return rows
        .map((r) => SourceRecord(
              id: r.id,
              title: r.title,
              provisionPath: r.provisionPath,
              originalText: r.originalText,
              plainExplanation: r.plainExplanation,
              officialUrl: r.officialUrl,
              recordVersion: r.recordVersion,
              packVersion: r.packVersion,
              legalStatus: r.legalStatus,
              categories: [r.category],
            ))
        .toList();
  }

  // Office queries
  Future<List<OfficeRecord>> searchOffices(
      {String? territory, String? query}) async {
    final q = select(governmentOffices);
    if (territory != null) q.where((t) => t.territory.equals(territory));
    if (query != null && query.isNotEmpty) {
      q.where((t) => t.name.like('%$query%') | t.issueScope.like('%$query%'));
    }
    final rows = await q.get();
    return rows
        .map((r) => OfficeRecord(
              id: r.id,
              name: r.name,
              address: r.address,
              phone: r.phone,
              territory: r.territory,
              issueScope: r.issueScope,
              status: r.status,
            ))
        .toList();
  }

  // Draft operations
  Future<List<DraftDocument>> getAllDrafts() async {
    final rows = await (select(localDrafts)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();

    return rows.map<DraftDocument>((r) {
      List<Fact> facts = [];
      try {
        final decoded = jsonDecode(r.factsJson) as List<dynamic>;
        facts = decoded
            .map((f) => Fact.fromJson(f as Map<String, dynamic>))
            .toList();
      } catch (_) {}

      final docType = DocumentType.values.firstWhere(
        (e) => e.name == r.type,
        orElse: () => DocumentType.gd,
      );

      final status = DraftStatus.values.firstWhere(
        (e) => e.name == r.status,
        orElse: () => DraftStatus.inProgress,
      );

      return DraftDocument(
        id: r.id,
        type: docType,
        title: r.title,
        recipient: r.recipient,
        subject: r.subject,
        body: r.body,
        facts: facts,
        applicantName: r.applicantName,
        applicantPhone: r.applicantPhone,
        applicantAddress: r.applicantAddress,
        officeName: r.officeName,
        status: status,
      );
    }).toList();
  }

  Future<void> upsertDraft(DraftDocument draft) async {
    await into(localDrafts).insertOnConflictUpdate(
      LocalDraftsCompanion.insert(
        id: draft.id,
        type: draft.type.name,
        title: draft.title,
        recipient: draft.recipient,
        subject: draft.subject,
        body: draft.body,
        factsJson: jsonEncode(draft.facts.map((f) => f.toJson()).toList()),
        applicantName: Value(draft.applicantName),
        applicantPhone: Value(draft.applicantPhone),
        applicantAddress: Value(draft.applicantAddress),
        officeName: Value(draft.officeName),
        status: draft.status.name,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> removeDraft(String id) async {
    await (delete(localDrafts)..where((t) => t.id.equals(id))).go();
  }
}
