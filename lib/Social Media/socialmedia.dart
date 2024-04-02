import 'dart:io';

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
  File? _selectedImage; // Declare _selectedImage

  // Add a variable to track which page to display
  bool isCreatingPost = false;

  // Add references for Firebase Storage
  late Reference _storageReference;
  late UploadTask _uploadTask;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Social Media App'),
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
                      final postId = post.id; // Get postId from document id

                      return WallPostWidget(
                        messages: messages,
                        user: user,
                        imageUrl: post['ImageURL'] ?? '',
                        postId: postId,
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
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text("Logged in as ${currentUser?.email ?? 'Unknown'}"),
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
            maxLines: null, // Allow unlimited lines
            decoration: InputDecoration(
              hintText: 'Write your local updates.....',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (textController.text.isNotEmpty || _selectedImage != null) {
              String imageUrl = "";

              // Upload image to Firebase Storage
              if (_selectedImage != null) {
                _storageReference = FirebaseStorage.instance
                    .ref()
                    .child('post_images/${DateTime.now().toIso8601String()}');
                _uploadTask = _storageReference.putFile(_selectedImage!);

                await _uploadTask.whenComplete(() async {
                  imageUrl = await _storageReference.getDownloadURL();
                });
              }

              // Generate a unique post ID
              String postId = FirebaseFirestore.instance.collection('user post').doc().id;

              await FirebaseFirestore.instance.collection("user post").doc(postId).set({
                'Usermail': currentUser?.email,
                'Message': textController.text,
                'ImageURL': imageUrl,
                'TimeStamp': Timestamp.now(),
              });

              // Clear the text field and selected image after posting
              textController.clear();
              setState(() {
                _selectedImage = null;
                isCreatingPost = false; // Close the create post page
              });

              // Navigate back to the social media page
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
}

class WallPostWidget extends StatefulWidget {
  final String postId; // Add postId
  final String messages;
  final String user;
  final String imageUrl;

  WallPostWidget({
    required this.postId,
    required this.messages,
    required this.user,
    required this.imageUrl,
  });

  @override
  _WallPostWidgetState createState() => _WallPostWidgetState();
}

class _WallPostWidgetState extends State<WallPostWidget> {
  int likeCount = 0; // Add a variable to track likes

  @override
  Widget build(BuildContext context) {
    return Card(
      // Adjust card properties as needed
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delete button
            if (widget.user == FirebaseAuth.instance.currentUser?.email)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Call a function to delete the post
                    _deletePost(widget.postId);
                  },
                ),
              ),
            
            // User profile
            Row(
              children: [
                CircleAvatar(
                  // Add logic to display the user's profile image
                  radius: 20,
                  // Placeholder for the user's profile image
                  child: Icon(Icons.account_circle, size: 40),
                ),
                SizedBox(width: 8),
                Text(widget.user),
              ],
            ),

            // Message Text
            Container(
              child: Text(
                widget.messages,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            // Image
            if (widget.imageUrl.isNotEmpty)
              Image.network(
                widget.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

            // Like button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () {
                    setState(() {
                      likeCount++;
                    });
                  },
                ),
                Text('$likeCount likes'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to delete the post
  void _deletePost(String postId) async {
    try {
      // Delete the post from Firestore
      await FirebaseFirestore.instance.collection('user post').doc(postId).delete();
      // Show a snackbar to indicate success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post deleted')));
    } catch (error) {
      // Show a snackbar to indicate error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete post')));
    }
  }
}
