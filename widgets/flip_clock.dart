import 'dart:async';
import 'package:flutter/material.dart';

class FlipCountdown extends StatefulWidget {
  final DateTime targetDate;
  const FlipCountdown({super.key, required this.targetDate});

  @override
  State<FlipCountdown> createState() => _FlipCountdownState();
}

class _FlipCountdownState extends State<FlipCountdown> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.targetDate.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final now = DateTime.now();
        if (widget.targetDate.isAfter(now)) {
          _timeLeft = widget.targetDate.difference(now);
        } else {
          _timeLeft = Duration.zero;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFlipUnit(_timeLeft.inDays.toString().padLeft(2, '0'), "Өдөр"),
        _separator(),
        _buildFlipUnit((_timeLeft.inHours % 24).toString().padLeft(2, '0'), "Цаг"),
        _separator(),
        _buildFlipUnit((_timeLeft.inMinutes % 60).toString().padLeft(2, '0'), "Мин"),
        _separator(),
        _buildFlipUnit((_timeLeft.inSeconds % 60).toString().padLeft(2, '0'), "Сек"),
      ],
    );
  }

  Widget _separator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 15),
      child: Text(":", style: TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFlipUnit(String value, String label) {
    return Column(
      children: [
        FlipCard(value: value),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}

class FlipCard extends StatelessWidget {
  final String value;
  const FlipCard({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF202025),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(0, 4), blurRadius: 4)
        ],
      ),
      child: Stack(
        children: [
          // Дээд тал
          Positioned.fill(
            bottom: 25,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2C2C35),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
          ),
          // Дундын шугам (Нугас)
          Center(child: Container(height: 1, color: Colors.black)),
          // Тоо (AnimatedSwitcher ашиглаж Flip эффект оруулна)
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final rotateAnim = Tween(begin: 0.5, end: 0.0).animate(animation);
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Text(
                value,
                key: ValueKey<String>(value),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}