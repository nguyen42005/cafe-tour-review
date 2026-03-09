import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class PlaceFieldLabel extends StatelessWidget {
  const PlaceFieldLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.publicSans(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

class PlaceFormTextField extends StatelessWidget {
  const PlaceFormTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.textAlign = TextAlign.start,
    this.onSubmitted,
    this.onChanged,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final TextAlign textAlign;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: textAlign,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      cursorColor: AppColors.primary,
      style: GoogleFonts.publicSans(color: const Color(0xFF1E293B), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.publicSans(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      ),
    );
  }
}

class PlaceTimePickerField extends StatelessWidget {
  const PlaceTimePickerField({
    super.key,
    required this.value,
    required this.onSelected,
  });

  final String value;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(value.split(':')[0]),
            minute: int.parse(value.split(':')[1]),
          ),
        );
        if (picked != null) {
          onSelected(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: GoogleFonts.publicSans()),
            const Icon(Icons.access_time, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
