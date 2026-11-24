import '../models/pack_state.dart';

abstract class PackRepository {
  /// Get current install and update state of legal pack
  Stream<PackState> watchPackState();

  /// Check for new version on server
  Future<PackState> checkForUpdates();

  /// Start downloading and staging pack
  Future<void> installPack();

  /// Cancel an ongoing download
  Future<void> cancelInstall();

  /// Remove installed pack from phone storage
  Future<void> removePack();
}
