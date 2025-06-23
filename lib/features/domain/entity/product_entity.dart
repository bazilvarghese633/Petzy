class ProductEntity {
  final String id;
  final String name;
  final String? description;
  final String category;
  final int price;
  final int quantity;
  final String unit;
  final List<String> imageUrls;

  ProductEntity({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrls,
  });
}
