import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'BackgroundWidget.dart';
import 'more_products_page.dart';

class FilteredProductsPage extends StatelessWidget {
  final String filterType;

  FilteredProductsPage({required this.filterType});

  Stream<List<Map<String, dynamic>>> _getFilteredProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('type', isEqualTo: filterType)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'price': doc['price'],
          'image': doc['image'],
          'type': doc['type'],
          'weight': doc['weight'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String webImageUrl =
        kIsWeb ? 'http://yourdomain.com/path/to/bk.png' : 'assets/bk.png';

    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth > 900) {
      crossAxisCount = 4;
      childAspectRatio = 0.7;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.65;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.55;
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'منتجات $filterType',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color(0xFF800080),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context);
          }
        },
        child: BackgroundWidget(
          imageUrl: webImageUrl,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getFilteredProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد منتجات حالياً',
                        style: TextStyle(
                          color: const Color(0xFF800080),
                          fontSize: kIsWeb ? 24 : 18,
                        ),
                      ),
                    );
                  }

                  final products = snapshot.data!;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    padding: EdgeInsets.all(kIsWeb ? 20 : 10),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/productDetails',
                            arguments: {
                              'name': product['name'],
                              'price': product['price'],
                              'image': product['image'],
                              'type': product['type'],
                              'weight': product['weight'],
                            },
                          );
                        },
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Image.network(
                                    product['image'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: kIsWeb ? 18 : 14,
                                        color: const Color(0xFF800080),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'الوزن: ${product['weight']}',
                                      style: TextStyle(
                                        color: const Color(0xFF800080),
                                        fontWeight: FontWeight.w500,
                                        fontSize: kIsWeb ? 16 : 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'السعر: ${product['price']} د.أ',
                                      style: TextStyle(
                                        color: const Color(0xFF800080),
                                        fontWeight: FontWeight.w500,
                                        fontSize: kIsWeb ? 16 : 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
