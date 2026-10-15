import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  List<CoffeeItem> _localCoffeeList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoffeeData();
  }

  Future<void> _loadCoffeeData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedCoffees = prefs.getString('saved_coffee_list');

    if (savedCoffees != null) {
      List decodedData = json.decode(savedCoffees);
      setState(() {
        _localCoffeeList = decodedData.map((item) => CoffeeItem(
          id: item['id'],
          name: item['name'],
          description: item['description'],
          price: item['price'],
          imageUrl: item['imageUrl'],
        )).toList();
        _isLoading = false;
      });
    } else {
      await _fetchAndSaveInitialData();
    }
  }

  Future<void> _saveCoffeeData() async {
    final prefs = await SharedPreferences.getInstance();
    List encodedData = _localCoffeeList.map((coffee) => {
      'id': coffee.id,
      'name': coffee.name,
      'description': coffee.description,
      'price': coffee.price,
      'imageUrl': coffee.imageUrl,
    }).toList();
    await prefs.setString('saved_coffee_list', json.encode(encodedData));
  }

  Future<void> _fetchAndSaveInitialData() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
       List<String> sampleImages = [
  'https://images.unsplash.com/photo-1572442388796-11668a67e53d', // KapeBrown
  'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd', // CappeStick
  'https://images.unsplash.com/photo-1541167760496-1628856ab772', // Americano
  'https://images.unsplash.com/photo-1536256263959-770b48d82b0a', // Matcha Latte (Green Matcha Image)
  'https://images.unsplash.com/photo-1461023058943-07fcbe16d735', // EspessoCape
];
        setState(() {
          _localCoffeeList = List.generate(data.length, (index) {
            return CoffeeItem(
              id: data[index]['id'],
              name: index == 0 ? 'KapeBrown' : index == 1 ? 'CappeStick' : index == 2 ? 'Americano' : index == 3 ? 'Matcha Latte' : 'EspessoCape',
              description: data[index]['title'],
              price: 120.0 + (index * 15),
              imageUrl: sampleImages[index % sampleImages.length],
            );
          });
          _isLoading = false;
        });
        await _saveCoffeeData();
      }
    } catch (e) {
      setState(() {
        _localCoffeeList = [
          CoffeeItem(id: 1, name: 'Cappuccino', description: 'Rich espresso with steamed milk foam.', price: 130.0, imageUrl: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d'),
          CoffeeItem(id: 2, name: 'Latte', description: 'Smooth espresso with plenty of milk.', price: 140.0, imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd'),
        ];
        _isLoading = false;
      });
      await _saveCoffeeData();
    }
  }

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
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
              onPressed: () async {
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

                  await _saveCoffeeData();

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

  void _showEditCoffeeDialog(BuildContext context, int index) {
    final coffee = _localCoffeeList[index];
    final nameController = TextEditingController(text: coffee.name);
    final priceController = TextEditingController(text: coffee.price.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.brown[900],
          title: const Text('Edit Coffee', style: TextStyle(color: Colors.white)),
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
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
              onPressed: () async {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  setState(() {
                    _localCoffeeList[index] = CoffeeItem(
                      id: coffee.id,
                      name: nameController.text,
                      description: coffee.description,
                      price: double.tryParse(priceController.text) ?? coffee.price,
                      imageUrl: coffee.imageUrl,
                    );
                  });

                  await _saveCoffeeData();

                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${coffee.name} updated successfully!')),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

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
              onPressed: () async {
                setState(() {
                  _localCoffeeList.removeAt(index);
                });
                await _saveCoffeeData();

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _localCoffeeList.isEmpty
              ? const Center(
                  child: Text('No coffee items available.', style: TextStyle(color: Colors.white)),
                )
              : ListView.builder(
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
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
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.white70),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditCoffeeDialog(context, index);
                                } else if (value == 'delete') {
                                  _confirmDelete(context, index);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blueAccent),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}