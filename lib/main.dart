import 'package:apptest/homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

//hellooo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // hellooo
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       //hellooo hiindndndndndnd
       //dwjdiwdjiw
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
