import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> refineText({
    required String apiKey,
    required String inputText,
    required String vibe,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': _getSystemPrompt(vibe)},
            {'role': 'user', 'content': inputText},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'].trim();
        } else {
          throw Exception('No response from ChatGPT API');
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
