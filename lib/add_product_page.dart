import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart'; // استيراد مكتبة photo_view
import 'package:photo_view/photo_view_gallery.dart'; // استيراد gallery لعرض الصور
import 'BackgroundWidget.dart'; // استيراد الملف الجديد

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedType = 'خواتم'; // القيمة الافتراضية للنوع
  final _weightController = TextEditingController(); // إضافة متحكم للوزن
  File? _image;
  final _formKey = GlobalKey<FormState>();

  // قائمة الأنواع المتاحة
  final List<String> _types = [
    'خواتم', 'ذبل', 'سحبات', 'أساور', 'عقد', 'حلق', 'بيبي', 'تعاليق', 'تشكيلة'
  ];

  // اختيار صورة من المعرض
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // رفع الصورة إلى Firebase Storage
  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    final storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = storageRef.putFile(_image!);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // إضافة المنتج إلى Firestore
  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      double price = double.parse(_priceController.text);
      String type = _selectedType; // استخدام النوع المحدد
      double weight = double.parse(_weightController.text); // الحصول على الوزن

      // رفع الصورة والحصول على رابطها
      String? imageUrl = await _uploadImage();

      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'price': price,
        'type': type, // إضافة النوع
        'weight': weight, // إضافة الوزن
        'image': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إضافة المنتج بنجاح')));
      Navigator.pop(context); // العودة بعد إضافة المنتج
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // التحقق إذا كان السحب من اليسار لليمين
        if (details.primaryDelta! > 0) {
          Navigator.pop(context); // العودة
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('إضافة منتج', style: TextStyle(color: Color(0xFF6A5096))), // لون الكتابة ذهبي
          backgroundColor: Color(0xFF4CAF50), // اللون الأخضر
          centerTitle: true,  // جعل العنوان في منتصف شريط التطبيق
        ),
        body: BackgroundWidget(  // استخدام BackgroundWidget لتغطية الخلفية
          child: SingleChildScrollView(  // تمكين التمرير في الصفحة
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _image == null
                          ? Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: Center(child: Text('اضغط لاختيار صورة')))
                          : ClipRRect(  // إضافة ClipRRect لتنعيم الحواف
                        borderRadius: BorderRadius.circular(15), // جعل الحواف دائرية
                        child: Container(
                          height: 200,
                          child: PhotoView(  // إضافة PhotoView لتمكين التكبير
                            imageProvider: FileImage(_image!),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'اسم المنتج'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال اسم المنتج';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'السعر'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال السعر';
                        }
                        return null;
                      },
                    ),
                    // استخدام Dropdown لانتقاء النوع
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(labelText: 'نوع المنتج'),
                      items: _types.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى اختيار نوع المنتج';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _weightController,  // إضافة حقل الوزن
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'وزن المنتج (بالجرام)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال وزن المنتج';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: _addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50), // خلفية زر أخضر
                        foregroundColor: Color(0xFF6A5096), // الكتابة باللون الذهبي
                      ),
                      child: Text('إضافة المنتج'),
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
