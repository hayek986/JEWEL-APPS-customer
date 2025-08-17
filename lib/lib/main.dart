import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'cart_model.dart';
import 'cart_page.dart';
import 'payment_page.dart';
import 'home_page.dart';
import 'product_grid.dart';
import 'about_us_page.dart';
import 'product_details_page.dart';
import 'order.dart';
import 'more_products_page.dart';
import 'gold_price_service.dart';
import 'twilio_service.dart';
import 'login_page.dart';
import 'add_product_page.dart';
import 'EditProductPage.dart';
import 'filtered_products_page.dart';

// إعدادات الإشعارات المحلية
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
);

// هاندلر الرسائل في الخلفية
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase مرة واحدة فقط، مع التعامل مع خطأ التهيئة المزدوجة
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      print("Firebase is already initialized, proceeding.");
    } else {
      print("Failed to initialize Firebase with error: ${e.code}");
    }
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon,
          ),
        ),
      );
    }
  });

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متجر الملك للمجوهرات',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      // تم إزالة `const` من المسارات هنا
      routes: {
        '/': (context) => HomePage(),
        '/cart': (context) => CartPage(),
        '/payment': (context) => PaymentPage(),
        '/aboutus': (context) => AboutUsPage(),
        '/products': (context) => ProductGrid(),
        '/productDetails': (context) => ProductDetailsPage(),
        '/moreProducts': (context) => MoreProductsPage(),
        '/filteredProducts': (context) => FilteredProductsPage(filterType: ''),
        '/add_product_page': (context) => AddProductPage(),
        '/edit_product_page': (context) => EditProductPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
