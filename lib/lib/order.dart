// order.dart
import 'package:flutter/material.dart';

class CustomOrder {
  String paymentMethod;
  String address;
  String phone;
  String visaNumber;
  String visaExpiry;
  String visaCVC;
  List<Map<String, String>> cartItems;
  double totalPrice;
  String customerName;
  String deviceId; // تم إضافة معرف الجهاز

  CustomOrder({
    required this.paymentMethod,
    required this.address,
    required this.phone,
    required this.visaNumber,
    required this.visaExpiry,
    required this.visaCVC,
    required this.cartItems,
    required this.totalPrice,
    required this.customerName,
    required this.deviceId, // تم إضافة معرف الجهاز إلى المنشئ
  });
}
