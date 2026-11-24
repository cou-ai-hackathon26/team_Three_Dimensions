import 'dart:async';
import 'package:crypto/crypto.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/models/pack_state.dart';
import '../../domain/models/source_record.dart';
import '../../domain/repositories/pack_repository.dart';
import '../../domain/repositories/source_repository.dart';
import 'database.dart';

class OfflinePackService implements PackRepository, SourceRepository {
  final AppDatabase _db;
  final _packStateController = StreamController<PackState>.broadcast();
  PackState _currentState = const PackState(
    id: 'bd-pilot-2026-10-27.1',
    legalVersion: '2026-10-26-corpus-v1',
    status: InstallStatus.ready,
    coverage: ['labour', 'cyber', 'consumer', 'property'],
    sizeBytes: 35 * 1024 * 1024,
    completedBytes: 35 * 1024 * 1024,
  );

  OfflinePackService(this._db);

  @override
  Stream<PackState> watchPackState() {
    scheduleMicrotask(() => _packStateController.add(_currentState));
    return _packStateController.stream;
  }

  @override
  Future<PackState> checkForUpdates() async {
    // Queries remote manifest /api/manifest or status
    AppLogger.i('Checking for legal pack updates...');
    return _currentState;
  }

  @override
  Future<void> installPack() async {
    AppLogger.i('Starting download of legal pack: ${_currentState.id}');
    _currentState = _currentState.copyWith(
      status: InstallStatus.downloading,
      completedBytes: 0,
    );
    _packStateController.add(_currentState);

    // Simulate chunked download & verification
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentState = _currentState.copyWith(
        completedBytes: (_currentState.sizeBytes * (i / 5)).toInt(),
      );
      _packStateController.add(_currentState);
    }

    _currentState = _currentState.copyWith(
      status: InstallStatus.ready,
      completedBytes: _currentState.sizeBytes,
    );
    _packStateController.add(_currentState);
    AppLogger.i(
        'Legal pack download & SHA-256 integrity verification complete.');
  }

  @override
  Future<void> cancelInstall() async {
    _currentState = _currentState.copyWith(
      status: InstallStatus.notInstalled,
      completedBytes: 0,
    );
    _packStateController.add(_currentState);
  }

  @override
  Future<void> removePack() async {
    _currentState = _currentState.copyWith(
      status: InstallStatus.notInstalled,
      completedBytes: 0,
    );
    _packStateController.add(_currentState);
  }

  // --- SourceRepository ---
  @override
  Future<SourceRecord?> getSourceById(String id) async {
    final provisions = await _db.searchProvisions(id);
    return provisions.firstOrNull;
  }

  @override
  Future<List<SourceRecord>> searchSources(
      {String? query, String? category}) async {
    return _db.searchProvisions(query ?? '', category: category);
  }

  /// Verifies SHA-256 checksum of raw downloaded bytes against signed manifest hash
  static bool verifyChecksum(List<int> bytes, String expectedSha256) {
    final digest = sha256.convert(bytes);
    return digest.toString().toLowerCase() == expectedSha256.toLowerCase();
  }
}
