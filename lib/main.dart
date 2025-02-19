import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // تأكد من أنك قمت باستيراد هذه الحزمة
import 'order.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'payment_page.dart';
import 'more_products_page.dart';
import 'product_details_page.dart';
import 'gold_price_service.dart';
import 'cart_model.dart'; // تأكد من استيراد CartModel هنا
import 'twilio_service.dart'; // استيراد خدمة Twilio
import 'login_page.dart'; // استيراد صفحة تسجيل الدخول
import 'add_product_page.dart'; // ا
import 'EditProductPage.dart';
import 'about_us.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      messagingSenderId: "78317324117",
      apiKey: "AIzaSyCMn0sc0hEhH985nmSV69vXVMrMs-rDSR4",
      appId: "1:1:78317324117:android:7588c4faadd1fc7c8711dc",
      projectId: "alhayekjewelry-7ff5e",
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'متجر الحايك للمجوهرات',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/products': (context) => MoreProductsPage(),
        '/productDetails': (context) => ProductDetailsPage(),
        '/cart': (context) => CartPage(),
        '/payment': (context) => PaymentPage(),
        '/login': (context) => LoginPage(), // إضافة مسار صفحة تسجيل الدخول
        '/addProduct': (context) => AddProductPage(), // إضافة مسار صفحة إضافة المنتج
        '/editProduct': (context) => EditProductPage(), // تأكد من إضافة المسار
        '/aboutus': (context) => AboutUsPage(),  // تأكد من استخدام AboutUsPage هنا
      },
    );
  }
}
