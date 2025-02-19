import 'package:flutter/material.dart'; // استيراد مكتبة Flutter

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  BackgroundWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity, // تأكد من ملء الشاشة
      width: double.infinity, // تأكد من ملء الشاشة
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bk.png'), // الصورة الخاصة بالخلفية
          fit: BoxFit.cover, // ملء الشاشة بالصورة
        ),
      ),
      child: child,
    );
  }
}
