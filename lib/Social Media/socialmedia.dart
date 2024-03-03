import 'dart:io';

import 'package:apptest/Social%20Media/wall_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(Socialmedia());
}

class Socialmedia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  late Reference _storageReference;
  late UploadTask _uploadTask;

  bool isCreatingPost = false;
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      toolbarHeight: 30,
        backgroundColor: Color.fromARGB(255, 220, 119, 119),
        title: Text('Local media of $selectedCity city', style: TextStyle(fontWeight: FontWeight.bold,),),
      ),
      body: isCreatingPost
          ? _buildCreatePostPage(context)
          : _buildSocialMediaPage(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isCreatingPost = !isCreatingPost;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSocialMediaPage(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("user post")
                  .where('City', isEqualTo: selectedCity)
                  .orderBy(
                    "TimeStamp",
                    descending: true,
                  )
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
        ],
      ),
    );
  }

  Widget _buildCreatePostPage(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            controller: textController,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Write your local updates.....',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (textController.text.isNotEmpty || _selectedImage != null) {
              String imageUrl = "";

              if (_selectedImage != null) {
                _storageReference = FirebaseStorage.instance
                    .ref()
                    .child('post_images/${DateTime.now().toIso8601String()}');
                _uploadTask = _storageReference.putFile(_selectedImage!);

                await _uploadTask.whenComplete(() async {
                  imageUrl = await _storageReference.getDownloadURL();
                });
              }

              await FirebaseFirestore.instance.collection("user post").add({
                'Usermail': currentUser?.email,
                'Message': textController.text,
                'ImageURL': imageUrl,
                'TimeStamp': Timestamp.now(),
                'City': selectedCity,
              });

              textController.clear();
              setState(() {
                _selectedImage = null;
                isCreatingPost = false;
              });

              Navigator.pop(context);
            }
          },
          child: Text('Post'),
        ),
        ElevatedButton(
          onPressed: () => _pickImageFromGallery(),
          child: Text('Image from Gallery'),
        ),
        ElevatedButton(
          onPressed: () => _pickImageFromCamera(),
          child: Text('Image from Camera'),
        ),
      ],
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserCity(); // Fetch user's city from Firestore
  }

  Future<void> _fetchUserCity() async {
    // Fetch the user's city from Firestore users collection based on user's UID
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();

    setState(() {
      selectedCity = userSnapshot['location'];
    });
  }
}
