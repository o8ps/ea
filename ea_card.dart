import 'package:flutter/material.dart';

class EaCard extends StatelessWidget {
  final String title;
  final Widget child;

  const EaCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111114),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 2.5,
              color: Color(0xFF555555),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
