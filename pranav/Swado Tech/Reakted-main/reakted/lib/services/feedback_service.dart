import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  // Store feedback data
  static Future<void> storeFeedback({
    required String responseId,
    required bool isPositive,
    String? context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Store feedback with timestamp for analytics
    await prefs.setString(
      'feedback_$responseId',
      '${isPositive ? 'positive' : 'negative'}_$timestamp',
    );

    debugPrint(
      'Feedback stored: $responseId - ${isPositive ? 'positive' : 'negative'}',
    );
  }
}
