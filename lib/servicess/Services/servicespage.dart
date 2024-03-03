import 'package:apptest/servicess/Services/servicedetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceCategoryModel {
  final String title;
  final String image;

  ServiceCategoryModel({
    required this.title,
    required this.image,
  });
}

class ServiceCategoriesPage extends StatelessWidget {
  final String selectedCity;

  ServiceCategoriesPage({required this.selectedCity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Categories'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Container(
        color: Colors.grey[200], // Set the background color of the screen
        child: FutureBuilder<List<ServiceCategoryModel>>(
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
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
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
                          builder: (context) => ServiceDetailsPage(
                            mainCategoryId: currentCategory.title,
                            categoryName: currentCategory.title,
                            selectedCity: selectedCity, // Pass the selectedCity
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Container(
                        color: Colors.white, // Set the background color of the grid item
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
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
              );
            }
          },
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
