import '../models/draft_document.dart';
import '../models/fact.dart';

abstract class DraftRepository {
  /// Prepare or preview a draft document (GD, DIFE, DNCRP)
  Future<DraftDocument> prepareDraft({
    required DocumentType type,
    required List<Fact> facts,
    String? id,
  });

  /// Save draft locally
  Future<void> saveDraft(DraftDocument draft);

  /// Get list of saved drafts
  Future<List<DraftDocument>> getSavedDrafts();

  /// Delete a saved draft
  Future<void> deleteDraft(String id);
}
