import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.truck, size: 64, color: const Color(0xFF2EC4B6)),
            const SizedBox(height: 16),
            const Text(
              'ExpressDeliv',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827), letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Livraison express',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2EC4B6)),
          ],
        ),
      ),
    );
  }
}