class Product {
  final String productId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool availability;

  Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.availability,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      imageUrl: json['image_url'],
      availability: json['availability'] ?? true,
    );
  }
}

class Category {
  final String name;
  final String imageUrl;

  Category({required this.name, required this.imageUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
}
