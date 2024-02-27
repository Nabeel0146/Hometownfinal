import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  final TextEditingController _shopDescriptionController = TextEditingController();
  final List<ProductEntry> _productEntries = [];

  @override
  void initState() {
    super.initState();
    loadShopProfileData();
    loadProducts();
  }

  Future<void> loadShopProfileData() async {
    try {
      DocumentSnapshot shopSnapshot =
          await FirebaseFirestore.instance.collection('shops').doc(widget.shopId).get();

      if (shopSnapshot.exists) {
        Map<String, dynamic> data = shopSnapshot.data() as Map<String, dynamic>;
        _shopNameController.text = data['name'] ?? '';
        _categoryController.text = data['category'] ?? '';
        _cityController.text = data['city'] ?? '';
        _mobileNumberController.text = data['mobileNumber'] ?? '';
        _shopDescriptionController.text = data['description'] ?? '';
      }
    } catch (e) {
      print('Error loading shop profile data: $e');
    }
  }

  Future<void> loadProducts() async {
    try {
      CollectionReference productsCollection =
          FirebaseFirestore.instance.collection('products');

      // Use snapshots() to get real-time updates
      productsCollection
          .where('shopId', isEqualTo: widget.shopId)
          .snapshots()
          .listen((QuerySnapshot productsSnapshot) {
        List<ProductEntry> products = productsSnapshot.docs
            .map((doc) => ProductEntry.fromSnapshot(doc))
            .toList();

        setState(() {
          _productEntries.clear();
          _productEntries.addAll(products);
        });
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: _addProductEntry,
        child: const Text('Add Product'),
      ),
      appBar: AppBar(
        title: const Text('Edit Shop Profile'),
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
                onPressed: () {
                  String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
                  if (currentUserUid == widget.ownerUid) {
                    _updateShopProfile();
                  } else {
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
              const SizedBox(height: 16.0),
              const Text(
                'Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _productEntries.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildProductGridItem(_productEntries[index]);
                },
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGridItem(ProductEntry product) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            product.getImageUrl(),
            width: double.infinity,
            height: 20.0,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.getName()),
                const SizedBox(height: 8.0),
                Text('\$${product.getPrice()}'),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () => _editProductDetails(product),
                  child: const Text('Edit'),
                ),
                const SizedBox(height: 30,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editProductDetails(ProductEntry product) {
    TextEditingController productNameController = TextEditingController();
    TextEditingController productPriceController = TextEditingController();
    TextEditingController productDescriptionController = TextEditingController();

    productNameController.text = product.getName();
    productPriceController.text = product.getPrice().toString();
    productDescriptionController.text = product.getDescription();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: productNameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: productPriceController,
              decoration: const InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: productDescriptionController,
              decoration: const InputDecoration(labelText: 'Product Description'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(product),
              child: const Text('Pick Image'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              product.setName(productNameController.text);
              product.setPrice(double.parse(productPriceController.text));
              product.setDescription(productDescriptionController.text);

              product.saveOrUpdateProduct(widget.shopId, productId: product.productId);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addProductEntry() {
    setState(() {
      _productEntries.add(ProductEntry());
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _productEntries.last._productNameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _productEntries.last._productPriceController,
              decoration: const InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _productEntries.last._productDescriptionController,
              decoration: const InputDecoration(labelText: 'Product Description'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(_productEntries.last),
              child: const Text('Pick Image'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _productEntries.last.saveOrUpdateProduct(widget.shopId);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ProductEntry product) async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    File imageFile = File(pickedFile.path);
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('product_images/$imageName.jpg');
    
    UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask.whenComplete(() async {
      String imageUrl = await storageReference.getDownloadURL();
      product.setImageUrl(imageUrl);
    });

    // Update UI to show the picked image
    setState(() {
      // Assuming you have a method in ProductEntry to set the image URL
      product.setImageUrl(product.getImageUrl());
    });
  } else {
    print('No image selected.');
  }
}


  void _updateShopProfile() async {
    await FirebaseFirestore.instance.collection('shops').doc(widget.shopId).update({
      'name': _shopNameController.text,
      'city': _cityController.text,
      'mobileNumber': _mobileNumberController.text,
      'category': _categoryController.text,
      'description': _shopDescriptionController.text,
    });

    for (var entry in _productEntries) {
      await entry.saveOrUpdateProduct(widget.shopId, productId: entry.productId);
    }

    Navigator.pop(context);
  }
}

class ProductEntry {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  String _imageUrl = '';
  String? productId;

  ProductEntry();

  Widget buildProductEntry(BuildContext context) {
    return Column(
      children: [
        Image.network(
          _imageUrl,
          width: 100,
          height: 100,
        ),
        TextField(
          controller: _productNameController,
          decoration: const InputDecoration(labelText: 'Product Name'),
        ),
        TextField(
          controller: _productPriceController,
          decoration: const InputDecoration(labelText: 'Product Price'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _productDescriptionController,
          decoration: const InputDecoration(labelText: 'Product Description'),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Future<void> saveOrUpdateProduct(String shopId, {String? productId}) async {
    try {
      Map<String, dynamic> productData = {
        'name': _productNameController.text,
        'price': double.parse(_productPriceController.text),
        'description': _productDescriptionController.text,
        'image': _imageUrl,
        'shopId': shopId,
      };

      if (productId != null) {
        await FirebaseFirestore.instance.collection('products').doc(productId).update(productData);
      } else {
        DocumentReference docRef = await FirebaseFirestore.instance.collection('products').add(productData);
        this.productId = docRef.id;
      }
    } catch (e) {
      print('Error adding/updating product: $e');
    }
  }

  ProductEntry.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    _productNameController.text = data['name'] ?? '';
    _productPriceController.text = data['price'].toString() ?? '';
    _productDescriptionController.text = data['description'] ?? '';
    _imageUrl = data['image'] ?? '';
    productId = snapshot.id;
  }

  String getName() => _productNameController.text;
  double getPrice() => double.parse(_productPriceController.text);
  String getDescription() => _productDescriptionController.text;
  String getImageUrl() => _imageUrl;

  void setName(String name) {
    _productNameController.text = name;
  }

  void setPrice(double price) {
    _productPriceController.text = price.toString();
  }

  void setDescription(String description) {
    _productDescriptionController.text = description;
  }

  void setImageUrl(String imageUrl) {
    _imageUrl = imageUrl;
  }
}
