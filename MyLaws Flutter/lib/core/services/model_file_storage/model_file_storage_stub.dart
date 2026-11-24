import 'model_file_storage.dart';

ModelFileStorage getModelFileStorage() => ModelFileStorageStub();

class StubModelFileSink implements ModelFileSink {
  final void Function(List<int> chunk)? onAdd;
  StubModelFileSink([this.onAdd]);

  @override
  void add(List<int> chunk) {
    onAdd?.call(chunk);
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async {}
}

class ModelFileStorageStub implements ModelFileStorage {
  int _virtualSizeBytes = 0;
  bool _mockInstalled = false;

  void setMockInstalled(bool installed, {int? sizeBytes}) {
    _mockInstalled = installed;
    _virtualSizeBytes = sizeBytes ?? (installed ? 491400032 : 0);
  }

  @override
  Future<String?> getModelFilePath(String modelId) async =>
      'virtual://$modelId.gguf';

  @override
  Future<int> getLocalFileSizeBytes(String modelId) async => _virtualSizeBytes;

  @override
  Future<bool> doesModelFileExist(String modelId, int expectedSizeBytes) async =>
      _mockInstalled || _virtualSizeBytes >= expectedSizeBytes;

  @override
  Future<ModelFileSink> openWriteStream(String modelId,
      {required bool append}) async {
    return StubModelFileSink((chunk) {
      _virtualSizeBytes += chunk.length;
    });
  }

  @override
  Future<void> deleteModelFile(String modelId) async {
    _virtualSizeBytes = 0;
    _mockInstalled = false;
  }
}
