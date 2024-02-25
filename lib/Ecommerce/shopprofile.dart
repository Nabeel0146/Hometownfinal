import 'package:apptest/Ecommerce/editshopprofilepage.dart';
import 'package:apptest/Ecommerce/productdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              _navigateToEditShopProfile(context);
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

  void _navigateToEditShopProfile(BuildContext context) async {
    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the shop data
        DocumentSnapshot shopSnapshot = await FirebaseFirestore.instance.collection('shops').doc(shopId).get();

        if (shopSnapshot.exists) {
          Map<String, dynamic> shopData = shopSnapshot.data() as Map<String, dynamic>;
          String ownerUid = shopData['ownerUid'];

          // Check if the current user is the owner
          if (user.uid == ownerUid) {
            // Navigate to EditShopProfilePage with shopId and ownerUid
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditShopProfilePage(
                  shopId: shopId,
                  ownerUid: ownerUid,
                ),
              ),
            );
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
        }
      } else {
        // User is not logged in, handle accordingly (you might want to navigate to the login page)
        print('User is not logged in.');
      }
    } catch (e) {
      print('Error navigating to EditShopProfilePage: $e');
    }
  }
}
