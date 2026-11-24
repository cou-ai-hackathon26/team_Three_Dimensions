import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/model_file_storage/model_file_storage.dart';
import '../../core/services/offline_legal_inference_engine.dart';
import '../../domain/models/pack_state.dart';

class LocalAiModelState {
  final String modelId;
  final String modelName;
  final String versionTag;
  final int totalBytes;
  final int downloadedBytes;
  final int diskSizeBytes;
  final double progress;
  final InstallStatus status;
  final String downloadUrl;
  final String expectedSha256;
  final double speedBytesPerSec;
  final String? errorMessage;
  final bool isAutoConfigured;
  final String ramRequirement;
  final bool isRecommended;
  final String? localPath;

  const LocalAiModelState({
    this.modelId = AppConfig.localModelLightId,
    this.modelName = AppConfig.localModelLightName,
    this.versionTag = 'v2.5-gguf-q4',
    this.totalBytes = AppConfig.localModelLightSizeBytes,
    this.downloadedBytes = 0,
    this.diskSizeBytes = 0,
    this.progress = 0.0,
    this.status = InstallStatus.notInstalled,
    this.downloadUrl = AppConfig.localModelLightR2Url,
    this.expectedSha256 = AppConfig.localModelLightSha256,
    this.speedBytesPerSec = 0.0,
    this.errorMessage,
    this.isAutoConfigured = false,
    this.ramRequirement = AppConfig.localModelLightRamRequirement,
    this.isRecommended = true,
    this.localPath,
  });

  LocalAiModelState copyWith({
    String? modelId,
    String? modelName,
    String? versionTag,
    int? totalBytes,
    int? downloadedBytes,
    int? diskSizeBytes,
    double? progress,
    InstallStatus? status,
    String? downloadUrl,
    String? expectedSha256,
    double? speedBytesPerSec,
    String? errorMessage,
    bool? isAutoConfigured,
    String? ramRequirement,
    bool? isRecommended,
    String? localPath,
  }) {
    return LocalAiModelState(
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      versionTag: versionTag ?? this.versionTag,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      diskSizeBytes: diskSizeBytes ?? this.diskSizeBytes,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      expectedSha256: expectedSha256 ?? this.expectedSha256,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
      errorMessage: errorMessage,
      isAutoConfigured: isAutoConfigured ?? this.isAutoConfigured,
      ramRequirement: ramRequirement ?? this.ramRequirement,
      isRecommended: isRecommended ?? this.isRecommended,
      localPath: localPath ?? this.localPath,
    );
  }

  /// Estimated seconds remaining based on download speed
  int get remainingSeconds {
    if (speedBytesPerSec <= 0) return 60;
    final remainingBytes = totalBytes - downloadedBytes;
    if (remainingBytes <= 0) return 0;
    return (remainingBytes / speedBytesPerSec).ceil();
  }

  /// Human-readable progress text, e.g. "২০২ MB / ৪৬৮ MB (৫১%)"
  String getProgressSummary({required bool isBn}) {
    final downloadedMb = (downloadedBytes / (1024 * 1024)).toStringAsFixed(0);
    final totalMb = (totalBytes / (1024 * 1024)).toStringAsFixed(0);
    final pct = (progress * 100).toInt().clamp(0, 100);

    if (isBn) {
      final bnDownloaded = _toBanglaDigits(downloadedMb);
      final bnTotal = _toBanglaDigits(totalMb);
      final bnPct = _toBanglaDigits(pct.toString());
      return '$bnDownloaded MB / $bnTotal MB ($bnPct%)';
    }
    return '$downloadedMb MB / $totalMb MB ($pct%)';
  }

  /// Human-readable remaining time & speed text
  String getRemainingText({required bool isBn}) {
    if (status == InstallStatus.paused) {
      return isBn
          ? 'ডাউনলোড স্থগিত / বিরতি (পুনরায় চালু করতে চাপুন)'
          : 'Download paused (tap Resume to continue)';
    }
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return errorMessage!;
    }

