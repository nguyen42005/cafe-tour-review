import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomDialogTone { success, error, info }

class CustomDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    bool isSuccess = false,
  }) {
    return _showByTone(
      context,
      title: title,
      message: message,
      tone: isSuccess ? CustomDialogTone.success : CustomDialogTone.error,
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return _showByTone(
      context,
      title: title,
      message: message,
      tone: CustomDialogTone.success,
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return _showByTone(
      context,
      title: title,
      message: message,
      tone: CustomDialogTone.error,
    );
  }

  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return _showByTone(
      context,
      title: title,
      message: message,
      tone: CustomDialogTone.info,
    );
  }

  static Future<void> _showByTone(
    BuildContext context, {
    required String title,
    required String message,
    required CustomDialogTone tone,
  }) {
    final style = _toneStyle(tone);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(style.icon, color: style.color, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: style.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Đóng',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static _DialogStyle _toneStyle(CustomDialogTone tone) {
    switch (tone) {
      case CustomDialogTone.success:
        return const _DialogStyle(Icons.check_circle, Colors.green);
      case CustomDialogTone.error:
        return const _DialogStyle(Icons.error, Colors.red);
      case CustomDialogTone.info:
        return const _DialogStyle(Icons.info, Colors.blue);
    }
  }
}

class _DialogStyle {
  final IconData icon;
  final Color color;

  const _DialogStyle(this.icon, this.color);
}
