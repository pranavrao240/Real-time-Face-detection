import 'package:flutter/material.dart';
import 'package:reakted/utils/toast.dart';

class SmartFeedbackWidget extends StatefulWidget {
  final String responseId;
  final Function(bool isPositive)? onFeedback;
  final String? context;

  const SmartFeedbackWidget({
    super.key,
    required this.responseId,
    this.onFeedback,
    this.context,
  });

  @override
  State<SmartFeedbackWidget> createState() => _SmartFeedbackWidgetState();
}

class _SmartFeedbackWidgetState extends State<SmartFeedbackWidget> {
  bool? _userFeedback;

  void _handleFeedback(bool isPositive) {
    setState(() {
      if (_userFeedback == isPositive) {
        _userFeedback = null;
      } else {
        _userFeedback = isPositive;
      }
    });

    if (_userFeedback != null) {
      widget.onFeedback?.call(_userFeedback!);
      showToast("Feedback sent Successfully", context, 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 12),

        // Show thumbs up only if no feedback or user selected thumbs up
        if (_userFeedback == null || _userFeedback == true)
          _buildFeedbackButton(
            isPositive: true,
            isSelected: _userFeedback == true,
            onTap: () => _handleFeedback(true),
          ),

        if (_userFeedback == null) const SizedBox(width: 8),

        // Show thumbs down only if no feedback or user selected thumbs down
        if (_userFeedback == null || _userFeedback == false)
          _buildFeedbackButton(
            isPositive: false,
            isSelected: _userFeedback == false,
            onTap: () => _handleFeedback(false),
          ),
      ],
    );
  }

  Widget _buildFeedbackButton({
    required bool isPositive,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color selectedColor = isPositive ? Colors.black : Colors.black;
    Color unselectedColor = Colors.grey[500]!;
    Color fillColor =
        isSelected
            ? (isPositive ? Colors.green[50]! : Colors.red[50]!)
            : Colors.transparent;
    Color borderColor = isSelected ? selectedColor : Colors.grey[300]!;

    IconData iconData =
        isPositive
            ? (isSelected ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined)
            : (isSelected
                ? Icons.thumb_down_alt
                : Icons.thumb_down_alt_outlined);

    return Material(
      color: fillColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),

          child: Icon(
            iconData,
            size: 16,
            color: isSelected ? selectedColor : unselectedColor,
          ),
        ),
      ),
    );
  }
}
