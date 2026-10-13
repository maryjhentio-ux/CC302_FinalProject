import 'package:flutter/material.dart';
import 'pages/main_screen.dart';

void main() {
  runApp(const BeanThereCoffeeApp());
}

class BeanThereCoffeeApp extends StatelessWidget {
  const BeanThereCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bean There Coffee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFF2C1E16), // Dark coffee theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E140E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}