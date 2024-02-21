import 'package:apptest/Ecommerce/ecommerce.dart';
import 'package:apptest/firebase_options.dart';
import 'package:apptest/homepage.dart';
import 'package:apptest/profile/profile.dart';
import 'package:apptest/servicess/Services/servicespage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



Future<void> main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Town',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(), //hiaded
    );
  }
}




class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
           Image.network("https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/hometownlogo.png", width: 35, height: 35,),
            const Text('Home Town', ),
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
              children: const [
                SocialMediaPage(),
                Servicespage(),
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
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            items: const [
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
  const SocialMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Social Media Content'),
    );
  }
}






