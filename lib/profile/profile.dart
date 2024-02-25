import 'package:apptest/Ecommerce/addshopprofilepage.dart';
import 'package:apptest/Ecommerce/editshopprofilepage.dart';
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
              title: const Text('Profile'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          bool hasShops = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
          return buildProfileScreen(context, hasShops, snapshot.data);
        }
      },
    );
  }

  Widget buildProfileScreen(BuildContext context, bool hasShops, QuerySnapshot? snapshot) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditShopProfilePage(
                  shopId: snapshot?.docs[0].id ?? '',
                  ownerUid: FirebaseAuth.instance.currentUser?.uid ?? '',
                )),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/placeholder_image.png'),
            ),
            const SizedBox(height: 16),
            const Text(
              'User Name', // Replace with the user's name from Firebase
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Location', // Replace with the user's location from Firebase
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => hasShops
                        ? EditShopProfilePage(
                            shopId: snapshot?.docs[0].id ?? '',
                            ownerUid: FirebaseAuth.instance.currentUser?.uid ?? '',
                          )
                        : const AddShopProfilePage(),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.work),
                  const Padding(padding: EdgeInsets.only(left: 20)),
                  Text(hasShops ? "Manage Your Business" : "Become a Business User"),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
               },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}