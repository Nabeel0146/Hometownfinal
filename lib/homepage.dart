import 'package:apptest/Ecommerce/ecommerce.dart';
import 'package:apptest/Social%20Media/socialmedia.dart';
import 'package:apptest/profile/profile_page.dart';
import 'package:apptest/servicess/service_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    
    ServicePage(),
    ECommercePage(),
    SocialMediaPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Pageeee'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items:  [
          
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.work),
            label: 'Service',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'E-commerce',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Social Media',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
