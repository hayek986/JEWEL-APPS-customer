import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gold_price_service.dart';
import 'more_products_page.dart';
import 'package:provider/provider.dart';
import 'order.dart';
import 'cart_page.dart';
import 'payment_page.dart';
import 'product_details_page.dart';
import 'cart_model.dart';
import 'twilio_service.dart';
import 'add_product_page.dart';
import 'EditProductPage.dart';
import 'product_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController = ScrollController();
  late Timer _timer;
  List<Product> _carouselProducts = [];
  Map<String, double> _goldPrices = {};

  @override
  void initState() {
    super.initState();
    _loadCarouselProducts();
    _loadGoldPrices();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        double delta = 2.0;

        if (currentScroll + delta >= maxScroll) {
          _scrollController.jumpTo(0.0);
        } else {
          _scrollController.jumpTo(currentScroll + delta);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCarouselProducts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();
    List<Product> products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    setState(() {
      _carouselProducts = products;
    });
  }

  Future<void> _loadGoldPrices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedPrices = prefs.getString('goldPrices');

    if (cachedPrices != null) {
      Map<String, double> goldPrices = Map<String, double>.fromEntries(
        cachedPrices.split('|').map((entry) {
          var parts = entry.split(':');
          return MapEntry(parts[0], double.parse(parts[1]));
        }),
      );
      setState(() {
        _goldPrices = goldPrices;
      });
    } else {
      Map<String, double> goldPrices = await GoldPriceService.fetchGoldPrices();
      String pricesString = goldPrices.entries.map((e) => '${e.key}:${e.value}').join('|');
      await prefs.setString('goldPrices', pricesString);

      setState(() {
        _goldPrices = goldPrices;
      });
    }
  }

  void _closeApp() {
    if (kIsWeb) {
      Navigator.of(context).maybePop();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('متجر مجوهرات ',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.white)),
        backgroundColor: const Color(0xFF800080),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bk.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _carouselProducts.isNotEmpty
                ? SizedBox(
                    height: 180,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: _carouselProducts.length,
                      itemBuilder: (context, index) {
                        final product = _carouselProducts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/productDetails',
                                arguments: {
                                  'name': product.name,
                                  'price': product.price,
                                  'image': product.imageUrl,
                                  'type': product.type,
                                  'weight': product.weight,
                                },
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const CircularProgressIndicator(),
            const Spacer(),
            _buildButton(context, "المنتجات", Icons.shop, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MoreProductsPage()),
              );
            }),
            const SizedBox(height: 18),
            _buildButton(context, "السلة", Icons.shopping_cart, () {
              Navigator.pushNamed(context, "/cart");
            }),
            const SizedBox(height: 18),
            _buildButton(context, "الدفع", Icons.payment, () {
              Navigator.pushNamed(context, "/payment");
            }),
            const SizedBox(height: 18),
            _buildButton(context, "من نحن", Icons.info, () {
              Navigator.pushNamed(context, "/aboutus");
            }),
            const SizedBox(height: 18),
            // هنا تم إضافة الشرط لإخفاء الزر على الويب
            if (!kIsWeb)
              _buildButton(context, "إغلاق التطبيق", Icons.exit_to_app, () {
                _closeApp();
              }, isCloseButton: true),
            const Spacer(),
            _goldPrices.isNotEmpty
                ? Container(
                    color: const Color(0xFFF5F5DC),
                    height: 50,
                    child: Marquee(
                      text: _goldPrices.entries.map((entry) {
                        return '${entry.key}: ${entry.value.toStringAsFixed(2)} د.أ';
                      }).join('    |    '),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF800080),
                        fontWeight: FontWeight.bold,
                      ),
                      scrollAxis: Axis.horizontal,
                      blankSpace: 20.0,
                      velocity: 100.0,
                      pauseAfterRound: const Duration(seconds: 0),
                    ),
                  )
                : const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, IconData icon,
      VoidCallback onPressed,
      {bool isCloseButton = false}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 25, color: Colors.white),
      label: Text(label,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF800080),
        foregroundColor: Colors.white,
        minimumSize: const Size(200, 50),
      ),
    );
  }
}
