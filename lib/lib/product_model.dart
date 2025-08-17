import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String type; // تم إضافة حقل النوع
  final double weight; // تم إضافة حقل الوزن

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.type, // مطلوب الآن
    required this.weight, // مطلوب الآن
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['image'] ?? 'https://via.placeholder.com/240', // تم تغيير 'imageUrl' إلى 'image' ليتوافق مع Firestore
      type: data['type'] ?? '', // قراءة حقل النوع من Firestore
      weight: (data['weight'] ?? 0.0).toDouble(), // قراءة حقل الوزن من Firestore
    );
  }
}
