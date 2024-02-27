import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubCategoryModel {
  final String name;
  final String image;
  final String description;
  final String number;

  SubCategoryModel(
    this.name,
    this.image,
    this.description,
    this.number,
  );
}

class ServiceDetailsPage extends StatelessWidget {
  final String mainCategoryId;
  final String categoryName;

  const ServiceDetailsPage({
    Key? key,
    required this.mainCategoryId,
    required this.categoryName,
  }) : super(key: key);

  Future<List<SubCategoryModel>> fetchSubcategories(
      String mainCategoryId) async {
    var subcategoriesSnapshot = await FirebaseFirestore.instance
        .collection('Servicedetails')
        .where('mainCategoryId', isEqualTo: mainCategoryId)
        .get();

    return subcategoriesSnapshot.docs.map((doc) {
      var data = doc.data();
      return SubCategoryModel(
        data['name'] ?? "",
        data['image'] ?? "",
        data['description'] ?? "",
        data['number'] ?? "",
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubCategoryModel>>(
      future: fetchSubcategories(mainCategoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(categoryName),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(categoryName),
            ),
            body: Center(child: Text('Error loading data.')),
          );
        } else if (snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(categoryName),
            ),
            body: Center(child: Text('No data available')),
          );
        } else {
          var subcategories = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(categoryName),
            ),
            body: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                var currentItem = subcategories[index];
                return ListTile(
                  title: Text(currentItem.name),
                  subtitle: Text(currentItem.description),
                  // Add more UI elements as needed
                );
              },
            ),
          );
        }
      },
    );
  }
}

