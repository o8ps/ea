import 'package:flutter/material.dart';

class EaField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final TextInputType? keyboardType;
  final bool obscure;

  const EaField({
    super.key,
    required this.ctrl,
    required this.label,
    this.keyboardType,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: Colors.white),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