    final speedMb = (speedBytesPerSec / (1024 * 1024)).toStringAsFixed(1);
    final sec = remainingSeconds;
    final mins = sec ~/ 60;
    final remSec = sec % 60;

    if (isBn) {
      final bnSpeed = _toBanglaDigits(speedMb);
      String timePart;
      if (mins > 0) {
        timePart =
            '${_toBanglaDigits(mins.toString())} মিনিট ${_toBanglaDigits(remSec.toString())} সেকেন্ড';
      } else {
        timePart = '${_toBanglaDigits(remSec.toString())} সেকেন্ড';
      }
      return 'গতি: $bnSpeed MB/s • বাকি প্রায় $timePart';
    }

    String timePart;
    if (mins > 0) {
      timePart = '${mins}m ${remSec}s';
    } else {
      timePart = '${remSec}s';
    }
    return 'Speed: $speedMb MB/s • ~$timePart remaining';
  }

  static String _toBanglaDigits(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(en[i], bn[i]);
    }
    return result;
  }
}

class LocalAiModelNotifier extends StateNotifier<LocalAiModelState> {
  static const String _prefModelInstalledPrefix = 'key_local_ai_model_installed_';
  static const String _prefModelInstalledLegacyKey = 'key_local_ai_model_installed';
  static const String _prefSelectedTierKey = 'key_local_ai_selected_tier';

  http.Client? _httpClient;
  final http.Client? _customHttpClient;
  StreamSubscription<List<int>>? _streamSub;
  ModelFileSink? _fileSink;
  DateTime? _lastSpeedCalcTime;
  int _bytesSinceLastSpeedCalc = 0;

