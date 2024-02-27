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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Categories'),
      ),
      body: FutureBuilder<List<ServiceCategoryModel>>(
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
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var currentCategory = categories[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to the next page for listing services
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailsPage(
                          mainCategoryId: currentCategory.title,
                          categoryName: currentCategory.title,
                        ),
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
            );
          }
        },
      ),
    );
  }

  Future<List<ServiceCategoryModel>> fetchServiceCategories() async {
  var categoriesSnapshot = await FirebaseFirestore.instance
      .collection('serviceCategories')
      .get();

  return categoriesSnapshot.docs.map((doc) {
    var data = doc.data();
    return ServiceCategoryModel(
      title: data['title'] ?? "",
      image: data['image'] ?? "",
    );
  }).toList();
}

}

