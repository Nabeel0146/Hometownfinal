import 'package:apptest/servicess/Services/servicedetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';


class MainCategoryModel {
  final String id;
  final String name;
  final String image;

  MainCategoryModel(this.id, this.name, this.image);
}

class SubCategoryModel {
  final String name;
  final String image;
  final String description;
  final String number;
  final int orderNumber;

  SubCategoryModel(
      this.name, this.image, this.description, this.number, this.orderNumber);
}

class Servicespage extends StatelessWidget {
  const Servicespage({super.key, Key? key1});

  Future<String> fetchAdvertisementImage() async {
    var advertisementSnapshot = await FirebaseFirestore.instance
        .collection('bottomAd')
        .doc('ad1')
        .get();
    var data = advertisementSnapshot.data() as Map<String, dynamic>;
    return data['image'];
  }

  Future<List<MainCategoryModel>> fetchMainCategories() async {
    var mainCategoriesSnapshot =
        await FirebaseFirestore.instance.collection('Servicecategories').get();

    return mainCategoriesSnapshot.docs.map((doc) {
      var data = doc.data();
      return MainCategoryModel(doc.id, data['name'], data['image']);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MainCategoryModel>>(
      future: fetchMainCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Services',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: const Color.fromARGB(255, 74, 195, 139),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
                title: const Text('Services',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                backgroundColor: const Color.fromARGB(255, 74, 195, 139)),
            body: const Center(child: Text('Error loading data.')),
          );
        } else if (snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
                title: const Text('Services',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                backgroundColor: const Color.fromARGB(255, 74, 195, 139)),
            body: const Center(child: Text('No categories available.')),
          );
        } else {
          var mainCategories = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Services',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              backgroundColor: const Color.fromARGB(255, 74, 195, 139),
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemCount: mainCategories.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Servicedetailspage(
                            mainCategoryId: mainCategories[index].id,
                            categoryName: mainCategories[index].name,
                            advertisementImageUrl: fetchAdvertisementImage(),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(
                                    255, 230, 230, 230), // shadow color
                                offset: Offset(
                                    0, 3), // changes the position of the shadow
                                blurRadius:
                                    2, // changes the intensity of the shadow
                                spreadRadius:
                                    1, // changes the size of the shadow
                              ),
                            ]),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 25, right: 25),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, left: 10, right: 10),
                                child: CachedNetworkImage(
                                  imageUrl: mainCategories[index].image,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(
                                          strokeWidth: 0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white)),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                mainCategories[index].name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
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
            bottomNavigationBar: FutureBuilder<String>(
              future: fetchAdvertisementImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const BottomAppBar(
                    child: SizedBox.shrink(),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const BottomAppBar(
                    child: SizedBox.shrink(),
                  );
                } else {
                  var advertisementImageUrl = snapshot.data!;
                  return BottomAppBar(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CachedNetworkImage(
                        imageUrl: advertisementImageUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                          strokeWidth: 0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  );
                }
              },
            ),
          );
        }
      },
    );
  }
}
