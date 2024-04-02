import 'package:apptest/Ecommerce/categoryshops.dart';
import 'package:apptest/servicess/Services/servicespage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apptest/Ecommerce/shopprofile.dart';
import 'package:apptest/Social%20Media/wall_post.dart';
import 'package:apptest/servicess/Services/servicedetails.dart';

class CategoryListPage extends StatefulWidget {
  @override
  _CategoryListPageState createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  String userCity = 'YourSelectedCitrry';

  @override
  void initState() {
    super.initState();
    fetchUserCity();
  }

  Future<void> fetchUserCity() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Fetch the user's city from Firestore users collection based on user's UID
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get();

    if (userDoc.exists) {
      setState(() {
        userCity = userDoc['location'] ?? 'nahh';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 139, 220, 142),
        toolbarHeight: 30,
        automaticallyImplyLeading: false,
        title: Text(userCity, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20,),
            Center(
              child: Text("Latest posts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("user post")
                    .orderBy("TimeStamp", descending: true)
                    .limit(2)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                     
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        final messages = post['Message'] as String? ?? '';
                        final user = post['Usermail'] as String? ?? '';

                        return WallPostWidget(
                          messages: messages,
                          user: user,
                          imageUrl: post['ImageURL'] ?? '', postId: '',
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Divider(
              color: Colors.black,
              height: 10.0,
              thickness: .5,
            ),
            SizedBox(height: 20,),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Shop Categories',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 10,),
            SingleChildScrollView(
            
              child: SizedBox(
                height: 250,
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return _buildCategoryItem(index);
                  },
                ),
              ),
            ),
            SizedBox(height: 36.0),
            Divider(
              color: Colors.black,
              height: 10.0,
              thickness: .5,
            ),
            SizedBox(height: 20,),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Find services nearby',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            FutureBuilder<List<ServiceCategoryModel>>(
              future: fetchServiceCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Center(child: Text('Error loading data.'));
                } else if (snapshot.data!.isEmpty) {
                  return Center(child: Text('No service categories available.'));
                } else {
                  var categories = snapshot.data!;
                  return SizedBox(
                    height: 200,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        mainAxisExtent: 220,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        var currentCategory = categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceCategoriesPage(selectedCity: '',),
                              ),
                            );
                          },
                          child: Card(
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15, left: 15),
                                    child: Image.network(
                                      currentCategory.image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    currentCategory.title,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    final categoryNames = ['Fruits', 'Grocery', 'Vegetables', 'Electronics', 'Clothing', 'Footwear'];
    final categoryImageUrls = [
      'https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/fruitspic.jpg',
      'https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/grocerypic.jpg',
      'https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/vegetabespic.jpg',
      'https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/gadgetspic.jpg',
      'https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/clothespic.jpg',
      'https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/footwearpic.jpg',
    ];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryShopListPage(category: categoryNames[index]),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(categoryImageUrls[index]),
            backgroundColor: Colors.blue,
            radius: 45.0,
          ),
          SizedBox(height: 8.0),
          Text(
            categoryNames[index],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<ServiceCategoryModel>> fetchServiceCategories() async {
    var categoriesSnapshot =
        await FirebaseFirestore.instance.collection('serviceCategories').get();

    return categoriesSnapshot.docs.map((doc) {
      var data = doc.data();
      return ServiceCategoryModel(
        title: data['title'] ?? "",
        image: data['image'] ?? "",
      );
    }).toList();
  }
}
