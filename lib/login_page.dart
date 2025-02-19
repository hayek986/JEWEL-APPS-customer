import 'package:flutter/material.dart';
import 'ProductListPage.dart';  // تأكد من استيراد صفحة قائمة المنتجات
import 'BackgroundWidget.dart'; // تأكد من استيراد BackgroundWidget هنا

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // للتحقق من صحة المدخلات

  // دالة للتحقق من المدخلات
  void _login() {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // هنا يمكن إضافة الكود للتحقق من اسم المستخدم وكلمة المرور
      if (username == 'admin' && password == '1234') {
        // إذا كان اسم المستخدم وكلمة المرور صحيحين، انتقل إلى صفحة قائمة المنتجات
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductListPage()),
        );
      } else {
        // إذا كانت المدخلات غير صحيحة، عرض رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('اسم المستخدم أو كلمة المرور غير صحيحة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.primaryDelta! > 0) {
          Navigator.pop(context); // This will handle the swipe to go back
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              color: Color(0xFF6A5096),  // تغيير لون النص إلى الأصفر
            ),
          ),
          backgroundColor: Colors.green, // تغيير لون AppBar إلى الأخضر
          centerTitle: true,  // محاذاة النص في المنتصف
          elevation: 0, // إزالة الظل ليتماشى مع التصميم المسطح
        ),
        body: BackgroundWidget( // إضافة BackgroundWidget هنا
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المستخدم',
                        labelStyle: TextStyle(color:Color(0xFF6A5096)), // تغيير لون النص إلى الأصفر
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.green), // تغيير لون الأيقونة
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أدخل اسم المستخدم';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true, // لإخفاء كلمة المرور
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        labelStyle: TextStyle(color: Color(0xFF6A5096)), // تغيير لون النص إلى الأصفر
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.green), // تغيير لون الأيقونة
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أدخل كلمة المرور';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // تغيير لون الخلفية إلى الأخضر
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(fontSize: 18, color: Color(0xFF6A5096)), // تغيير لون النص إلى الأصفر
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // يمكن إضافة إجراءات أخرى هنا مثل "نسيت كلمة المرور؟"
                      },
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(color: Color(0xFF6A5096)), // تغيير لون النص إلى الأخضر
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
