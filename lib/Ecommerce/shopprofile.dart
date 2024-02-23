import 'package:apptest/Ecommerce/editshopprofilepage.dart';  
import 'package:apptest/Ecommerce/productdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShopProfilePage extends StatelessWidget {
  final String shopId;

  const ShopProfilePage({Key? key, required this.shopId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditShopProfilePage(shopId: shopId, ownerUid: ""),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('shops').doc(shopId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                var shop = snapshot.data;
                if (shop == null || !shop.exists) {
                  return const Text('Shop not found');
                }

                var shopData = shop.data();

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop Name: ${shopData?['name']}',
                        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      Text('Category: ${shopData?['category']}'),
                    ],
                  ),
                );
              },
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
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

                var products = (snapshot.data)?.docs ?? [];

                return Column(
                  children: products.map((product) {
                    var productData = product.data();
                    return ListTile(
                      title: Text(productData['name'] ?? ''),
                      subtitle: Text(productData['description'] ?? ''),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(productData['image'] ?? ''),
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
