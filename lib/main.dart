import 'dart:async';
import 'package:apptest/Ecommerce/ecommerce.dart';
import 'package:apptest/Social%20Media/socialmedia.dart';
import 'package:apptest/firebase_options.dart';
import 'package:apptest/profile/profile.dart';
import 'package:apptest/servicess/Services/servicespage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:apptest/profile/signuppage.dart';
import 'package:apptest/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
      home: SplashScreen(), // Display SplashScreen initially
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 5 seconds and then navigate to the SignupPage
    Timer(
      Duration(seconds: 6),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignupPage()),
      ),
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 150),
          Image.network(
            "https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/hometownlogo.png",
            width: 100,
            height: 100,
          ),
          Text(
            "Welcome to your \n HOME TOWN APP",
            style: TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CircularProgressIndicator(),
          SizedBox(height: 180,),
          Expanded(
            child: Image.network(
              "https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/main%201.png",
             height: 100,
              fit: BoxFit.fitWidth,
            ),
          ),
        ],
      ),
    ),
  );
}

}

class MyHomePage extends StatefulWidget {
  final String userUid;
  final String selectedCity;

  MyHomePage({Key? key, required this.userUid, required this.selectedCity})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  List<String> categories = ['Electronics', 'Clothing', 'Books', 'Home Decor'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.network(
              "https://raw.githubusercontent.com/Nabeel0146/Hometown-project-images/main/hometownlogo.png",
              width: 35,
              height: 35,
            ),
            const SizedBox(width: 8),
            const Text('Home Town'),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          Socialmedia(),
          ServiceCategoriesPage(selectedCity: widget.selectedCity,),
          CategoryListPage(),
          EcommercePage(selectedCity: widget.selectedCity),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Services',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Ecommerce',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
