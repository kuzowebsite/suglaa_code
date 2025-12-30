import 'package:flutter/material.dart';
import 'dart:math';

class DiceGame extends StatefulWidget {
  const DiceGame({super.key});

  @override
  State<DiceGame> createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> {
  int diceValue = 1;
  bool isRolling = false;

  void _rollDice() async {
    setState(() => isRolling = true);
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        diceValue = Random().nextInt(6) + 1;
      });
    }
    setState(() => isRolling = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Та $diceValue буулгалаа!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("Азын Шоо", style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 150, height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: isRolling ? Colors.red.withOpacity(0.5) : Colors.black45, blurRadius: 20)],
              ),
              child: Center(
                 child: Icon(_getDiceIcon(diceValue), size: 80, color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: isRolling ? null : _rollDice,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: const Text("ШОО ХАЯХ", style: TextStyle(color: Colors.white, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }

  IconData _getDiceIcon(int value) {
    switch (value) {
      case 1: return Icons.looks_one;
      case 2: return Icons.looks_two;
      case 3: return Icons.looks_3;
      case 4: return Icons.looks_4;
      case 5: return Icons.looks_5;
      case 6: return Icons.looks_6;
      default: return Icons.looks_one;
    }
  }
}