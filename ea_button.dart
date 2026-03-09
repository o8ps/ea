import 'package:flutter/material.dart';

class EaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final Color? color;
  final Color? textColor;

  const EaButton({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? (primary ? const Color(0xFF2A2A2E) : const Color(0xFF1A1A1E));
    final fg = textColor ?? (primary ? Colors.white : const Color(0xFF929292));
    final disabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.35 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 11),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2A2E)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              color: fg,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
