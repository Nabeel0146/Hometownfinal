import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String selectedCity;

  const ServiceDetailsPage({
    Key? key,
    required this.mainCategoryId,
    required this.categoryName,
    required this.selectedCity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Servicedetails')
            .where('mainCategoryId', isEqualTo: mainCategoryId)
            .where('city', isEqualTo: selectedCity) // Filter by selected city
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            var subcategories = snapshot.data!.docs.map(
              (doc) {
                var data = doc.data() as Map<String, dynamic>;
                return SubCategoryModel(
                  data['name'] ?? "",
                  data['image'] ?? "",
                  data['description'] ?? "",
                  data['number'] ?? "",
                );
              },
            ).toList();

            return ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                var currentItem = subcategories[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(currentItem.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentItem.description),
                        SizedBox(height: 5),
                        Text('Mobile: ${currentItem.number}'),
                      ],
                    ),
                    leading: _buildLeadingWidget(currentItem.image),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.phone),
                          onPressed: () {
                            _makePhoneCall(currentItem.number);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.chat),
                          onPressed: () {
                            _openWhatsAppChat(currentItem.number);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            _shareServiceDetails(currentItem.name, currentItem.number);
                          },
                        ),
                      ],
                    ),
                    // Add more UI elements as needed
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddServiceProviderDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildLeadingWidget(String imageUrl) {
    return imageUrl.isNotEmpty
        ? Image.network(imageUrl)
        : CircleAvatar(
            backgroundColor: Colors.grey,
          );
  }

  void _showAddServiceProviderDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController numberController = TextEditingController();

    File? _image;

    _pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Service Provider'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _pickImage();
                },
                child: Text('Pick Image'),
              ),
              _image != null
                  ? Image.file(
                      _image!,
                      height: 100,
                      width: 100,
                    )
                  : SizedBox(),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: numberController,
                decoration: InputDecoration(labelText: 'Number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                saveServiceProviderData(nameController.text, descriptionController.text, numberController.text, _image);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void saveServiceProviderData(String name, String description, String number, File? image) async {
    String imageUrl = "";

    if (image != null) {
      // Upload image to Firebase Storage
      var storageRef = FirebaseStorage.instance.ref().child('service_images/${DateTime.now()}.png');
      await storageRef.putFile(image);
      imageUrl = await storageRef.getDownloadURL();
    }

    FirebaseFirestore.instance.collection('Servicedetails').add({
      'mainCategoryId': mainCategoryId,
      'name': name,
      'description': description,
      'number': number,
      'image': imageUrl,
      'city': selectedCity, // Add the selected city to the document
    });
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneCallUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneCallUri.toString())) {
      await launch(phoneCallUri.toString());
    } else {
      print('Could not launch $phoneCallUri');
    }
  }

  void _openWhatsAppChat(String phoneNumber) async {
    final Uri whatsappUri = Uri(
      scheme: 'whatsapp',
      path: 'send',
      queryParameters: {'phone': phoneNumber},
    );

    if (await canLaunch(whatsappUri.toString())) {
      await launch(whatsappUri.toString());
    } else {
      print('Could not launch $whatsappUri');
    }
  }

  void _shareServiceDetails(String serviceName, String phoneNumber) async {
    final String shareText = 'Check out the service: $serviceName\nContact: $phoneNumber';
    await Share.share(shareText);
  }
}
