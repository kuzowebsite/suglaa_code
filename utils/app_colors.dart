import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  
  // ШИНЭ: Тасалбарын хар саарал дэвсгэр
  static const Color ticketBackground = Color(0xFF2C2C2C);

  // ... бусад өнгөнүүд хэвээрээ ...
  static const Color walletDark = Color(0xFF2C2C2C);
  static const Color walletTexture = Color(0xFF1A1A1A);
  static const LinearGradient goldCard = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFD4AF37), Color(0xFFC5A028)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    stops: [0.1, 0.5, 0.9],
  );
  static const LinearGradient orangeCard = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient blueCard = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF26C6DA)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient purpleCard = LinearGradient(
    colors: [Color(0xFFAB47BC), Color(0xFF7E57C2)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}