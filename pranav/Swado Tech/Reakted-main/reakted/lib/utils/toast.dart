import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:tabler_icons/tabler_icons.dart';

void showToast(String message, BuildContext context, int type) {
  var color = Colors.white;
  Icon icon = Icon(Icons.check_circle);

  switch (type) {
    case 1:
      color = Color(0xFF8BFFB7);
      icon = Icon(TablerIcons.circle_check_filled, color: Colors.green);
    case 2:
      color = Colors.red;
      icon = Icon(Icons.error, color: Colors.white);
    case 3:
      color = Colors.orange;
      icon = Icon(Icons.warning, color: Colors.white);
    case 4:
      color = Color(0xFFFFFFFF);
      icon = Icon(TablerIcons.x, color: Colors.black, size: 16, fill: 1);
    default:
  }

  // Show the toast
  WidgetsBinding.instance.addPostFrameCallback((_) {
    DelightToastBar(
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 4),
      builder:
          (context) => ToastCard(
            leading: type == 4 ? null : icon,
            trailing: type == 4 ? icon : null,
            color: color,
            title: Text(
              message,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            onTap: () {
              DelightToastBar.removeAll();
            },
          ),
    ).show(context);
  });
}


// Types of Toast
// 1 - Success
// 2 - Error
// 3 - Warning
// 4 - Info