class ProductRating {
  final String productId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> starDistribution; // {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}

  ProductRating({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    required this.starDistribution,
  });
}
