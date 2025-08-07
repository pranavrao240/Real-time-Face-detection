import '../services/chatgpt_service.dart';
import '../services/gemini_service.dart';
import '../services/claude_service.dart';

class AIService {
  static Future<String> refineText({
    required String provider,
    required String model,
    required String apiKey,
    required String inputText,
    required String vibe,
  }) async {
    switch (provider.toLowerCase()) {
      case 'chatgpt':
      case 'openai':
        return await ChatGPTService.refineText(
          apiKey: apiKey,
          inputText: inputText,
          vibe: vibe,
        );

      case 'gemini':
      case 'google':
        return await GeminiService.refineText(
          apiKey: apiKey,
          inputText: inputText,
          vibe: vibe,
          model: model,
        );

      case 'claude':
      case 'anthropic':
        return await ClaudeService.refineText(
          apiKey: apiKey,
          inputText: inputText,
          vibe: vibe,
          model: model,
        );

      default:
        throw Exception('Unsupported provider: $provider');
    }
  }
}
