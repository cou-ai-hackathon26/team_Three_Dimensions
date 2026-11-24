/// Central application configuration for MyLaws
class AppConfig {
  /// Dedicated standalone Cloudflare API Worker endpoints
  static const String localApiBaseUrl = 'http://127.0.0.1:8787';
  static const String remoteApiBaseUrl =
      'https://mylaws-api.fork-x-master.workers.dev';
  static const String apiBaseUrl = remoteApiBaseUrl;

  /// Maximum time the app will wait for Meta Model API online response
  /// before handing over to the on-device Local AI model.
  static const Duration onlineApiTimeout = Duration(seconds: 35);

  /// Standard timeout for quick metadata API calls (auth check, quota check, etc.)
  static const Duration standardApiTimeout = Duration(seconds: 15);

  /// Local AI Model specifications (Cloudflare R2 storage & CORS Worker)
  /// Tier 1: Light Model (Recommended for 2GB - 4GB RAM devices)
  static const String localModelLightId = 'qwen-2.5-0.5b';
  static const String localModelLightName = 'Qwen 2.5 0.5B Instruct (Q4_K_M)';
  static const int localModelLightSizeBytes = 491400032; // ~468 MB (491.4 MB)
  static const String localModelLightR2Url =
      'https://mylaws-model-uploader.fork-x-master.workers.dev/download?key=Qwen2.5-0.5B-Instruct-Q4_K_M.gguf';
  static const String localModelLightSha256 =
      '74A4DA8C9FDBCD15BD1F6D01D621410D31C6FC00986F5EB687824E7B93D7A9DB';
  static const String localModelLightRamRequirement = '2 GB - 4 GB RAM';

  /// Tier 2: Pro Model (For 6GB+ RAM devices)
  static const String localModelProId = 'llama-3.2-1b';
  static const String localModelProName = 'Llama 3.2 1B Instruct (Q4_K_M)';
  static const int localModelProSizeBytes = 807694464; // ~808 MB
  static const String localModelProR2Url =
      'https://mylaws-model-uploader.fork-x-master.workers.dev/download?key=Llama-3.2-1B-Instruct-Q4_K_M.gguf';
  static const String localModelProSha256 =
      '6F85A640A97CF2BF5B8E764087B1E83DA0FDB51D7C9FAB7D0FECE9385611DF83';
  static const String localModelProRamRequirement = '6 GB+ RAM';

  /// Default active on-device model specifications (Dual-tier default: Light model)
  static const String localModelName = localModelLightName;
  static const int localModelSizeBytes = localModelLightSizeBytes;
  static const String localModelR2Url = localModelLightR2Url;
  static const String localModelSha256 = localModelLightSha256;

  /// Cloudflare D1 Legal Database (Serverless SQLite)
  static const String cloudflareD1DatabaseName = 'mylaws-db';
  static const String cloudflareD1DatabaseUuid =
      '04619018-0f31-49b8-a6b0-a975e13c414c';
}
