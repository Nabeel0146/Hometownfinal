import 'package:apptest/Ecommerce/ecommerce.dart';
import 'package:apptest/Social%20Media/socialmedia.dart';
import 'package:apptest/homepage.dart';
import 'package:apptest/profile/profile_page.dart';
import 'package:apptest/servicess/service_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/service': (context) => ServicePage(),
        '/ecommerce': (context) => ECommercePage(),
        '/': (context) => const HomePage(),
        '/social_media': (context) => SocialMediaPage(),
        '/profile': (context) => ProfilePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
