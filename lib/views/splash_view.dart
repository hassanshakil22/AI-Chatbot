import 'dart:async';

import 'package:ai_chatbot/views/chat_UI.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const ChatUI()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[100]!,
                  Colors.purple[200]!
                ], // Define your gradient colors
                begin: Alignment.topLeft, // Gradient start point
                end: Alignment.bottomRight, // Gradient end point
              ),
            ),
            child: Center(
              child: Image.asset(
                "assets/medbot.png",
                width: MediaQuery.of(context).size.width * .75,
              ),
            )));
  }
}
