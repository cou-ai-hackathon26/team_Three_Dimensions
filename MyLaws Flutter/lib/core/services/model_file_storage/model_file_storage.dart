import 'model_file_storage_stub.dart'
    if (dart.library.io) 'model_file_storage_io.dart';

/// Interface for streaming and persisting AI model files to local storage.
abstract class ModelFileSink {
  void add(List<int> chunk);
  Future<void> flush();
  Future<void> close();
}

abstract class ModelFileStorage {
  static ModelFileStorage instance = getModelFileStorage();

  Future<String?> getModelFilePath(String modelId);
  Future<int> getLocalFileSizeBytes(String modelId);
  Future<bool> doesModelFileExist(String modelId, int expectedSizeBytes);
  Future<ModelFileSink> openWriteStream(String modelId, {required bool append});
  Future<void> deleteModelFile(String modelId);
}
