import 'package:flutter/material.dart';

import '../pages/main_screen.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/sample_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String coffeeList = '/coffee-list';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String cart = '/cart';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const MainScreen(),
    login: (context) => const HomePage(),
    coffeeList: (context) => const SamplePage(type: 'List'),
    profile: (context) => const ProfilePage(),
    favorites: (context) => const SamplePage(type: 'Favorites'),
    cart: (context) => const SamplePage(type: 'Cart'),
  };
}
