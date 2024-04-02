import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopProfilePage extends StatefulWidget {
  final String shopId;

  const ShopProfilePage({Key? key, required this.shopId}) : super(key: key);

  @override
  _ShopProfilePageState createState() => _ShopProfilePageState();
}

class _ShopProfilePageState extends State<ShopProfilePage> {
  List<Map<String, dynamic>> cartItems = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Shop Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              _openCartDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            for (var item in cartItems)
              ListTile(
                title: Text(item['name'] ?? ''),
                subtitle: Text('Price: \$${item['price'] ?? ''}'),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _placeOrder();
                },
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('shops').doc(widget.shopId).snapshots(),
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
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(shopData?['imageUrl'] ?? ''),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Shop Name: ${shopData?['name']}',
                        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      Text('Category: ${shopData?['category']}'),
                      Text('Mobile Number: ${shopData?['mobileNumber']}'),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _launchPhoneCall(shopData?['mobileNumber']);
                              },
                              child: const Text('Call'),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _launchWhatsApp(shopData?['mobileNumber'], 'Hello from your customer!');
                              },
                              child: const Text('WhatsApp'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Products',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('products').where('shopId', isEqualTo: widget.shopId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                var products = (snapshot.data)?.docs ?? [];

                return GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8.0,
    mainAxisSpacing: 8.0,
    mainAxisExtent: 250,
  ),
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: products.length,
  itemBuilder: (context, index) {
    var productData = products[index].data();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10,),
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(productData['image'] ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productData['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),),
                Text(productData['description'] ?? ''),
                Text('Price: \$${productData['price'] ?? ''}'),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.green),
            width: 140,
            height: 40,
            
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _addToCart(productData);
                  },
                  child: Text("Add to cart",)),
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    _addToCart(productData);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
)
;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      cartItems.add({
        'name': product['name'],
        'price': product['price'],
      });
    });
  }

  void _placeOrder() {
    double totalPrice = 0;
    for (var item in cartItems) {
      totalPrice += (item['price'] ?? 0);
    }

    FirebaseFirestore.instance.collection('shops').doc(widget.shopId).get().then((shopSnapshot) {
      if (shopSnapshot.exists) {
        String whatsappNumber = shopSnapshot.data()?['mobileNumber'] ?? '';
        String orderMessage = 'Order Details:\n\n';
        for (var item in cartItems) {
          orderMessage += '${item['name']} - \$${item['price']}\n';
        }
        orderMessage += '\nTotal Price: \$${totalPrice.toStringAsFixed(2)}';

        _launchWhatsApp(whatsappNumber, orderMessage);
      }
    });
  }

  void _launchPhoneCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      String url = 'tel:$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch phone call.');
      }
    }
  }

  void _launchWhatsApp(String? phoneNumber, String message) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      String url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch WhatsApp.');
      }
    }
  }

  void _openCartDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }
}
