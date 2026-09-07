/// Centralized API Constants & Security Config
class ApiConstants {
  ApiConstants._();

  /// Default Gemini API Key (Can be overridden via --dart-define or App UI Modal)
  static const String defaultGeminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Default model identifier
  static const String geminiModel = 'gemini-1.5-flash';
}
