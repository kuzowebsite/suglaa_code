import 'dart:async';
import 'package:flutter/material.dart';

class CinematicTimer extends StatefulWidget {
  final DateTime targetDate;
  const CinematicTimer({super.key, required this.targetDate});

  @override
  State<CinematicTimer> createState() => _CinematicTimerState();
}

class _CinematicTimerState extends State<CinematicTimer> {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeBlock(_timeLeft.inDays.toString().padLeft(2, '0'), "ӨДӨР"),
        _buildSeparator(),
        _buildTimeBlock((_timeLeft.inHours % 24).toString().padLeft(2, '0'), "ЦАГ"),
        _buildSeparator(),
        _buildTimeBlock((_timeLeft.inMinutes % 60).toString().padLeft(2, '0'), "МИН"),
        _buildSeparator(),
        _buildTimeBlock((_timeLeft.inSeconds % 60).toString().padLeft(2, '0'), "СЕК"),
      ],
    );
  }

  Widget _buildSeparator() {
    return Container(
      height: 50,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: const Text(":", style: TextStyle(color: Colors.white24, fontSize: 30, fontWeight: FontWeight.w100)),
    );
  }

  Widget _buildTimeBlock(String value, String label) {
    return Column(
      children: [
        // Хар хайрцаг
        Container(
          width: 60,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A), // Маш гүн хар
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: ClipRect( // Хайрцагнаас илүү гарсан хэсгийг хайчилна
            child: Stack(
              children: [
                // Тоонд "Flow Down" эффект оруулах
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    // ШИНЭЧЛЭЛ: Орж ирэх болон гарах хөдөлгөөнийг ялгах логик
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      // child.key нь ValueKey(value) байгаа.
                      // Хэрэв child-ийн утга одоогийн утгатай тэнцүү бол энэ нь "Шинэ" тоо.
                      final isNewValue = (child.key as ValueKey<String>).value == value;

                      if (isNewValue) {
                        // ШИНЭ ТОО: Дээрээс (-1.0) гол руу (0.0) орж ирнэ
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, -1.0), 
                            end: const Offset(0.0, 0.0),
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                          child: child,
                        );
                      } else {
                        // ХУУЧИН ТОО: Голоос (0.0) доошоо (1.0) алга болно
                        // AnimatedSwitcher гарахдаа animation-ийг 1.0 -> 0.0 руу бууруулдаг.
                        // Тиймээс Tween-ийг (Bottom -> Center) гэж тохируулбал, 
                        // урвуу ажиллахдаа Center -> Bottom руу явна.
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 1.0), 
                            end: const Offset(0.0, 0.0),
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
                          child: child,
                        );
                      }
                    },
                    // layoutBuilder ашиглаж давхарлаж харуулна (Stack)
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: Text(
                      value,
                      key: ValueKey<String>(value), // Key чухал!
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Roboto', 
                      ),
                    ),
                  ),
                ),
                // Шилэн гялбаа (Overlay)
                Positioned(
                  top: 0, left: 0, right: 0, height: 35,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.white.withOpacity(0.08), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ],
    );
  }
}