import '../models/office_record.dart';

abstract class OfficeRepository {
  /// Lookup a verified office by ID
  Future<OfficeRecord?> getOfficeById(String id);

  /// List all verified offices
  Future<List<OfficeRecord>> getOffices();
}
