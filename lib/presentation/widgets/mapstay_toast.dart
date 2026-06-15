import 'package:flutter/material.dart';


enum MapStayToastType { success, info, warning, error }




class MapStayToast {




  static void show(
    BuildContext context, {
    required String message,
    required MapStayToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {

    final (accentColor, iconData) = switch (type) {
      MapStayToastType.success => (const Color(0xFF20B2AA), Icons.check_circle_outline_rounded),
      MapStayToastType.info    => (const Color(0xFF7BD0FF), Icons.info_outline_rounded),
      MapStayToastType.warning => (const Color(0xFFFBBF24), Icons.warning_amber_rounded),
      MapStayToastType.error   => (const Color(0xFFEF4444), Icons.error_outline_rounded),
    };

    final theme = Theme.of(context);


    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        elevation: 4.0,
        backgroundColor: const Color(0xFF222A3D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: accentColor,
            width: 1.0,
          ),
        ),

        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        content: Row(
          children: [
            Icon(
              iconData,
              color: accentColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ) ?? const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFF1F5F9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
