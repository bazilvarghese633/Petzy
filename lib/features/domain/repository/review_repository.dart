import 'package:petzy/features/domain/entity/review_entity.dart';
import 'package:petzy/features/domain/entity/product_rating.dart';

abstract class ReviewRepository {
  Future<String> createReview(ReviewEntity review);
  Future<List<ReviewEntity>> getProductReviews(String productId);
  Future<ProductRating> getProductRating(String productId);
  Future<bool> hasUserReviewedProduct(String userId, String productId);
  Future<void> updateReview(ReviewEntity review);
  Future<void> deleteReview(String reviewId);
}
