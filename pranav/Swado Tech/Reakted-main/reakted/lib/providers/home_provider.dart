import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../services/system_preferences_service.dart';
import 'settings_provider.dart';

// Chat message model
class ChatMessage {
  final String id;
  final String userMessage;
  final String? aiResponse;
  final String selectedTone;
  final DateTime timestamp;
  final bool isLoading;
  final bool isDisliked;
  final bool isLiked;

  ChatMessage({
    required this.id,
    required this.userMessage,
    this.aiResponse,
    required this.selectedTone,
    required this.timestamp,
    this.isLoading = false,
    this.isDisliked = false,
    this.isLiked = false,
  });

  ChatMessage copyWith({
    String? id,
    String? userMessage,
    String? aiResponse,
    String? selectedTone,
    DateTime? timestamp,
    bool? isLoading,
    bool? isDisliked,
    bool? isLiked,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userMessage: userMessage ?? this.userMessage,
      aiResponse: aiResponse ?? this.aiResponse,
      selectedTone: selectedTone ?? this.selectedTone,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      isDisliked: isDisliked ?? this.isDisliked,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

// Provider for the list of available vibes
final vibesProvider = Provider<List<String>>((ref) {
  return [
    'Warm & Personal',
    'Professional & Clear',
    'Direct & Persuasive',
    'Casual & Easygoing',
    'Service‑Focused & Reassuring',
    'Gratitude‑Driven',
  ];
});

// Provider for the selected vibe state
final selectedVibeProvider = StateProvider<String>((ref) => '');

// Provider for the text controller
final textControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  // Dispose the controller when the provider is disposed
  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});

// Provider for chat messages
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
      (ref) => ChatMessagesNotifier(),
    );

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(String userMessage, String selectedTone) {
    // Save prompt to system preferences (not history)
    SystemPreferencesService.savePrompt(userMessage);

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userMessage: userMessage,
      selectedTone: selectedTone,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    print('Adding new message: ${newMessage.id}'); // Debug print
    state = [...state, newMessage];
    print('State length after adding: ${state.length}'); // Debug print
  }

  void updateMessageResponse(String messageId, String response) {
    print(
      'Updating message $messageId with response: $response',
    ); // Debug print
    state =
        state.map((message) {
          if (message.id == messageId) {
            return message.copyWith(aiResponse: response, isLoading: false);
          }
          return message;
        }).toList();
    print('Updated state length: ${state.length}'); // Debug print
  }

  void clearMessages() {
    state = [];
  }

  void updateMessageDisliked(String messageId, bool isDisliked) {
    state =
        state.map((message) {
          if (message.id == messageId) {
            return message.copyWith(isDisliked: isDisliked);
          }
          return message;
        }).toList();
  }

  void updateMessageLiked(String messageId, bool isLiked) {
    state =
        state.map((message) {
          if (message.id == messageId) {
            return message.copyWith(isLiked: isLiked);
          }
          return message;
        }).toList();
  }
}

// Provider for loading state
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for error state
final errorProvider = StateProvider<String?>((ref) => null);

// Provider for copy state
final isCopiedProvider = StateProvider<bool>((ref) => false);

// Provider for like state
final isLikedProvider = StateProvider<bool>((ref) => false);

// Provider for handling vibe selection
final vibeSelectionProvider = Provider.family<void Function(String), String>((
  ref,
  vibe,
) {
  return (String selectedVibe) {
    final currentVibe = ref.read(selectedVibeProvider);
    if (currentVibe == selectedVibe) {
      ref.read(selectedVibeProvider.notifier).state = '';
    } else {
      ref.read(selectedVibeProvider.notifier).state = selectedVibe;
    }
  };
});

// Provider for handling refine message action
final refineMessageProvider = Provider<void Function()>((ref) {
  return () async {
    final selectedVibe = ref.read(selectedVibeProvider);
    final input = ref.read(textControllerProvider).text;
    final settings = ref.read(settingsProvider);

    if (input.trim().isEmpty) {
      ref.read(errorProvider.notifier).state =
          'Please enter some text to refine';
      return;
    }

    if (selectedVibe.isEmpty) {
      ref.read(errorProvider.notifier).state = 'Please select a vibe';
      return;
    }

    if (settings.isLoading) {
      // Wait a bit for settings to load
      await Future.delayed(const Duration(milliseconds: 100));
      // Re-read settings after potential load
      final updatedSettings = ref.read(settingsProvider);
      if (updatedSettings.isLoading) {
        ref.read(errorProvider.notifier).state =
            'Settings are still loading, please try again';
        return;
      }

      if (updatedSettings.apiKey.isEmpty) {
        ref.read(errorProvider.notifier).state =
            'Please set your API key in settings';
        return;
      }
    } else if (settings.apiKey.isEmpty) {
      ref.read(errorProvider.notifier).state =
          'Please set your API key in settings';
      return;
    }

    try {
      ref.read(isLoadingProvider.notifier).state = true;
      ref.read(errorProvider.notifier).state = null;

      // Add new message to chat
      ref.read(chatMessagesProvider.notifier).addMessage(input, selectedVibe);

      // Get the latest message ID
      final messages = ref.read(chatMessagesProvider);
      final latestMessage = messages.last;

      // Build conversation history for context-aware AI
      final chatMessages = ref.read(chatMessagesProvider);
      final List<Map<String, String>> messagesHistory = [];
      for (final m in chatMessages) {
        if (m.userMessage.isNotEmpty) {
          messagesHistory.add({'role': 'user', 'content': m.userMessage});
        }
        if (m.aiResponse != null && m.aiResponse!.isNotEmpty) {
          messagesHistory.add({'role': 'assistant', 'content': m.aiResponse!});
        }
      }
      // Add the current input as the latest user message
      messagesHistory.add({'role': 'user', 'content': input});

      final refinedText = await AIService.refineText(
        provider: settings.provider,
        model: settings.model,
        apiKey: settings.apiKey,
        inputText: input,
        vibe: selectedVibe,
        messages: messagesHistory,
      );

      print('AI Response: $refinedText'); // Debug print

      // Update the message with the response
      ref
          .read(chatMessagesProvider.notifier)
          .updateMessageResponse(latestMessage.id, refinedText);

      // Clear the text controller
      ref.read(textControllerProvider).clear();

      // Reset selected vibe to default
    } catch (e) {
      ref.read(errorProvider.notifier).state = e.toString();
      // If there's an error, also clear the text controller
      ref.read(textControllerProvider).clear();
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  };
});

// Provider for copy action
final copyMessageProvider = Provider<void Function(String)>((ref) {
  return (String text) async {
    if (text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
      ref.read(isCopiedProvider.notifier).state = true;

      // Reset copy state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        ref.read(isCopiedProvider.notifier).state = false;
      });
    }
  };
});

// Provider for refresh action
final refreshMessageProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(chatMessagesProvider.notifier).clearMessages();
    ref.read(errorProvider.notifier).state = null;
  };
});
