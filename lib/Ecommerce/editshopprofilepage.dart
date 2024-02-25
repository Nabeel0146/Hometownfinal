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
  final List<ProductEntry> _productEntries = [];

  @override
  void initState() {
    super.initState();
    // Load the existing shop profile data and products when the page is initialized
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
        _imageUrlController.text = data['imageUrl'] ?? '';
      }
    } catch (e) {
      print('Error loading shop profile data: $e');
    }
  }

  Future<void> loadProducts() async {
    try {
      QuerySnapshot productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('shopId', isEqualTo: widget.shopId)
          .get();

      List<ProductEntry> products = productsSnapshot.docs
          .map((doc) => ProductEntry.fromSnapshot(doc))
          .toList();

      setState(() {
        _productEntries.addAll(products);
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        
        onPressed: 
                 _addProductEntry,
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

  // Method to edit product details in a popup
  // Method to edit product details in a popup
void _editProductDetails(ProductEntry product) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: product._productNameController,
            decoration: const InputDecoration(labelText: 'Product Name'),
          ),
          TextField(
            controller: product._productPriceController,
            decoration: const InputDecoration(labelText: 'Product Price'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: product._productDescriptionController,
            decoration: const InputDecoration(labelText: 'Product Description'),
          ),
          TextField(
            controller: product._productImageController,
            decoration: const InputDecoration(labelText: 'Product Image URL'),
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
            // Save the edited product details directly to Firestore
            product.saveOrUpdateProduct(widget.shopId);
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
          TextField(
            controller: _productEntries.last._productImageController,
            decoration: const InputDecoration(labelText: 'Product Image URL'),
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
            // Save the new product details
            _productEntries.last.saveOrUpdateProduct(widget.shopId);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
//above is the pop up that ask the product detailsssssssss


  void _updateShopProfile() async {
    // Validate inputs if needed

    // Update the shop profile in Firestore
    await FirebaseFirestore.instance.collection('shops').doc(widget.shopId).update({
      'name': _shopNameController.text,
      'city': _cityController.text,
      'mobileNumber': _mobileNumberController.text,
      'category': _categoryController.text,
      'imageUrl': _imageUrlController.text,
    });

    // Save or update each product entry in Firestore
    for (var entry in _productEntries) {
      await entry.saveOrUpdateProduct(widget.shopId);
    }

    // Navigate back to the previous page
    Navigator.pop(context);
  }
}

class ProductEntry {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _productImageController = TextEditingController();

  // Default constructor
  ProductEntry();

  Widget buildProductEntry(BuildContext context) {
    return Column(
      children: [
        Image.network(
          _productImageController.text,
          width: 100, // Adjust the width as needed
          height: 100, // Adjust the height as needed
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

  Future<void> saveOrUpdateProduct(String shopId) async {
    try {
      // Validate inputs if needed

      // Add or update the product in the "products" collection in Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'name': _productNameController.text,
        'price': double.parse(_productPriceController.text),
        'description': _productDescriptionController.text,
        'image': _productImageController.text,
        'shopId': shopId,
      });
    } catch (e) {
      print('Error adding/updating product: $e');
    }
  }

  // Constructor to create ProductEntry from Firestore snapshot
  ProductEntry.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    _productNameController.text = data['name'] ?? '';
    _productPriceController.text = data['price'].toString() ?? '';
    _productDescriptionController.text = data['description'] ?? '';
    _productImageController.text = data['image'] ?? '';
  }

  String getName() => _productNameController.text;
  double getPrice() => double.parse(_productPriceController.text);
  String getImageUrl() => _productImageController.text;
}
