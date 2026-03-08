import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialAuthButton extends StatelessWidget {
  final String label;
  final String? iconPath;
  final bool useFlutterIcon;
  final IconData? flutterIcon;
  final Color? iconColor;
  final VoidCallback onPressed;
  final bool compact;

  const SocialAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconPath,
    this.useFlutterIcon = false,
    this.flutterIcon,
    this.iconColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          side: const BorderSide(color: Color(0x19BD660F)), // primary/10
        ),
        child: _buildIcon(),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (useFlutterIcon && flutterIcon != null) {
      return Icon(flutterIcon, color: iconColor, size: 24);
    } else if (iconPath != null) {
      return Image.asset(
        iconPath!,
        height: 20,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
      );
    }
    return const SizedBox.shrink();
  }
}
