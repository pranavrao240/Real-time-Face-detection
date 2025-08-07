import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for saving user prompts as system preferences (not history)
class SystemPreferencesService {
  static const String _promptKey = 'user_prompts';
  static const String _feedbackKey = 'user_feedback';

  /// Save a user prompt to system preferences
  static Future<void> savePrompt(String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    final existingPrompts = prefs.getStringList(_promptKey) ?? [];

    // Add new prompt to the beginning of the list
    existingPrompts.insert(0, prompt);

    // Keep only last 50 prompts to prevent excessive storage
    if (existingPrompts.length > 50) {
      existingPrompts.removeLast();
    }

    await prefs.setStringList(_promptKey, existingPrompts);
  }

  /// Get all saved user prompts from system preferences
  static Future<List<String>> getSavedPrompts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_promptKey) ?? [];
  }

  /// Clear all saved prompts from system preferences
  static Future<void> clearPrompts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_promptKey);
  }

  static Future<bool> promptExists(String prompt) async {
    final prompts = await getSavedPrompts();
    return prompts.contains(prompt);
  }

  static Future<void> saveFeedback(
    String messageId,
    String feedbackType, {
    String? comment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingFeedback = prefs.getStringList(_feedbackKey) ?? [];

    final entry = '$messageId|$feedbackType|${comment ?? ''}';
    existingFeedback.insert(0, entry);
    if (existingFeedback.length > 100) {
      existingFeedback.removeLast();
    }
    await prefs.setStringList(_feedbackKey, existingFeedback);
  }

  /// Get all saved feedback
  static Future<List<String>> getSavedFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_feedbackKey) ?? [];
  }

  /// Clear all saved feedback
  static Future<void> clearFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_feedbackKey);
  }
}
