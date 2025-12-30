import 'package:flutter/material.dart';

class MonochromePrizeList extends StatelessWidget {
  const MonochromePrizeList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. СУПЕР ШАГНАЛ (Хар дэвсгэр, Цагаан хүрээ)
        _buildSuperPrizeCard(),
        
        const SizedBox(height: 15),
        
        // 2. Бусад шагнал (Жагсаалт)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), // Хар саарал
            borderRadius: BorderRadius.circular(20),
            // Маш бүдэг цагаан хүрээ
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildNormalRow("II", "1 азтан:", "4,000,000₮", "(10 жил сар бүр)"),
              const Divider(color: Colors.white12, height: 25),
              _buildNormalRow("III", "1 азтан:", "3,000,000₮", "(10 жил сар бүр)"),
              const Divider(color: Colors.white12, height: 25),
              _buildNormalRow("IV", "7 азтан:", "2,000,000₮", "(7 хоног бүр)"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuperPrizeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.black, // Цэвэр хар
        borderRadius: BorderRadius.circular(20),
        // Цагаан гэрэлтсэн хүрээ (Glow биш, хатуу хүрээ)
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon placeholder
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star, color: Colors.black, size: 28),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "СУПЕР АЗТАН",
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                SizedBox(height: 5),
                Text(
                  "5,000,000₮",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _buildNormalRow(String rank, String label, String amount, String subText) {
    return Row(
      children: [
        // Байр эзэлсэн дугаар
        Container(
          width: 30,
          alignment: Alignment.center,
          child: Text(rank, style: const TextStyle(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 2),
              Text(subText, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}