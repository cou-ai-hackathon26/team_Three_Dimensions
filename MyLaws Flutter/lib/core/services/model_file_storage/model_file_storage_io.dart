import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'model_file_storage.dart';

ModelFileStorage getModelFileStorage() => ModelFileStorageIo();

class IoModelFileSink implements ModelFileSink {
  final IOSink _sink;
  IoModelFileSink(this._sink);

  @override
  void add(List<int> chunk) => _sink.add(chunk);

  @override
  Future<void> flush() => _sink.flush();

  @override
  Future<void> close() => _sink.close();
}

class ModelFileStorageIo implements ModelFileStorage {
  @override
  Future<String?> getModelFilePath(String modelId) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory(p.join(docsDir.path, 'mylaws_models'));
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return p.join(modelsDir.path, '$modelId.gguf');
  }

  @override
  Future<int> getLocalFileSizeBytes(String modelId) async {
    try {
      final filePath = await getModelFilePath(modelId);
      if (filePath == null) return 0;
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<bool> doesModelFileExist(String modelId, int expectedSizeBytes) async {
    try {
      final filePath = await getModelFilePath(modelId);
      if (filePath == null) return false;
      final file = File(filePath);
      if (!await file.exists()) return false;
      final actualSize = await file.length();
      // Allow minor margin or exact match
      return actualSize >= expectedSizeBytes;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ModelFileSink> openWriteStream(String modelId,
      {required bool append}) async {
    final filePath = await getModelFilePath(modelId);
    if (filePath == null) {
      throw UnsupportedError('File storage not available on this platform');
    }
    final file = File(filePath);
    final sink = file.openWrite(mode: append ? FileMode.append : FileMode.write);
    return IoModelFileSink(sink);
  }

  @override
  Future<void> deleteModelFile(String modelId) async {
    try {
      final filePath = await getModelFilePath(modelId);
      if (filePath == null) return;
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
