import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String provider;
  final String model;
  final String apiKey;
  final bool isLoading; // Add loading state

  SettingsState({
    this.provider = 'ChatGPT',
    this.model = 'gpt-3.5-turbo',
    this.apiKey = '',
    this.isLoading = true, // Start with loading true
  });

  SettingsState copyWith({
    String? provider,
    String? model,
    String? apiKey,
    bool? isLoading,
  }) {
    return SettingsState(
      provider: provider ?? this.provider,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get hasApiKey => apiKey.isNotEmpty;
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    // Ensure settings are loaded immediately
    _loadSettings();
  }

  static const String _providerKey = 'ai_provider';
  static const String _modelKey = 'ai_model';
  static const String _apiKeyKey = 'ai_api_key';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final provider = prefs.getString(_providerKey) ?? 'ChatGPT';
      final model = prefs.getString(_modelKey) ?? 'gpt-3.5-turbo';
      final apiKey = prefs.getString(_apiKeyKey) ?? '';

      // Update state with loaded values and set loading to false
      state = state.copyWith(
        provider: provider,
        model: model,
        apiKey: apiKey,
        isLoading: false,
      );
    } catch (e) {
      // Set loading to false even on error
      state = state.copyWith(isLoading: false);
    }
  }

  // Add a public method to reload settings if needed
  Future<void> reloadSettings() async {
    state = state.copyWith(isLoading: true);
    await _loadSettings();
  }

  Future<void> setProvider(String provider) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_providerKey, provider);
      
      // Define default models for each provider
      final defaultModels = {
        'ChatGPT': 'gpt-3.5-turbo',
        'Claude': 'claude-3-sonnet-20240229',
      };
      
      // Get the default model for the new provider
      final defaultModel = defaultModels[provider] ?? 'gpt-3.5-turbo';
      
      // Update both provider and model
      await prefs.setString(_modelKey, defaultModel);
      state = state.copyWith(
        provider: provider,
        model: defaultModel,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setModel(String model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modelKey, model);
      state = state.copyWith(model: model);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyKey, apiKey);
      state = state.copyWith(apiKey: apiKey);
    } catch (e) {
      // Handle error silently
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
