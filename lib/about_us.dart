import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('من نحن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFFFFD700))),
        backgroundColor: Color(0xFF4CAF50),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'نحن متجر الحايك للمجوهرات، نوفر لكم أرقى أنواع المجوهرات بأفضل الأسعار.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: Colors.black),
        ),
      ),
    );
  }
}
