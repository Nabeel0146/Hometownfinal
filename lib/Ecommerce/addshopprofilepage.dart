import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Add this import statement
import 'package:uuid/uuid.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Shop Profile'),
      ),
      body: Padding(
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
            const SizedBox(height: 32.0),
            TextField(
              controller: _imageUrlController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Image URL'),
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
    );
  }

  void _addShopProfile() async {
    String shopId = generateShopId();  // Generate a unique shopId
    String shopName = _shopNameController.text;
    String category = _categoryController.text;
    String city = _cityController.text;
    String mobileNumber = _mobileNumberController.text;
    String imageUrl = _imageUrlController.text;
    
    // Get the current user's UID
    String? ownerUid = FirebaseAuth.instance.currentUser?.uid;

    // Validate inputs (you can add more sophisticated validation as needed)

    // Save the shop profile to Firestore
    await FirebaseFirestore.instance.collection('shops').doc(shopId).set({
      'name': shopName,
      'city': city,
      'mobileNumber': mobileNumber,
      'category': category,
      'imageUrl': imageUrl,
      'ownerUid': ownerUid,  // Associate the owner's UID with the shop profile
      // You can add more fields here as needed
    });

    // Navigate back to the previous page (EcommercePage)
    Navigator.pop(context);
  }

  // Generate a unique shopId using the uuid package
  String generateShopId() {
    var uuid = const Uuid();
    return uuid.v4();
  }
}
