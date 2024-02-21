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
      body: Column(
        children: [
          // Display Shop Information
          StreamBuilder(
  stream: FirebaseFirestore.instance.collection('shops').doc(shopId).snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
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

    return Column(
      children: [
        // Display Shop Information
        Text('Shop Name: ${shopData?['name']}'),
        Text('Category: ${shopData?['category']}'),
        // Add other relevant shop information here
      ],
    );
  },
),

          // Display Products Grid
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

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        var product = products[index];
        return Card(
          child: Column(
            children: [
              Text(product['name']),
              Text('Price: ${product['price']}'),
              // Add other relevant product information here
            ],
          ),
        );
      },
    );
  },
),

        ],
      ),
    );
  }
}
