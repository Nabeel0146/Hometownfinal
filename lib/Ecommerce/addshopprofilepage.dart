import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddShopProfilePage extends StatefulWidget {
  const AddShopProfilePage({Key? key}) : super(key: key);

  @override
  _AddShopProfilePageState createState() => _AddShopProfilePageState();
}

class _AddShopProfilePageState extends State<AddShopProfilePage> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _shopDescriptionController = TextEditingController();
  XFile? _pickedImage;

  // Product details controllers
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  XFile? _productImage;

  final List<Map<String, dynamic>> _productsList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Shop Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _mobileNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _shopDescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Shop Description'),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  await _pickImage();
                },
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 32.0),
        
              // Product entry fields
              TextField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _productDescriptionController,
                decoration: const InputDecoration(labelText: 'Product Description'),
              ),
              TextField(
                controller: _productPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Product Price'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await _pickProductImage();
                },
                child: const Text('Pick Product Image'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _addProduct();
                },
                child: const Text('Add Product'),
              ),
              const SizedBox(height: 32.0),
        
              // Display added products
              if (_productsList.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Added Products:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    // Display added products here
                    for (var product in _productsList)
                      ListTile(
                        title: Text(product['name']),
                        subtitle: Text(product['description']),
                        trailing: Text('\$${product['price']}'),
                      ),
                  ],
                ),
        
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  _addShopProfile();
                },
                child: const Text('Save Shop Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        _pickedImage = pickedImage;
        _imageUrlController.text = _pickedImage?.path ?? '';
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickProductImage() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        _productImage = pickedImage;
      });
    } catch (e) {
      print('Error picking product image: $e');
    }
  }

  void _addProduct() {
    String productName = _productNameController.text;
    String productDescription = _productDescriptionController.text;
    double productPrice = double.parse(_productPriceController.text);

    if (productName.isNotEmpty && productDescription.isNotEmpty) {
      _productsList.add({
        'name': productName,
        'description': productDescription,
        'price': productPrice,
        'image': _productImage?.path ?? '', // You may need to handle Firebase Storage upload for product image
      });

      // Clear the product entry fields
      _productNameController.clear();
      _productDescriptionController.clear();
      _productPriceController.clear();
      setState(() {
        _productImage = null;
      });
    }
  }

  void _addShopProfile() async {
    try {
      String shopId = generateShopId();
      String shopName = _shopNameController.text;
      String category = _categoryController.text;
      String city = _cityController.text;
      String mobileNumber = _mobileNumberController.text;
      String shopDescription = _shopDescriptionController.text;

      // Get the current user's UID
      String? ownerUid = FirebaseAuth.instance.currentUser?.uid;

      // Save the shop profile to Firestore
      await FirebaseFirestore.instance.collection('shops').doc(shopId).set({
        'name': shopName,
        'city': city,
        'mobileNumber': mobileNumber,
        'category': category,
        'ownerUid': ownerUid,
        'description': shopDescription, // Added description field
      });

      // Upload the shop image to Firebase Storage
      if (_pickedImage != null) {
        await _uploadImage(shopId, _pickedImage!.path);
      }

      // Add products to the 'products' collection
      for (var product in _productsList) {
        await _addProductToFirestore(shopId, product);
      }

      // Navigate back to the previous page (EcommercePage)
      Navigator.pop(context);
    } catch (e) {
      print('Error adding shop profile: $e');
    }
  }

  Future<void> _uploadImage(String shopId, String imagePath) async {
    try {
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('shop_images')
          .child('$shopId.jpg');

      await storageRef.putFile(File(imagePath));
      final imageUrl = await storageRef.getDownloadURL();

      // Save the shop image URL to Firestore
      await FirebaseFirestore.instance.collection('shops').doc(shopId).update({
        'imageUrl': imageUrl,
      });
    } catch (e) {
      print('Error uploading shop image: $e');
    }
  }

  Future<void> _addProductToFirestore(String shopId, Map<String, dynamic> product) async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': product['name'],
        'description': product['description'],
        'price': product['price'],
        'image': product['image'], // You may need to handle Firebase Storage upload for product image
        'shopId': shopId,
      });
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  String generateShopId() {
    var uuid = const Uuid();
    return uuid.v4();
  }
}
