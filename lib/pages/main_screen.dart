import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'detail_page.dart';
import 'profile_page.dart';
import '../models/coffee_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  List<CoffeeItem> _cartItems = [];
  List<CoffeeItem> _favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Load login state, saved tab, cart, and favorites from local storage
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // Load the last active tab index (default to 1 for List if logged in, 0 for Home if not)
    int savedTab = prefs.getInt('saved_tab_index') ?? 1;

    // Load Cart
    final String? savedCart = prefs.getString('saved_cart');
    if (savedCart != null) {
      List decodedCart = json.decode(savedCart);
      _cartItems = decodedCart.map((item) => CoffeeItem.fromJson(item)).toList();
    }

    // Load Favorites
    final String? savedFavs = prefs.getString('saved_favorites');
    if (savedFavs != null) {
      List decodedFavs = json.decode(savedFavs);
      _favoriteItems = decodedFavs.map((item) => CoffeeItem.fromJson(item)).toList();
    }

    setState(() {
      if (isLoggedIn) {
        _currentIndex = savedTab; // Restore the exact tab they were on!
      } else {
        _currentIndex = 0; // Home / Sign-In page
      }
      _isLoading = false;
    });
  }

  // Save Cart to local storage using toJson()
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    List encodedCart = _cartItems.map((coffee) => coffee.toJson()).toList();
    await prefs.setString('saved_cart', json.encode(encodedCart));
  }

  // Save Favorites to local storage using toJson()
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List encodedFavs = _favoriteItems.map((coffee) => coffee.toJson()).toList();
    await prefs.setString('saved_favorites', json.encode(encodedFavs));
  }

  Future<void> _handleSignInSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setInt('saved_tab_index', 1); // Set default tab to List upon sign-in
    setState(() {
      _currentIndex = 1;
    });
  }

  void _addToCart(CoffeeItem item) async {
    setState(() {
      _cartItems.add(item);
    });
    await _saveCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} added to Cart!')),
    );
  }

  void _addToFavorites(CoffeeItem item) async {
    setState(() {
      if (!_favoriteItems.any((fav) => fav.id == item.id)) {
        _favoriteItems.add(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} added to Favorites!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} is already in Favorites!')),
        );
      }
    });
    await _saveFavorites();
  }

  void _removeFromCart(int index) async {
    setState(() {
      _cartItems.removeAt(index);
    });
    await _saveCart();
  }

  void _removeFromFavorites(int index) async {
    setState(() {
      _favoriteItems.removeAt(index);
    });
    await _saveFavorites();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    final List<Widget> screens = [
      HomePage(
        onSignInSuccess: _handleSignInSuccess,
      ),
      DetailPage(
        onAddToCart: _addToCart,
        onAddToFav: _addToFavorites,
      ),
      const ProfilePage(),
      FavoritesScreen(
        favoriteItems: _favoriteItems,
        onRemove: _removeFromFavorites,
      ),
      CartScreen(
        cartItems: _cartItems,
        onRemove: _removeFromCart,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFFD4B28C),
        selectedItemColor: Colors.brown[900],
        unselectedItemColor: Colors.brown[700],
        type: BottomNavigationBarType.fixed,
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });
          // Save the current tab index so it stays remembered on refresh
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('saved_tab_index', index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Fav'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}

// Functional Favorites Screen
class FavoritesScreen extends StatelessWidget {
  final List<CoffeeItem> favoriteItems;
  final Function(int) onRemove;

  const FavoritesScreen({super.key, required this.favoriteItems, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favoriteItems.isEmpty
          ? const Center(
              child: Text(
                'No favorite coffee added yet.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final coffee = favoriteItems[index];
                return Card(
                  color: Colors.brown[800],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(coffee.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(coffee.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('PHP ${coffee.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amberAccent)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => onRemove(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Functional Cart Screen with Checkout
class CartScreen extends StatelessWidget {
  final List<CoffeeItem> cartItems;
  final Function(int) onRemove;

  const CartScreen({super.key, required this.cartItems, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your Cart is Empty',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final coffee = cartItems[index];
                      return Card(
                        color: Colors.brown[800],
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(coffee.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                          ),
                          title: Text(coffee.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text('PHP ${coffee.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amberAccent)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => onRemove(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.brown[900],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: PHP ${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order placed successfully!')),
                          );
                        },
                        child: const Text('Checkout', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}