import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(String productName, double productPrice, String productImage,
      String productType, double productWeight) {
    // تحقق إذا المنتج موجود بالفعل في السلة
    int index = _cartItems.indexWhere((item) => item['name'] == productName);
    if (index != -1) {
      // زيادة الكمية فقط
      _cartItems[index]['quantity'] += 1;
    } else {
      _cartItems.add({
        'name': productName,
        'price': productPrice,
        'image': productImage,
        'type': productType,
        'weight': productWeight,
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _cartItems.length) {
      if (quantity > 0) {
        _cartItems[index]['quantity'] = quantity;
      } else {
        // إزالة العنصر إذا الكمية صفر أو أقل
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  double getTotalPrice() {
    double total = 0.0;
    for (var item in _cartItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