  LocalAiModelNotifier({http.Client? httpClient})
      : _customHttpClient = httpClient,
        super(const LocalAiModelState()) {
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedTier =
          prefs.getString(_prefSelectedTierKey) ?? AppConfig.localModelLightId;

      if (selectedTier == AppConfig.localModelProId) {
        _setProModelState();
      } else {
        _setLightModelState();
      }

      final isMarkedInstalled =
          (prefs.getBool('$_prefModelInstalledPrefix${state.modelId}') ?? false) ||
          (prefs.getBool(_prefModelInstalledLegacyKey) ?? false);
      final fileSizeBytes =
          await ModelFileStorage.instance.getLocalFileSizeBytes(state.modelId);
      final filePath =
          await ModelFileStorage.instance.getModelFilePath(state.modelId);

      // Verify physical file existence and minimum valid size threshold (95% of total)
      final bool fileTrulyExists = fileSizeBytes > 0 &&
          fileSizeBytes >= (state.totalBytes * 0.95).toInt();

      if (fileTrulyExists && isMarkedInstalled) {
        state = state.copyWith(
          status: InstallStatus.ready,
          progress: 1.0,
          downloadedBytes: state.totalBytes,
          diskSizeBytes: fileSizeBytes,
          isAutoConfigured: true,
          localPath: filePath,
        );
        await OfflineLegalInferenceEngine.setModelInstalled(true);
        AppLogger.i(
            'Verified & restored Local AI Model (${state.modelName}) from ROM storage ($fileSizeBytes bytes).');
      } else {
        // If SharedPreferences had a phantom/false positive flag, clean it up
        if (isMarkedInstalled && !fileTrulyExists) {
          AppLogger.w(
              'Clearing stale model installation flag: physical file missing or incomplete ($fileSizeBytes bytes).');
          await prefs.remove('$_prefModelInstalledPrefix${state.modelId}');
        }

        final double currentProgress = fileSizeBytes > 0 && state.totalBytes > 0
            ? (fileSizeBytes / state.totalBytes).clamp(0.0, 1.0)
            : 0.0;

        state = state.copyWith(
          status: fileSizeBytes > 0
              ? InstallStatus.paused
              : InstallStatus.notInstalled,
          progress: currentProgress,
          downloadedBytes: fileSizeBytes,
          diskSizeBytes: fileSizeBytes,
          isAutoConfigured: false,
          localPath: filePath,
        );
        await OfflineLegalInferenceEngine.setModelInstalled(false);
      }
    } catch (e) {
      AppLogger.w('Failed to load Local AI Model persisted state: $e');
    }
  }

  void _setLightModelState() {
    state = state.copyWith(
      modelId: AppConfig.localModelLightId,
      modelName: AppConfig.localModelLightName,
      versionTag: 'v2.5-gguf-q4',
      totalBytes: AppConfig.localModelLightSizeBytes,
      downloadUrl: AppConfig.localModelLightR2Url,
      expectedSha256: AppConfig.localModelLightSha256,
      ramRequirement: AppConfig.localModelLightRamRequirement,
      isRecommended: true,
      errorMessage: null,
    );
  }

  void _setProModelState() {
    state = state.copyWith(
      modelId: AppConfig.localModelProId,
      modelName: AppConfig.localModelProName,
      versionTag: 'v1.0-gguf-q4',
      totalBytes: AppConfig.localModelProSizeBytes,
      downloadUrl: AppConfig.localModelProR2Url,
      expectedSha256: AppConfig.localModelProSha256,
      ramRequirement: AppConfig.localModelProRamRequirement,
      isRecommended: false,
      errorMessage: null,
    );
  }

  /// Switches active model tier (Lightweight Qwen 2.5 vs Pro LLaMA 3.2)
  Future<void> selectModelTier({required bool isPro}) async {
    if (state.status == InstallStatus.downloading) return;

    if (isPro) {
      _setProModelState();
    } else {
      _setLightModelState();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefSelectedTierKey, state.modelId);

      final fileSizeBytes =
          await ModelFileStorage.instance.getLocalFileSizeBytes(state.modelId);
      final bool fileTrulyExists = fileSizeBytes > 0 &&
          fileSizeBytes >= (state.totalBytes * 0.95).toInt();
      final isMarked =
          prefs.getBool('$_prefModelInstalledPrefix${state.modelId}') ?? false;

      if (fileTrulyExists && isMarked) {
        state = state.copyWith(
          status: InstallStatus.ready,
          progress: 1.0,
          downloadedBytes: state.totalBytes,
          diskSizeBytes: fileSizeBytes,
          isAutoConfigured: true,
        );
        await OfflineLegalInferenceEngine.setModelInstalled(true);
      } else {
        final progress = fileSizeBytes > 0 && state.totalBytes > 0
            ? (fileSizeBytes / state.totalBytes).clamp(0.0, 1.0)
            : 0.0;
        state = state.copyWith(
          status: fileSizeBytes > 0
              ? InstallStatus.paused
              : InstallStatus.notInstalled,
          progress: progress,
          downloadedBytes: fileSizeBytes,
          diskSizeBytes: fileSizeBytes,
          isAutoConfigured: false,
        );
        await OfflineLegalInferenceEngine.setModelInstalled(false);
      }
    } catch (e) {
      AppLogger.w('Failed to switch model tier: $e');
    }
  }

  /// Starts or resumes streaming download from Cloudflare R2 and saves to ROM disk
  Future<void> startDownload() async {
    if (state.status == InstallStatus.downloading ||
        state.status == InstallStatus.ready) {
      return;
    }

    // Inspect existing bytes on disk
    int existingBytes =
        await ModelFileStorage.instance.getLocalFileSizeBytes(state.modelId);
    if (existingBytes >= state.totalBytes) {
      state = state.copyWith(
        status: InstallStatus.ready,
        progress: 1.0,
        downloadedBytes: state.totalBytes,
        diskSizeBytes: existingBytes,
        isAutoConfigured: true,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_prefModelInstalledPrefix${state.modelId}', true);
      await OfflineLegalInferenceEngine.setModelInstalled(true);
      return;
    }

    state = state.copyWith(
      status: InstallStatus.downloading,
      errorMessage: null,
    );

    _httpClient?.close();
    _httpClient = _customHttpClient ?? http.Client();

    try {
      final request = http.Request('GET', Uri.parse(state.downloadUrl));
      final bool isResuming = existingBytes > 0;
      if (isResuming) {
        request.headers['Range'] = 'bytes=$existingBytes-';
      }

      final response = await _httpClient!.send(request);

      if (response.statusCode != 200 && response.statusCode != 206) {
        if (response.statusCode == 404) {
          state = state.copyWith(
            status: InstallStatus.notInstalled,
            errorMessage:
                'মডেল ফাইলটি ক্লাউডফেয়ারে আপলোড প্রক্রিয়াধীন। বিকল্প হিসেবে প্রো মডেল (Llama 3.2) ডাউনলোড করতে পারেন।',
          );
          AppLogger.w('Model URL returned 404 Not Found: ${state.downloadUrl}');
          return;
        }
        throw Exception('Server responded with HTTP ${response.statusCode}');
      }

      // If server responded with 200 instead of 206, server does not support Range; restart from 0
      final bool serverSupportsRange = response.statusCode == 206;
      final int startBytes = serverSupportsRange ? existingBytes : 0;

      int totalContentLength = state.totalBytes;
      if (response.contentLength != null && response.contentLength! > 0) {
        totalContentLength = startBytes + response.contentLength!;
      }

      // Open writable file sink on ROM disk
      _fileSink = await ModelFileStorage.instance.openWriteStream(
        state.modelId,
        append: serverSupportsRange && startBytes > 0,
      );

      state = state.copyWith(
        totalBytes: totalContentLength,
        downloadedBytes: startBytes,
        diskSizeBytes: startBytes,
      );

      _lastSpeedCalcTime = DateTime.now();
      _bytesSinceLastSpeedCalc = 0;
      int accumulatedBytes = startBytes;

      _streamSub = response.stream.listen(
        (chunk) {
          _fileSink?.add(chunk);
          accumulatedBytes += chunk.length;
          _bytesSinceLastSpeedCalc += chunk.length;

          final now = DateTime.now();
          final elapsed = now.difference(_lastSpeedCalcTime!).inMilliseconds;

          double currentSpeed = state.speedBytesPerSec;
          if (elapsed >= 500) {
            currentSpeed = (_bytesSinceLastSpeedCalc / (elapsed / 1000.0));
            _bytesSinceLastSpeedCalc = 0;
            _lastSpeedCalcTime = now;
          }

          final pct = (accumulatedBytes / totalContentLength).clamp(0.0, 1.0);

          state = state.copyWith(
            downloadedBytes: accumulatedBytes,
            diskSizeBytes: accumulatedBytes,
            progress: pct,
            speedBytesPerSec: currentSpeed,
          );
        },
        onDone: () async {
          await _fileSink?.flush();
          await _fileSink?.close();
          _fileSink = null;

          final finalDiskSize = await ModelFileStorage.instance
              .getLocalFileSizeBytes(state.modelId);
          final filePath =
              await ModelFileStorage.instance.getModelFilePath(state.modelId);

          // Verify that full content was genuinely received (at least 95% threshold)
          final bool isComplete = finalDiskSize >= (totalContentLength * 0.95).toInt();

          if (isComplete) {
            state = state.copyWith(
              status: InstallStatus.ready,
              progress: 1.0,
              downloadedBytes: totalContentLength,
              diskSizeBytes: finalDiskSize,
              isAutoConfigured: true,
              speedBytesPerSec: 0.0,
              localPath: filePath,
              errorMessage: null,
            );

            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(
                  '$_prefModelInstalledPrefix${state.modelId}', true);
              await prefs.setBool(_prefModelInstalledLegacyKey, true);
              await OfflineLegalInferenceEngine.setModelInstalled(true);
              AppLogger.i(
                  '[Auto-Setup] Local AI Model (${state.modelName}) successfully saved to ROM ($finalDiskSize bytes) and active.');
            } catch (e) {
              AppLogger.w('Auto-setup persistence warning: $e');
            }
          } else {
            // Early disconnection before full transfer
            AppLogger.w(
                'Download stream ended early ($finalDiskSize / $totalContentLength bytes). Pausing download.');
            state = state.copyWith(
              status: InstallStatus.paused,
              downloadedBytes: finalDiskSize,
              diskSizeBytes: finalDiskSize,
              speedBytesPerSec: 0.0,
              errorMessage:
                  'ইন্টারনেট সংযোগ বিচ্ছিন্ন হয়েছিল। সংরক্ষিত: ${(finalDiskSize / (1024 * 1024)).toStringAsFixed(1)} MB। পুনরায় শুরু করতে চাপুন।',
            );
          }
        },
        onError: (err) async {
          await _fileSink?.flush();
          await _fileSink?.close();
          _fileSink = null;

          final finalDiskSize = await ModelFileStorage.instance
              .getLocalFileSizeBytes(state.modelId);
          AppLogger.e('Model download stream error: $err');
          state = state.copyWith(
            status: InstallStatus.paused,
            downloadedBytes: finalDiskSize,
            diskSizeBytes: finalDiskSize,
            speedBytesPerSec: 0.0,
            errorMessage: 'নেটওয়ার্ক সংযোগ বিঘ্নিত হয়েছে। পুনরায় চেষ্টা করুন।',
          );
        },
        cancelOnError: true,
      );
    } catch (e) {
      await _fileSink?.flush();
      await _fileSink?.close();
      _fileSink = null;

      final finalDiskSize = await ModelFileStorage.instance
          .getLocalFileSizeBytes(state.modelId);
      AppLogger.e('Failed to initiate model download: $e');
      state = state.copyWith(
        status: finalDiskSize > 0
            ? InstallStatus.paused
            : InstallStatus.notInstalled,
        downloadedBytes: finalDiskSize,
        diskSizeBytes: finalDiskSize,
        errorMessage: 'ডাউনলোড শুরু করা যায়নি: $e',
      );
    }
  }

  /// Pauses an active download, keeping current downloaded bytes on disk intact
  Future<void> pauseDownload() async {
    _streamSub?.cancel();
    _streamSub = null;
    _httpClient?.close();
    _httpClient = null;
    await _fileSink?.flush();
    await _fileSink?.close();
    _fileSink = null;

    final diskSize =
        await ModelFileStorage.instance.getLocalFileSizeBytes(state.modelId);
    state = state.copyWith(
      status: InstallStatus.paused,
      speedBytesPerSec: 0.0,
      diskSizeBytes: diskSize,
      downloadedBytes: diskSize,
    );
  }

  /// Resumes a paused download
  Future<void> resumeDownload() async {
    if (state.status != InstallStatus.paused) return;
    await startDownload();
  }

  /// Cancels and completely aborts the download, cleaning up disk file
  Future<void> cancelDownload() async {
    _streamSub?.cancel();
    _streamSub = null;
    _httpClient?.close();
    _httpClient = null;
    await _fileSink?.flush();
    await _fileSink?.close();
    _fileSink = null;

    await ModelFileStorage.instance.deleteModelFile(state.modelId);

    state = state.copyWith(
      status: InstallStatus.notInstalled,
      progress: 0.0,
      downloadedBytes: 0,
      diskSizeBytes: 0,
      speedBytesPerSec: 0.0,
      errorMessage: null,
    );
  }

  /// Removes the model from local ROM disk to reclaim phone storage
  Future<void> removeModel() async {
    await cancelDownload();
    state = state.copyWith(
      status: InstallStatus.notInstalled,
      progress: 0.0,
      downloadedBytes: 0,
      diskSizeBytes: 0,
      isAutoConfigured: false,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefModelInstalledPrefix${state.modelId}');
      await prefs.setBool(_prefModelInstalledLegacyKey, false);
      await OfflineLegalInferenceEngine.setModelInstalled(false);
      AppLogger.i(
          'Local AI Model (${state.modelName}) removed from ROM and storage reclaimed.');
    } catch (e) {
      AppLogger.w('Failed to clear model state from storage: $e');
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _httpClient?.close();
    _fileSink?.close();
    super.dispose();
  }
}

final localAiModelProvider =
    StateNotifierProvider<LocalAiModelNotifier, LocalAiModelState>((ref) {
  return LocalAiModelNotifier();
});
