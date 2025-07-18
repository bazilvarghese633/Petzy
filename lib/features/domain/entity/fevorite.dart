class Favorite {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;

  Favorite({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      productId: map['productId'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      price: map['price'].toDouble(),
    );
  }
}
