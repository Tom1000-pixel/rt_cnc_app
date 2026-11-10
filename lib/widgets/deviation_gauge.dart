import 'package:flutter/material.dart';

class DeviationGauge extends StatelessWidget {
  final String value;
  final String label;

  const DeviationGauge({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    // Parsing nilai string (misal "+0.123" atau "-0.005") ke double
    final numVal = double.tryParse(value) ?? 0.0;
    final absVal = numVal.abs();
    
    // Warna berdasarkan nilai (0 = hijau, <= 0.05 = kuning, > 0.05 = merah)
    Color color;
    if (absVal == 0) {
      color = const Color(0xFF34D399); // Hijau
    } else if (absVal <= 0.05) {
      color = const Color(0xFFFBBF24); // Kuning
    } else {
      color = const Color(0xFFFB7185); // Merah
    }

    // Skala bar (max 0.30)
    final double maxVal = 0.30;
    final double percent = (absVal / maxVal).clamp(0.0, 1.0);
    final isPositive = numVal >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 4),
        // Bar indicator
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              // Garis tengah
              Positioned(
                left: 30, top: 0, bottom: 0, width: 1,
                child: Container(color: Colors.white24),
              ),
              // Isi bar
              Positioned(
                left: isPositive ? 30 : 30 - (30 * percent),
                right: isPositive ? 30 - (30 * percent) : 30,
                top: 0, bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
