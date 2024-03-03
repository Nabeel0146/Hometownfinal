import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WallPostWidget extends StatefulWidget {
  final String messages;
  final String user;
  final String imageUrl;

  WallPostWidget({
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
            //image
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
}
