import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'BackgroundWidget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class EditProductPage extends StatefulWidget {
  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late String productId;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  dynamic _newImage; // تغيير نوع المتغير ليتعامل مع File و Uint8List

  String? _selectedType;
  final List<String> _availableTypes = [
    'خواتم', 'ذبل', 'سحبات', 'أساور', 'عقد', 'حلق', 'بيبي', 'تعاليق', 'تشكيلة'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      productId = args['productId'];
      _loadProductData();
    });
  }

  Future<void> _loadProductData() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('products').doc(productId).get();

    setState(() {
      _nameController.text = doc['name'];
      _priceController.text = doc['price'].toString();
      _weightController.text = doc['weight'].toString();
      _imageUrl = doc['image'];
      _selectedType = doc['type'];
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _newImage = bytes;
        });
      } else {
        setState(() {
          _newImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String> _uploadImage() async {
    if (_newImage == null) {
      return _imageUrl ?? '';
    }

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef =
        FirebaseStorage.instance.ref().child('product_images/$fileName');

    if (kIsWeb) {
      UploadTask uploadTask = storageRef.putData(_newImage as Uint8List);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } else {
      UploadTask uploadTask = storageRef.putFile(_newImage as File);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    }
  }

  Future<void> _updateProduct() async {
    String name = _nameController.text;
    double price = double.parse(_priceController.text);
    String type = _selectedType ?? '';
    double weight = double.parse(_weightController.text);

    String imageUrl = await _uploadImage();

    await FirebaseFirestore.instance.collection('products').doc(productId).update({
      'name': name,
      'price': price,
      'type': type,
      'weight': weight,
      'image': imageUrl,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('تم تحديث المنتج بنجاح')));
    Navigator.pop(context);
  }

  Future<void> _deleteProduct() async {
    if (_imageUrl != null) {
      try {
        Reference storageRef = FirebaseStorage.instance.refFromURL(_imageUrl!);
        await storageRef.delete();
      } catch (e) {
        print("Error deleting image from storage: $e");
      }
    }

    await FirebaseFirestore.instance.collection('products').doc(productId).delete();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('تم حذف المنتج بنجاح')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: AppBar(title: Text('تحرير المنتج')),
          body: Center(child: CircularProgressIndicator()));
    }
    
    // تحديد عنوان URL للصورة على الويب
    final String webImageUrl =
        kIsWeb ? 'http://yourdomain.com/path/to/bk.png' : 'assets/bk.png';


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تحرير المنتج',
          style: TextStyle(color: Color(0xFF6A5096)),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Color(0xFF6A5096)),
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: BackgroundWidget(
        imageUrl: webImageUrl,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600), // تحديد أقصى عرض للويب
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'اسم المنتج',
                      labelStyle: TextStyle(color: Color(0xFF6A5096)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'السعر',
                      labelStyle: TextStyle(color: Color(0xFF6A5096)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'الوزن',
                      labelStyle: TextStyle(color: Color(0xFF6A5096)),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'نوع المنتج',
                      labelStyle: TextStyle(color: Color(0xFF6A5096)),
                    ),
                    items: _availableTypes.map<DropdownMenuItem<String>>((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: _newImage == null
                        ? _imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  _imageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(height: 200, color: Colors.grey[200])
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: kIsWeb
                                ? Image.memory(
                                    _newImage as Uint8List,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _newImage as File,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        'تحديث المنتج',
                        style: TextStyle(color: Color(0xFF6A5096)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}