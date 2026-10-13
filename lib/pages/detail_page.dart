import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/coffee_item.dart';

class DetailPage extends StatefulWidget {
  final Function(CoffeeItem) onAddToCart;
  final Function(CoffeeItem) onAddToFav;

  const DetailPage({
    super.key,
    required this.onAddToCart,
    required this.onAddToFav,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<List<CoffeeItem>> _coffeeListFuture;
  List<CoffeeItem> _localCoffeeList = [];
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _coffeeListFuture = fetchCoffeeData();
  }

  Future<List<CoffeeItem>> fetchCoffeeData() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<String> sampleImages = [
          'https://images.unsplash.com/photo-1572442388796-11668a67e53d',
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd',
          'https://images.unsplash.com/photo-1541167760496-1628856ab772',
          'https://images.unsplash.com/photo-1534778101976-62847782c213',
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735',
        ];
        return List.generate(data.length, (index) {
          return CoffeeItem(
            id: data[index]['id'],
            name: index == 0 ? 'Cappuccino' : index == 1 ? 'Latte' : index == 2 ? 'Americano' : index == 3 ? 'Mocha' : 'Espresso',
            description: data[index]['title'],
            price: 120.0 + (index * 15),
            imageUrl: sampleImages[index % sampleImages.length],
          );
        });
      } else {
        throw Exception('Failed to load coffee items');
      }
    } catch (e) {
      return [
        CoffeeItem(id: 1, name: 'Cappuccino', description: 'Rich espresso with steamed milk foam.', price: 130.0, imageUrl: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d'),
        CoffeeItem(id: 2, name: 'Latte', description: 'Smooth espresso with plenty of milk.', price: 140.0, imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd'),
      ];
    }
  }

  // Dialog to Add a New Coffee Item (with Cancel option)
  void _showAddCoffeeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.brown[900],
          title: const Text('Add New Coffee', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Coffee Name',
                  labelStyle: TextStyle(color: Colors.amberAccent),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Price (PHP)',
                  labelStyle: TextStyle(color: Colors.amberAccent),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
                ),
              ),
            ],
          ),
          actions: [
            // CANCEL BUTTON
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            // ADD BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
              onPressed: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  final newCoffee = CoffeeItem(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: nameController.text,
                    description: 'Custom added coffee',
                    price: double.tryParse(priceController.text) ?? 100.0,
                    imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd',
                  );

                  setState(() {
                    _localCoffeeList.add(newCoffee);
                  });

                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${newCoffee.name} added to Menu!')),
                  );
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Delete Confirmation Dialog
  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.brown[900],
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to remove ${_localCoffeeList[index].name} from the list?', style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _localCoffeeList.removeAt(index);
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted successfully')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bean There Coffee - Menu List'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber[700],
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Add Coffee', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddCoffeeDialog(context),
      ),
      body: FutureBuilder<List<CoffeeItem>>(
        future: _coffeeListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_isLoaded) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (snapshot.hasError && !_isLoaded) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          if (!_isLoaded && snapshot.hasData) {
            _localCoffeeList = List.from(snapshot.data!);
            _isLoaded = true;
          }

          if (_localCoffeeList.isEmpty) {
            return const Center(
              child: Text('No coffee items available.', style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            itemCount: _localCoffeeList.length,
            itemBuilder: (context, index) {
              final coffee = _localCoffeeList[index];
              return Card(
                color: Colors.brown[800],
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      coffee.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.coffee, color: Colors.amber),
                    ),
                  ),
                  title: Text(coffee.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('PHP ${coffee.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amberAccent)),
                  trailing: SizedBox(
                    width: 135,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.amber, size: 20),
                          tooltip: 'Add to Favorites',
                          onPressed: () => widget.onAddToFav(coffee),
                        ),
                        IconButton(
                          icon: const Icon(Icons.shopping_cart, color: Colors.white70, size: 20),
                          tooltip: 'Add to Cart',
                          onPressed: () => widget.onAddToCart(coffee),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                          tooltip: 'Delete',
                          onPressed: () => _confirmDelete(context, index),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}