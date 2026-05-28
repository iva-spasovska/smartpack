import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final Color fieldColor;
  final Color textColor;

  const PasswordField({
    super.key,
    required this.controller,
    required this.hint,
    required this.fieldColor,
    required this.textColor,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: GoogleFonts.poppins(color: widget.textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.fieldColor,
        hintText: widget.hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF4F8D9C),
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFC7DDE8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF4F8D9C), width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
      ),
    );
  }
}
