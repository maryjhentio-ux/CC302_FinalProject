import 'package:flutter/material.dart';

class SamplePage extends StatefulWidget {
  final String type;

  const SamplePage({
    super.key,
    required this.type,
  });

  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  final List<Map<String, dynamic>> coffees = [
    {
      'name': 'Americano',
      'description': 'Original Taste',
      'price': 100.0,
      'icon': Icons.coffee,
      'favorite': true,
      'quantity': 0,
    },
    {
      'name': 'Americano',
      'description': 'Iced Coffee',
      'price': 120.0,
      'icon': Icons.local_cafe,
      'favorite': false,
      'quantity': 0,
    },
    {
      'name': 'Cappuccino',
      'description': 'with Oat Milk',
      'price': 150.0,
      'icon': Icons.coffee,
      'favorite': true,
      'quantity': 0,
    },
    {
      'name': 'Cappuccino',
      'description': 'with chocolate',
      'price': 180.0,
      'icon': Icons.local_cafe,
      'favorite': false,
      'quantity': 0,
    },
    {
      'name': 'Latte',
      'description': 'Creamy Coffee',
      'price': 120.0,
      'icon': Icons.coffee,
      'favorite': false,
      'quantity': 0,
    },
    {
      'name': 'Mocha',
      'description': 'Chocolate Coffee',
      'price': 160.0,
      'icon': Icons.local_cafe,
      'favorite': false,
      'quantity': 0,
    },
  ];

  double get total => coffees.fold(
        0.0,
        (sum, coffee) =>
            sum + coffee['price'] * coffee['quantity'],
      );

  @override
  Widget build(BuildContext context) {
    final isFavorites = widget.type == 'Favorites';
    final isCart = widget.type == 'Cart';
    final isList = widget.type == 'List';

    final items = coffees.where((coffee) {
      if (isFavorites) return coffee['favorite'] == true;
      if (isCart) return coffee['quantity'] > 0;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6EBDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF794727),
        foregroundColor: Colors.white,
        title: Text(
          isList
              ? "Mary Jhen's Coffee"
              : widget.type,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (isList)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: const Color(0xFF432715),
              child: const Column(
                children: [
                  Text(
                    'Buy one get one free',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose your favorite coffee',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          if (isList)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Cappuccino     Latte     Americano     Mocha',
                style: TextStyle(
                  color: Color(0xFF794727),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      isFavorites
                          ? 'No favorite coffees yet.'
                          : 'Your cart is empty.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : isCart || isFavorites
                    ? ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          ...items.map(
                            (coffee) => buildListItem(
                              coffee,
                              isCart,
                            ),
                          ),
                          if (isCart) ...[
                            const Divider(),
                            ListTile(
                              title: const Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                '₱${total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF794727),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: total == 0
                                    ? null
                                    : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Checkout demo. No payment was processed.',
                                            ),
                                          ),
                                        );
                                      },
                                child: const Text('Checkout'),
                              ),
                            ),
                          ],
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final coffee = items[index];
                          return buildCoffeeCard(coffee);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget buildCoffeeCard(Map<String, dynamic> coffee) {
    return Card(
      color: const Color(0xFFAD774A),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFE8D4BB),
              child: const Icon(
                Icons.coffee,
                size: 75,
                color: Color(0xFF794727),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Text(
              coffee['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              coffee['description'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₱${coffee['price'].toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          coffee['favorite'] = !coffee['favorite'];
                        });
                      },
                      icon: Icon(
                        coffee['favorite']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          coffee['quantity']++;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${coffee['name']} added to cart',
                            ),
                            duration: const Duration(milliseconds: 700),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFFFFC04D),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListItem(
    Map<String, dynamic> coffee,
    bool isCart,
  ) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8D4BB),
          child: Icon(
            Icons.coffee,
            color: Color(0xFF794727),
          ),
        ),
        title: Text(coffee['name']),
        subtitle: Text(
          '₱${coffee['price'].toStringAsFixed(0)}',
        ),
        trailing: isCart
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (coffee['quantity'] > 0) {
                          coffee['quantity']--;
                        }
                      });
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text('${coffee['quantity']}'),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        coffee['quantity']++;
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        coffee['quantity'] = 0;
                      });
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              )
            : IconButton(
                onPressed: () {
                  setState(() {
                    coffee['favorite'] = !coffee['favorite'];
                  });
                },
                icon: Icon(
                  coffee['favorite']
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
      ),
    );
  }
}
