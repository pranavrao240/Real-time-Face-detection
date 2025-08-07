import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reakted/utils/toast.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiKeyController = TextEditingController();
  bool _isObscured = true;

  final List<String> _providers = ['ChatGPT', 'Claude'];
  final Map<String, List<String>> _models = {
    'ChatGPT': ['gpt-3.5-turbo', 'gpt-4', 'gpt-4-turbo'],
    // 'Gemini': ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-pro'],
    'Claude': [
      'claude-3-sonnet-20240229',
      'claude-3-haiku-20240307',
      'claude-3-opus-20240229',
    ],
  };

  @override
  void initState() {
    super.initState();
    // Don't set the controller text here, let the build method handle it
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  String? _getValidModelValue(SettingsState settings) {
    final availableModels = _models[settings.provider ?? 'ChatGPT'] ?? [];
    if (availableModels.isEmpty) return null;

    // Check if current model is valid for the current provider
    if (availableModels.contains(settings.model)) {
      return settings.model;
    }

    // If not valid, return the first available model
    return availableModels.first;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // Update controller text when settings are loaded
    if (!settings.isLoading && _apiKeyController.text != settings.apiKey) {
      _apiKeyController.text = settings.apiKey;
    }

    // Show loading indicator while settings are being loaded
    if (settings.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(TablerIcons.chevron_left),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Provider',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your preferred AI provider for text refinement.',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          'Select Item',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items:
                            _providers
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/${e.toLowerCase()}.svg',
                                          width: 16,
                                          height: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(e),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                        value:
                            _providers.contains(settings.provider)
                                ? settings.provider
                                : null,
                        onChanged: (String? value) {
                          if (value != null) {
                            ref
                                .read(settingsProvider.notifier)
                                .setProvider(value);
                            ref
                                .read(settingsProvider.notifier)
                                .setModel(_models[value]?.first ?? '');
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          width: double.infinity,

                          decoration: BoxDecoration(
                            color: Colors.white,

                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // isExpanded: true,
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 335,
                          offset: Offset(0, -5),
                          // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          customHeights: _providers.map((e) => 40.0).toList(),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(TablerIcons.chevron_down),
                          openMenuIcon: Icon(TablerIcons.chevron_up),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Model',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose the specific model for your selected provider.',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        hint: Text(
                          'Select Item',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items:
                            _models[settings.provider ?? 'ChatGPT']
                                ?.map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList() ??
                            [],
                        value: _getValidModelValue(settings),
                        onChanged: (String? value) {
                          if (value != null) {
                            ref.read(settingsProvider.notifier).setModel(value);
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          width: double.infinity,

                          decoration: BoxDecoration(
                            color: Colors.white,

                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // isExpanded: true,
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 335,
                          offset: Offset(0, -5),
                          // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          customHeights:
                              _models[settings.provider ?? 'ChatGPT']
                                  ?.map((e) => 40.0)
                                  .toList() ??
                              [],
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(TablerIcons.chevron_down),
                          openMenuIcon: Icon(TablerIcons.chevron_up),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Key',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your ${settings.provider} API key to enable text refinement. Your key is stored locally and securely.',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _apiKeyController,
                        obscureText: _isObscured,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText:
                              settings.provider == 'ChatGPT'
                                  ? 'sk-...'
                                  : settings.provider == 'Claude'
                                  ? 'sk-ant-...'
                                  : 'AIza...',
                          hintStyle: TextStyle(
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? TablerIcons.eye
                                  : TablerIcons.eye_off,
                              size: 20,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(settingsProvider.notifier)
                        .setApiKey(_apiKeyController.text.trim());
                    if (mounted) {
                      showToast(
                        '${settings.provider} API key is configured',
                        context,
                        1,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF44FF59),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // if (settings.hasApiKey)
              //   Container(
              //     padding: const EdgeInsets.all(12),
              //     decoration: BoxDecoration(
              //       color: const Color(0xFFDCFCE7),
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(color: const Color(0xFF8BFFB7)),
              //     ),
              //     child: Row(
              //       children: [
              //         Icon(
              //           TablerIcons.circle_check_filled,
              //           color: Colors.green[700],
              //           size: 20,
              //         ),
              //         const SizedBox(width: 8),
              //         Text(
              //           '${settings.provider} API key is configured',
              //           style: TextStyle(
              //             color: Colors.black,
              //             fontWeight: FontWeight.w500,
              //             fontSize: 12,
              //             fontFamily: 'Satoshi',
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              const SizedBox(height: 32),
              const Text(
                'How to get your API key:',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              if (settings.provider == 'ChatGPT')
                const Text(
                  '1. Go to https://platform.openai.com/api-keys\n'
                  '2. Sign in or create an account\n'
                  '3. Click "Create new secret key"\n'
                  '4. Copy the key and paste it above',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                )
              else if (settings.provider == 'Claude')
                const Text(
                  '1. Go to https://console.anthropic.com/\n'
                  '2. Sign in or create an account\n'
                  '3. Navigate to API Keys section\n'
                  '4. Click "Create Key" and copy the key',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
