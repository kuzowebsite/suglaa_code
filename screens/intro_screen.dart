import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../layout/main_layout.dart';
import '../utils/app_colors.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ЭНД ЗУРАГ ОРНО (Та өөрийн asset зургийг тавиарай)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  // placeholder зураг
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://cdn.dribbble.com/userupload/10672133/file/original-40e38339758735611133935618338826.png?resize=400x300&vertical=center"),
                      fit: BoxFit.contain
                    )
                  ),
                  // Жинхэнэ 3D зургаа asset руу хийгээд доорхыг ашиглана:
                  // child: Image.asset("assets/images/3d_guy.png"), 
                ),
              ),
              const SizedBox(height: 30),
              
              // Текст хэсэг
              const Text("Learn \nDesign Systems",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
              ),
              const SizedBox(height: 15),
              Text("We have almost everything you can learn anytime or anywhere.",
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
              ),
              const Spacer(),

              // "Let's go" товч
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // MainLayout руу үсрэх
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainLayout()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726), // Улбар шар өнгө
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Let's go", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}