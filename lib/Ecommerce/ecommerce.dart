import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apptest/Ecommerce/shopprofile.dart';

class EcommercePage extends StatefulWidget {
  final String selectedCity;

  const EcommercePage({Key? key, required this.selectedCity}) : super(key: key);

  @override
  _EcommercePageState createState() => _EcommercePageState();
}

class _EcommercePageState extends State<EcommercePage> {
  late String _selectedCity;
  late List<String?> _availableCities;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.selectedCity;
    _availableCities = [];
    _fetchAvailableCities();
  }

  Future<void> _fetchAvailableCities() async {
    var snapshot = await FirebaseFirestore.instance.collection('shops').get();
    var citiesSet = snapshot.docs.map((doc) => doc['city'] as String?).toSet();
    var cities = ['All', ...citiesSet.toList()];

    setState(() {
      _availableCities = cities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        backgroundColor: Color.fromARGB(255, 252, 230, 143),
        title: const Text('Shops Nearby', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
        automaticallyImplyLeading: false,
      ),
      body: _buildShopList(),
    );
  }

  Widget _buildShopList() {
    return StreamBuilder(
      stream: _selectedCity == 'All'
          ? FirebaseFirestore.instance.collection('shops').snapshots()
          : FirebaseFirestore.instance
              .collection('shops')
              .where('city', isEqualTo: _selectedCity)
              .snapshots(),
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
          shopsByCategory.putIfAbsent(category, () => []).add(shop);
        }

        if (shopsByCategory.isEmpty) {
          return Center(
            child: Text('No shops available for the selected city.'),
          );
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
                  child: Row(
                    children: [
                      SizedBox(height: 60,),
                      Text(
                        category,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 9,),
                      Text(">", style: TextStyle(fontSize: 20),)
                    ],
                  ),
                ),
                SizedBox(
                  height: 232.0, // Set the height as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryShops.length,
                    itemBuilder: (context, subIndex) {
                      var shop = categoryShops[subIndex];
                      return GestureDetector(
                        onTap: () {
                          _navigateToShopProfile(shop.id);
                        },
                        child: Container(
                          width: 160,
                          decoration: BoxDecoration(
                            boxShadow: [
      BoxShadow(
        color: Color.fromARGB(255, 157, 157, 157).withOpacity(0.1), // Shadow color
        spreadRadius: 2, // Spread radius
        blurRadius: 5, // Blur radius
        offset: Offset(3, 2), // Offset in x and y
      ),
    ],
                          ),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: Image.network(
                                    shop['imageUrl'],
                                    height: 100.0,
                                    width: 100.0, // Set the width as needed
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        shop['name'],
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text('${shop['description']}', style: TextStyle(fontSize: 11),),
                                      Text('${shop['mobileNumber']}'),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 4, 168, 53)),
                                        onPressed: () {
                                          _navigateToShopProfile(shop.id);
                                        },
                                        child: Icon(Icons.open_in_new, color: Colors.white,),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  void _navigateToShopProfile(String shopId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopProfilePage(shopId: shopId),
      ),
    );
  }
}
