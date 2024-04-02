

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(content: Text('Post deleted')));
    } catch (error) {
      // Show a snackbar to indicate error
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(content: Text('Failed to delete post')));
    }
  }
}
