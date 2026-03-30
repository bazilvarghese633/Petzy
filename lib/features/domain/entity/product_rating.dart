class ProductRating {
  final String productId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> starDistribution;

  ProductRating({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    required this.starDistribution,
  });
}
