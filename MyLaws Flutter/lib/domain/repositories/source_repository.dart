import '../models/source_record.dart';

abstract class SourceRepository {
  /// Lookup a single statutory provision by its unique ID
  Future<SourceRecord?> getSourceById(String id);

  /// Search provisions by keyword or category
  Future<List<SourceRecord>> searchSources({String? query, String? category});
}
