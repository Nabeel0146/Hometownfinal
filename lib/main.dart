import 'package:apptest/Ecommerce/ecommerce.dart';
import 'package:apptest/homepage.dart';
import 'package:apptest/profile/profile.dart';
import 'package:apptest/servicess/services.dart';
import 'package:flutter/material.dart';
import 'package:apptest/Social%20Media/socialmedia.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Town',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}




class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("lib/images/hometownlogo.png",width: 35,height: 35, ),
            
            Text('Home Town', ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                SocialMediaPage(),
                ServicesPage(),
                HomePage(),
                EcommercePage(),
                ProfilePage(),
              ],
            ),
          ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Social Media',
                backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.build),
                label: 'Services',
                backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
                backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Ecommerce',
                backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
                backgroundColor: Colors.black
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SocialMediaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Social Media Content'),
    );
  }
}

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Services Content'),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Content'),
    );
  }
}

class EcommercePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Ecommerce Content'),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Content'),
    );
  }
}
