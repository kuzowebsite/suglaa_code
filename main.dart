import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/auth_screen.dart'; 
import 'utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dark 3D App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      
      // ▼▼▼ МОНГОЛ ХЭЛНИЙ ТОХИРГОО ▼▼▼
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('mn', 'MN'), // Монгол хэл
        Locale('en', 'US'), // Англи хэл
      ],
      locale: const Locale('mn', 'MN'), // Үндсэн хэлийг Монгол болгох
      // ▲▲▲ ▲▲▲

      home: const AuthScreen(),
    );
  }
}