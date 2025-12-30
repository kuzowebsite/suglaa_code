import 'package:flutter/material.dart';
import 'dart:ui'; // Blur хийхэд хэрэгтэй

class ModernPrizeList extends StatelessWidget {
  const ModernPrizeList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. СУПЕР ШАГНАЛ (Онцгой загвар)
        _buildSuperPrizeCard(),
        
        const SizedBox(height: 15),
        
        // 2. Бусад шагнал (Жагсаалт)
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Хагас тунгалаг хар саарал
                color: const Color(0xFF2C2C3E).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildNormalRow("🥈", "1 азтан:", "4,000,000₮", "(10 жил сар бүр)"),
                  const Divider(color: Colors.white10, height: 25),
                  _buildNormalRow("🥉", "1 азтан:", "3,000,000₮", "(10 жил сар бүр)"),
                  const Divider(color: Colors.white10, height: 25),
                  _buildNormalRow("🏅", "7 азтан:", "2,000,000₮", "(7 хоног бүр)"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 1-р байрны онцгой карт
  Widget _buildSuperPrizeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Алтан шар градиент (Super Prize)
        gradient: const LinearGradient(
          colors: [Color(0xFF654321), Color(0xFF2C2C3E)], // Gold-ish dark to dark
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Алтан цомны Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 30),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "СУПЕР АЗТАН (1)",
                  style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                SizedBox(height: 5),
                Text(
                  "5,000,000₮",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  "10 жилийн турш сар бүр",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Энгийн мөр
  Widget _buildNormalRow(String icon, String label, String amount, String subText) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 2),
              Text(subText, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}