import 'package:apptest/Ecommerce/shopprofile.dart';
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



