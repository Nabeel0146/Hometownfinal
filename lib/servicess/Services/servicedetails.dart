import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Servicedetailspage extends StatelessWidget {
  final String mainCategoryId;
  final String categoryName;
  final Future<String> advertisementImageUrl;

  const Servicedetailspage({
    super.key,
    Key? key1,
    required this.mainCategoryId,
    required this.categoryName,
    required this.advertisementImageUrl,
  });

  void _showAddDataDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController numberController = TextEditingController();

    // Get the current date and time
    DateTime currentDateTime = DateTime.now();

    // Create a reference to the data entering alert dialog
    AlertDialog dataEnteringDialog;

    dataEnteringDialog = AlertDialog(
      title: const Text('വിവരങ്ങൾ ചേർക്കാം'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Place'),
          ),
          TextField(
            controller: numberController,
            decoration: const InputDecoration(labelText: 'Mobile Number'),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            String name = nameController.text;
            String description = descriptionController.text;
            String number = numberController.text;

            // Validate form fields (add more validation logic as needed)
            if (name.isEmpty || description.isEmpty || number.isEmpty) {
              // Show an error message if any field is empty
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All fields are required.'),
                ),
              );
            } else {
              // Close the data entering dialog
              Navigator.of(context).pop();

              // Save the data to Firebase
              await FirebaseFirestore.instance.collection('requests').add({
                'subcategoryName': categoryName, // Pass the subcategory name
                'name': name,
                'description': description,
                'number': number,
                'dateTime': currentDateTime
                    .toString(), // Add date and time to Firestore
                // Add more fields as needed
              });

              // Show a success message using another AlertDialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 40,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Request Submitted',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    content: const Text(
                      'നിങ്ങൾ രേഖപ്പെടുത്തിയ വിവരങ്ങൾ പരിശോധിച്ച ശേഷം ലിസ്റ്റിൽ ഉൾപ്പെടുത്തുന്നതായിരിക്കും',
                      style: TextStyle(),
                      textAlign: TextAlign.center,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          // Close the success message dialog
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );

    // Show the data entering dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dataEnteringDialog;
      },
    );
  }

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
                title: Text(categoryName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: const Color.fromARGB(255, 74, 195, 139)),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
                title: Text(categoryName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: const Color.fromARGB(255, 74, 195, 139)),
            body: const Center(child: Text('Error loading data.')),
          );
        } else if (snapshot.data!.isEmpty) {
          return Scaffold(
              appBar: AppBar(
                  title: Text(' $categoryName',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: const Color.fromARGB(255, 74, 195, 139)),
              body: const Center(child: Text('No data available')),
              floatingActionButton: FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text("വിവരങ്ങൾ ചേർക്കാം"),
                onPressed: () {
                  _showAddDataDialog(context);
                },
              ));
        } else {
          var subcategories = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
                title: Text(categoryName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: const Color.fromARGB(255, 74, 195, 139)),
            body: ListView.builder(
              itemCount:
                  subcategories.length + 1, // Add 1 for the additional SizedBox
              itemBuilder: (context, index) {
                if (index < subcategories.length) {
                  var currentItem = subcategories[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 230, 230, 230),
                            offset: Offset(0, 3),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: CachedNetworkImage(
                                imageUrl: currentItem.image,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "images/imageunavailable.jpeg",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  currentItem.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  currentItem.description,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 97, 97, 97)),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      currentItem.number,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          iconSize: 20,
                                          icon: const Icon(
                                            Icons.call,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          iconSize: 20,
                                          icon: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Image.asset(
                                                "images/whatsapplogo.png"),
                                          ),
                                          onPressed: () {
                                          },
                                        ),
                                        IconButton(
                                          iconSize: 20,
                                          icon: const Icon(
                                            Icons.share,
                                            color: Color.fromARGB(
                                                255, 104, 104, 104),
                                          ),
                                          onPressed: () {
                                            
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Add SizedBox after the last ListTile
                  return const SizedBox(height: 70); // Set your desired height
                }
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              label: const Text("വിവരങ്ങൾ ചേർക്കാം"),
              onPressed: () {
                _showAddDataDialog(context);
              },
              icon: const Icon(Icons.add),
            ),
            bottomNavigationBar: FutureBuilder<String>(
              future: advertisementImageUrl,
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
                          strokeWidth: 30,
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
