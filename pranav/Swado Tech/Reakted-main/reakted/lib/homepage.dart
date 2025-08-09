import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reakted/providers/settings_provider.dart';
import 'package:reakted/utils/toast.dart';
import 'package:reakted/widgets/chat_message_feedback.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'providers/home_provider.dart';
import 'settings_page.dart';
import 'services/system_preferences_service.dart';

import 'services/feedback_service.dart';

class BreathingIcon extends StatefulWidget {
  const BreathingIcon({super.key});

  @override
  State<BreathingIcon> createState() => _BreathingIconState();
}

class _BreathingIconState extends State<BreathingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: const Icon(Icons.circle, color: Colors.black, size: 10),
        );
      },
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 3000),
    this.delay = const Duration(milliseconds: 10),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  String _displayText = '';
  int _currentIndex = 0;
  List<String> _words = [];

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = IntTween(
      begin: 0,
      end: _words.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _animation.addListener(() {
      final currentWordIndex = _animation.value.toInt();
      if (currentWordIndex != _currentIndex &&
          currentWordIndex <= _words.length) {
        setState(() {
          _currentIndex = currentWordIndex;
          _displayText = _words.take(currentWordIndex).join(' ');
        });
      }
    });

    // Start the animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _words = widget.text.split(' ');
      _currentIndex = 0;
      _displayText = '';
      _animation = IntTween(
        begin: 0,
        end: _words.length,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _controller.reset();
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayText, style: widget.style);
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _inactivityTimer;
  static const Duration _inactivityDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityDuration, () {
      if (mounted) {
        ref.read(chatMessagesProvider.notifier).clearMessages();
      }
    });
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vibes = ref.watch(vibesProvider);
    final selectedVibe = ref.watch(selectedVibeProvider);
    final chatMessages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(errorProvider);
    final isCopied = ref.watch(isCopiedProvider);
    final textController = ref.watch(textControllerProvider);
    final onRefineMessage = ref.watch(refineMessageProvider);
    final onCopyMessage = ref.watch(copyMessageProvider);
    final settings = ref.watch(settingsProvider);

    // Scroll to bottom when new message is added
    if (chatMessages.isNotEmpty) {
      _scrollToBottom();
      _resetInactivityTimer(); // Reset timer when messages are added
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Image.asset(
            'assets/images/reakted_logo.png',
            width: 32,
            height: 32,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(TablerIcons.settings, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment:
            chatMessages.isEmpty
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Align(
                  alignment:
                      chatMessages.isEmpty
                          ? Alignment.center
                          : Alignment.centerLeft,
                  child: Text(
                    "Let's Create",
                    textAlign:
                        chatMessages.isEmpty
                            ? TextAlign.center
                            : TextAlign.start,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Satoshi',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment:
                      chatMessages.isEmpty
                          ? Alignment.center
                          : Alignment.centerLeft,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "Turn your rough thoughts into polished, " +
                              (chatMessages.isNotEmpty ? '' : '\n'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                        TextSpan(
                          text: "perfect words",

                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (error != null)
            Card(
              margin: EdgeInsets.all(20),
              color: Colors.white,

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              ),
            ),
          // Chat messages section
          if (chatMessages.isNotEmpty) ...[
            Expanded(
              child:
                  chatMessages.isEmpty
                      ? const SizedBox.shrink()
                      : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: chatMessages.length,
                        itemBuilder: (context, index) {
                          final message = chatMessages[index];
                          print(message.aiResponse);
                          return _buildChatMessage(message, onCopyMessage);
                        },
                      ),
            ),
            Align(
              alignment: Alignment.centerRight,

              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    _resetInactivityTimer();
                    ref.read(chatMessagesProvider.notifier).clearMessages();
                  },
                  icon: const Icon(TablerIcons.refresh),
                  label: const Text('Refresh'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 130),
        ],
      ),

      bottomSheet: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text field
              TextFormField(
                controller: textController,
                keyboardType: TextInputType.text,
                maxLines: null,
                minLines: 1,
                onTap: _resetInactivityTimer,
                onChanged: (_) => _resetInactivityTimer(),
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText:
                      "Type like you talk — messy, scattered, voice-note style. We'll turn it into something clean, and clear.",
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  hintStyle: const TextStyle(
                    color: Color(0xFF96989C),
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Satoshi',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bottom row with tone selector and send button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tone selector
                  PopupMenuButton<String>(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          TablerIcons.adjustments_horizontal,
                          size: 16,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        if (selectedVibe.isEmpty)
                          const Text(
                            'Select Tone',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        if (selectedVibe.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EAED),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedVibe,
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    _resetInactivityTimer();
                                    ref
                                        .read(selectedVibeProvider.notifier)
                                        .state = '';
                                  },
                                  child: const Icon(
                                    TablerIcons.x,
                                    size: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    itemBuilder:
                        (context) =>
                            vibes
                                .map(
                                  (vibe) => PopupMenuItem(
                                    value: vibe,
                                    child: Text(
                                      vibe,
                                      style: const TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                    onSelected: (value) {
                      _resetInactivityTimer();
                      ref.read(selectedVibeProvider.notifier).state = value;
                    },
                  ),

                  // Send button
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color:
                          isLoading
                              ? Colors.grey[300]
                              : const Color.fromARGB(255, 1, 255, 9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                if (selectedVibe.isEmpty) {
                                  showToast('Please select a tone', context, 4);
                                  return;
                                }
                                if (textController.text.trim().isNotEmpty) {
                                  _resetInactivityTimer();
                                  onRefineMessage();
                                  // Clear the text controller immediately after sending
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    textController.clear();
                                  });
                                }
                              },
                      icon: Icon(
                        isLoading
                            ? Icons.square_rounded
                            : Icons.auto_fix_high_outlined,
                        size: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(
    ChatMessage message,
    Function(String) onCopyMessage,
  ) {
    final isCopied = ref.watch(isCopiedProvider);
    final isLiked = ref.watch(isLikedProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // User message (right aligned)
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.userMessage,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),

        // AI response (left aligned)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Response header
            Row(
              children: [
                const Icon(TablerIcons.sparkles, size: 16, color: Colors.black),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                    ),
                    children: [
                      const TextSpan(
                        text: 'Refined message ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Satoshi',
                        ),
                      ),
                      TextSpan(
                        text: '(${message.selectedTone})',
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Response content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child:
                  message.isLoading
                      ? const Align(
                        alignment: Alignment.topLeft,
                        child: BreathingIcon(),
                      )
                      : message.aiResponse != null
                      ? TypewriterText(
                        text: message.aiResponse!,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        duration: const Duration(milliseconds: 3000),
                        delay: const Duration(milliseconds: 50),
                      )
                      : const SizedBox.shrink(),
            ),

            if (message.aiResponse != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _resetInactivityTimer();
                        onCopyMessage(message.aiResponse!);
                      },
                      icon: Icon(isCopied ? Icons.check : Icons.copy, size: 16),
                      label: const SizedBox.shrink(),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(3),
                        minimumSize: const Size(28, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    // Very small gap
                    const SizedBox(width: 1),
                    Transform.translate(
                      offset: const Offset(-15, 0),
                      child: ChatMessageFeedback(
                        message: message,
                        onFeedback: (isPositive) {
                          if (isPositive) {
                            ref
                                .read(chatMessagesProvider.notifier)
                                .updateMessageLiked(message.id, true);

                            ref
                                .read(chatMessagesProvider.notifier)
                                .updateMessageDisliked(message.id, false);
                          } else {
                            ref
                                .read(chatMessagesProvider.notifier)
                                .updateMessageLiked(message.id, false);
                            ref
                                .read(chatMessagesProvider.notifier)
                                .updateMessageDisliked(message.id, true);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
