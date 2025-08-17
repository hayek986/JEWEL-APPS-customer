import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'من نحن',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Color(0xFFFFD700), // ذهبي
          ),
        ),
        backgroundColor: const Color(0xFF800080), // بنفسجي بدل الأخضر
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth > 600 ? 30.0 : 22.0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'نحن متجر الحايك للمجوهرات، نوفر لكم أرقى أنواع المجوهرات بأفضل الأسعار.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.white, // خط الكتابة أبيض
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFF800080), // يمكن إضافة خلفية بنفسجية لجعل النص الأبيض واضح
    );
  }
}
