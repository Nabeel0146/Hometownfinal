import 'package:apptest/Ecommerce/addshopprofilepage.dart';
import 'package:apptest/Ecommerce/editshopprofilepage.dart';
import 'package:apptest/profile/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('shops')
          .where('ownerUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 30,
              backgroundColor: Colors.yellow,
              automaticallyImplyLeading: false,
              title: const Text('Your Profile', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 30,
              backgroundColor: Colors.yellow,
              automaticallyImplyLeading: false,
              title: const Text('Your Profile', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return buildProfileScreen(context, snapshot.data);
        }
      },
    );
  }

  Widget buildProfileScreen(BuildContext context, QuerySnapshot? snapshot) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 30,
              backgroundColor: Colors.yellow,
              automaticallyImplyLeading: false,
              title: const Text('Your Profile', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (userSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 30,
              backgroundColor: Colors.yellow,
              automaticallyImplyLeading: false,
              title: const Text('Your Profile', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            ),
            body: Center(
              child: Text('Error: ${userSnapshot.error}'),
            ),
          );
        } else {
          String userName = userSnapshot.data?['name'] ?? 'User Name';
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 30,
              backgroundColor: Colors.yellow,
              automaticallyImplyLeading: false,
              title: const Text('Your Profile', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/placeholder_image.png'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      userName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Your city: ", style: TextStyle(fontSize: 16)),
                        Text(
                          userSnapshot.data?['location'] ?? 'Location',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => snapshot != null && snapshot.docs.isNotEmpty
                                ? EditShopProfilePage(
                                    shopId: snapshot.docs[0].id,
                                    ownerUid: FirebaseAuth.instance.currentUser?.uid ?? '',
                                  )
                                : AddShopProfilePage(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.work, color: Colors.black),
                          Padding(padding: EdgeInsets.only(left: 20)),
                          Text(snapshot != null && snapshot.docs.isNotEmpty
                              ? "Manage Your Business"
                              : "Become a Business User", style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                    const SizedBox(width: double.infinity),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(55.0),
                      )),
                      onPressed: () {
                        _showFeedbackPopup(context);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Icon(Icons.feedback, color: Colors.black),
                            Padding(padding: EdgeInsets.only(left: 20)),
                            const Text('Give Feedback', style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: double.infinity),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(55.0),
                      )),
                      onPressed: () {
                        _signOut(context);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.black),
                            Padding(padding: EdgeInsets.only(left: 20)),
                            const Text('Logout', style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("user post")
                          .where('Usermail', isEqualTo: FirebaseAuth.instance.currentUser?.email)
                          .orderBy("TimeStamp", descending: true)
                          .snapshots(),
                      builder: (context, postSnapshot) {
                        if (postSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (postSnapshot.hasError) {
                          return Center(child: Text('Error: ${postSnapshot.error}'));
                        } else if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No posts available'));
                        } else {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: postSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final post = postSnapshot.data!.docs[index];
                              final messages = post['Message'] as String? ?? '';
                              final user = post['Usermail'] as String? ?? '';

                              return WallPostWidget(
                                messages: messages,
                                user: user,
                                imageUrl: post['ImageURL'] ?? '',
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _showFeedbackPopup(BuildContext context) {
    String feedbackText = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Feedback"),
          content: TextField(
            onChanged: (value) {
              feedbackText = value;
            },
            decoration: InputDecoration(hintText: "Enter your feedback here"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _submitFeedback(context, feedbackText);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _submitFeedback(BuildContext context, String feedbackText) async {
    try {
      String userUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'userUid': userUid,
        'feedbackText': feedbackText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting feedback: $e');
    }
  }
}

class WallPostWidget extends StatelessWidget {
  final String messages;
  final String user;
  final String imageUrl;

  const WallPostWidget({
    Key? key,
    required this.messages,
    required this.user,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: $user'),
            if (imageUrl.isNotEmpty) Image.network(imageUrl),
            Text(messages),
          ],
        ),
      ),
    );
  }
}
