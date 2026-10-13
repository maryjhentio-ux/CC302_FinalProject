class CoffeeItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  CoffeeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory CoffeeItem.fromJson(Map<String, dynamic> json) {
    return CoffeeItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Coffee',
      description: json['description'] ?? 'Delicious brew',
      price: (json['price'] ?? 50.0).toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1509042239860-f550ce710b93',
    );
  }
}