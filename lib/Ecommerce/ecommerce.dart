import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apptest/Ecommerce/shopprofile.dart';

class EcommercePage extends StatefulWidget {
  const EcommercePage({Key? key}) : super(key: key);

  @override
  _EcommercePageState createState() => _EcommercePageState();
}

class _EcommercePageState extends State<EcommercePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Shops'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('shops').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          var shops = snapshot.data?.docs ?? [];
          Map<String, List<DocumentSnapshot>> shopsByCategory = {};

          for (var shop in shops) {
            var category = shop['category'];
            if (!shopsByCategory.containsKey(category)) {
              shopsByCategory[category] = [];
            }
            shopsByCategory[category]!.add(shop);
          }

          return ListView.builder(
            itemCount: shopsByCategory.length,
            itemBuilder: (context, index) {
              var category = shopsByCategory.keys.elementAt(index);
              var categoryShops = shopsByCategory[category] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      category,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 190.0, // Set the height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryShops.length,
                      itemBuilder: (context, subIndex) {
                        var shop = categoryShops[subIndex];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShopProfilePage(shopId: shop.id),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.network(
                                  shop['imageUrl'],
                                  height: 100.0,
                                  width: 150.0, // Set the width as needed
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        shop['name'],
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text('${shop['description']}'),
                                      Text('${shop['mobileNumber']}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
