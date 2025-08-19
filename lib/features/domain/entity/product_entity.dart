class ProductEntity {
  final String id;
  final String name;
  final String? description;
  final String category;
  final int price;
  final int quantity;
  final String unit;
  final List<String> imageUrls;

  final double averageRating;
  final int totalReviews;

  ProductEntity({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrls,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? price,
    int? quantity,
    String? unit,
    List<String>? imageUrls,
    double? averageRating,
    int? totalReviews,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageUrls: imageUrls ?? this.imageUrls,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  bool get hasReviews => totalReviews > 0;

  String get ratingText =>
      averageRating > 0
          ? '${averageRating.toStringAsFixed(1)} (${totalReviews} reviews)'
          : 'No reviews yet';
}
