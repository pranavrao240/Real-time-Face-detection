import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';

  static Future<String> refineText({
    required String apiKey,
    required String inputText,
    required String vibe,
    String model = 'claude-3-sonnet-20240229',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': 500,
          'messages': [
            {'role': 'user', 'content': _getUserPrompt(inputText, vibe)},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['content'] != null && data['content'].isNotEmpty) {
          return data['content'][0]['text'].trim();
        } else {
          throw Exception('No response from Claude API');
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'API Error: ${response.statusCode}';

        if (errorData['error'] != null) {
          if (errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'];
          }
          if (errorData['error']['type'] != null) {
            errorMessage = '${errorData['error']['type']}: $errorMessage';
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout: Please try again');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid API response format');
      } else {
        throw Exception('Error refining text: $e');
      }
    }
  }

  static String _getUserPrompt(String inputText, String vibe) {
    final systemPrompt = _getSystemPrompt(vibe);
    return '''$systemPrompt

Please refine this text: "$inputText"''';
  }

  static String _getSystemPrompt(String vibe) {
    switch (vibe) {
      case 'Warm & Personal':
        return '''You are a helpful assistant that transforms rough, informal text into warm and personal communication. 
        Provide ONLY ONE refined version of the text. Do not give multiple options or alternatives.
        Make the text feel friendly, approachable, and genuine while maintaining professionalism. 
        Use a conversational tone that builds rapport and connection. Keep the original meaning but make it more engaging and personal.
        Return the refined text directly without any explanations or additional text.''';

      case 'Professional & Clear':
        return '''You are a professional communication assistant that transforms rough text into clear, concise, and professional messages. 
        Provide ONLY ONE refined version of the text. Do not give multiple options or alternatives.
        Use formal language, proper grammar, and structure the message logically. 
        Make it suitable for business communication while maintaining clarity and professionalism.
        Return the refined text directly without any explanations or additional text.''';

      case 'Direct & Persuasive':
        return '''You are a persuasive communication expert that transforms rough text into direct, compelling, and action-oriented messages. 
        Provide ONLY ONE refined version of the text. Do not give multiple options or alternatives.
        Use strong, confident language that motivates action. 
        Be clear about the desired outcome and use persuasive techniques to influence the reader.
        Return the refined text directly without any explanations or additional text.''';

      case 'Casual & Easygoing':
        return '''You are a casual communication assistant that transforms rough text into relaxed, friendly, and approachable messages. 
        Provide ONLY ONE refined version of the text. Do not give multiple options or alternatives.
        Use informal but respectful language that feels natural and conversational. 
        Keep it light and easy to read while maintaining clarity.
        Return the refined text directly without any explanations or additional text.''';

      case 'Service‑Focused & Reassuring':
        return '''You are a customer service expert that transforms rough text into helpful, reassuring, and service-oriented messages. 
        Provide ONLY ONE refined version of the text. Do not give multiple options or alternatives.
        Focus on being helpful, addressing concerns, and providing reassurance. 
        Use empathetic language that shows understanding and commitment to helping.
        Return the refined text directly without any explanations or additional text.''';

      case 'Gratitude‑Driven':
        return '''You are a gratitude-focused communication assistant that transforms rough text into appreciative, thankful, and positive messages. 
        Provide ONLY ONE refined version of the text. Do not give multiple options or alternatives.
        Emphasize gratitude, appreciation, and positive sentiment. 
        Make the message feel warm and thankful while maintaining professionalism.
        Return the refined text directly without any explanations or additional text.''';

      default:
        return '''You are a helpful assistant that transforms rough, informal text into clear and polished communication. 
        Provide ONLY ONE refined version of the text. Do not give multiple options or alternatives.
        Make the text more professional, clear, and well-structured while maintaining the original meaning.
        Return the refined text directly without any explanations or additional text.''';
    }
  }
}
