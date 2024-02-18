import 'package:apptest/homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

//hellooo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // helloooiiiii
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo222',
      theme: ThemeData(
        //hellooo hiindndndndndnd
        //vannkkkkkk
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Homepage(),
    );
  }
}


