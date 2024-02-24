import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditShopProfilePage extends StatefulWidget {
  final String shopId;
  final String ownerUid;

  const EditShopProfilePage({
    Key? key,
    required this.shopId,
    required this.ownerUid,
  }) : super(key: key);

  @override
  _EditShopProfilePageState createState() => _EditShopProfilePageState();
}

class _EditShopProfilePageState extends State<EditShopProfilePage> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load the existing shop profile data when the page is initialized
    loadShopProfileData();
  }

  Future<void> loadShopProfileData() async {
    // Load the existing shop profile data from Firestore using widget.shopId
    // Set the data to the respective controllers
    try {
      DocumentSnapshot shopSnapshot =
          await FirebaseFirestore.instance.collection('shops').doc(widget.shopId).get();

      if (shopSnapshot.exists) {
        Map<String, dynamic> data = shopSnapshot.data() as Map<String, dynamic>;
        _shopNameController.text = data['name'] ?? '';
        _categoryController.text = data['category'] ?? '';
        _cityController.text = data['city'] ?? '';
        _mobileNumberController.text = data['mobileNumber'] ?? '';
        _imageUrlController.text = data['imageUrl'] ?? '';
      }
    } catch (e) {
      print('Error loading shop profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Shop Profile'),
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
                // Check if the current user is the owner of the shop
                String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
                if (currentUserUid == widget.ownerUid) {
                  // Current user is the owner, allow editing
                  _updateShopProfile();
                } else {
                  // Show an error message as the current user is not the owner
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('You are not the owner of this shop. Cannot edit.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Save Shop Profile'),
            ),
          ],
        ),
      ),
    );
  }

  

  void _updateShopProfile() async {
    // Validate inputs if needed

    // Update the shop profile in Firestore
    await FirebaseFirestore.instance.collection('shops').doc(widget.shopId).update({
      'name': _shopNameController.text,
      'city': _cityController.text,
      'mobileNumber': _mobileNumberController.text,
      'category' : _categoryController.text,
      'imageUrl' : _imageUrlController.text,
    });

    // Navigate back to the ShopProfilePage
    Navigator.pop(context);
  }
}
