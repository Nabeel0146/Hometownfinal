import 'package:apptest/Ecommerce/categoryshops.dart';
import 'package:apptest/servicess/Services/servicespage.dart';
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
  final List<String> predefinedCategories = [
    'Fruits',
    'Clothing',
    'Books',
    'Home Decor',
    'Sports',
    'Beauty',
  ];

  // Placeholder for the current user's city
  String userCity = 'YourSelectedCity';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 270, // Fixed height for Latest Posts section
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
                          imageUrl: post['ImageURL'] ?? '',
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
            Text(
              'Shop Categories',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 250, // Fixed height for New Categories section
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                itemCount: predefinedCategories.length,
                itemBuilder: (context, index) {
                  final category = predefinedCategories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CategoryShopListPage(category: category),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/$category.jpg'),
                          backgroundColor: Colors.blue,
                          radius: 30.0,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Find services nearby',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
                    height: 200, // Fixed height for Categories section
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  currentCategory.image,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  currentCategory.title,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
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
