import 'package:flutter/material.dart';
import 'dart:math';

class ScratchCardGame extends StatefulWidget {
  const ScratchCardGame({super.key});

  @override
  State<ScratchCardGame> createState() => _ScratchCardGameState();
}

class _ScratchCardGameState extends State<ScratchCardGame> {
  double _opacity = 1.0;
  bool _isRevealed = false;
  String _prize = "5000₮"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("Хусах Сугалаа", style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Дэлгэц дээр хуруугаараа үрж арилгаарай", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Container(
              width: 300, height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 15)],
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber, width: 5),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
                          const SizedBox(height: 10),
                          Text(_prize, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _opacity -= 0.03;
                        if (_opacity < 0) _opacity = 0;
                        if (_opacity < 0.3 && !_isRevealed) {
                           _isRevealed = true;
                           _opacity = 0;
                        }
                      });
                    },
                    child: Opacity(
                      opacity: _opacity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.style, size: 50, color: Colors.grey),
                              Text("Энд үрж арилга", style: TextStyle(color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (_isRevealed)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _opacity = 1.0;
                    _isRevealed = false;
                    _prize = "${(Random().nextInt(10) + 1) * 1000}₮"; 
                  });
                },
                child: const Text("Дахин хусах"),
              )
          ],
        ),
      ),
    );
  }
}