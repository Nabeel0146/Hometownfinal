import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EcommercePage extends StatelessWidget {
  const EcommercePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecommerce'),
      ),
      body: StreamBuilder(
  stream: FirebaseFirestore.instance.collection('shops').snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    // Perform a null check before accessing docs
    var shops = snapshot.data?.docs ?? [];

    return ListView.builder(
      itemCount: shops.length,
      itemBuilder: (context, index) {
        var shop = shops[index];
        return ListTile(
          title: Text(shop['name']),
          subtitle: Text(shop['category']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopProfilePage(shopId: shop.id),
              ),
            );
          },
        );
      },
    );
  },
),

    );
  }
}


class ShopProfilePage extends StatelessWidget {
  final String shopId;

  const ShopProfilePage({Key? key, required this.shopId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Shop Information
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('shops').doc(shopId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // Perform a null check before accessing data
                var shop = snapshot.data as DocumentSnapshot<Map<String, dynamic>>?;
                if (shop == null || !shop.exists) {
                  return Text('Shop not found');
                }

                // Access shop data safely
                var shopData = shop.data();

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop Name: ${shopData?['name']}',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      Text('Category: ${shopData?['category']}'),
                      // Add other relevant shop information here
                    ],
                  ),
                );
              },
            ),

            // Display Products List
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Products',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),

            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('products').where('shopId', isEqualTo: shopId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // Perform a null check before accessing docs
                var products = (snapshot.data as QuerySnapshot<Map<String, dynamic>>?)?.docs ?? [];

                return Column(
                  children: products.map((product) {
                    var productData = product.data();
                    return ListTile(
                      title: Text(productData?['name'] ?? ''),
                      subtitle: Text(productData?['description'] ?? ''),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(productData?['image'] ?? ''),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(product: productData),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product?['name'] ?? 'Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${product?['name'] ?? ''}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Text('Description: ${product?['description'] ?? ''}'),
            Text('Price: \$${product?['price'] ?? ''}'),
            // Add other relevant product information here
          ],
        ),
      ),
    );
  }
}
