import 'dart:async';
import 'package:flutter/material.dart';

class ModernTimer extends StatefulWidget {
  final DateTime targetDate;
  const ModernTimer({super.key, required this.targetDate});

  @override
  State<ModernTimer> createState() => _ModernTimerState();
}

class _ModernTimerState extends State<ModernTimer> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.targetDate.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          if (widget.targetDate.isAfter(now)) {
            _timeLeft = widget.targetDate.difference(now);
          } else {
            _timeLeft = Duration.zero;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3), // Арын бүдэг дэвсгэр
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCapsule(_timeLeft.inDays.toString().padLeft(2, '0'), "Өдөр", Colors.blueAccent),
          _buildDots(),
          _buildCapsule((_timeLeft.inHours % 24).toString().padLeft(2, '0'), "Цаг", Colors.purpleAccent),
          _buildDots(),
          _buildCapsule((_timeLeft.inMinutes % 60).toString().padLeft(2, '0'), "Мин", Colors.orangeAccent),
          _buildDots(),
          _buildCapsule((_timeLeft.inSeconds % 60).toString().padLeft(2, '0'), "Сек", Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return const Column(
      children: [
        Icon(Icons.circle, size: 4, color: Colors.white54),
        SizedBox(height: 5),
        Icon(Icons.circle, size: 4, color: Colors.white54),
      ],
    );
  }

  Widget _buildCapsule(String value, String label, Color glowColor) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(15),
            // Неон гэрэл (Glow Effect)
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 0),
              )
            ],
            border: Border.all(color: glowColor.withOpacity(0.5), width: 1.5),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier', // Дижитал фонт шиг харагдуулна
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}