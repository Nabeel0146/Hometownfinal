import 'package:apptest/Ecommerce/ecommerce.dart';
import 'package:apptest/firebase_options.dart';
import 'package:apptest/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:apptest/Ecommerce/shopprofile.dart';
import 'package:apptest/Social%20Media/socialmedia.dart';
import 'package:apptest/profile/signuppage.dart';
import 'package:apptest/servicess/Services/servicespage.dart';
import 'package:apptest/Ecommerce/categoryshops.dart';
import 'package:apptest/profile/profile.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp()); // Remove 'const' from here
}

class MyApp extends StatelessWidget {
   MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Town',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignupPage(),
    );
  }
}







class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.userUid}) : super(key: key);
  final String userUid;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Example list of categories
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
          SocialMediaPage(),
          ServiceCategoriesPage(),
          CategoryListPage(), // Pass the categories here
          EcommercePage(),
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
