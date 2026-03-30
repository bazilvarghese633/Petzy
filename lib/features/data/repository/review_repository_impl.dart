import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/domain/entity/review_entity.dart';
import 'package:petzy/features/domain/entity/product_rating.dart';
import 'package:petzy/features/domain/repository/review_repository.dart';
import 'package:petzy/features/data/model/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ReviewRepositoryImpl({required this.firestore, required this.auth});

  @override
  Future<String> createReview(ReviewEntity review) async {
    try {
      final reviewData = ReviewModel.fromEntity(review).toMap();
      await firestore.collection('reviews').doc(review.id).set(reviewData);

      return review.id;
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  @override
  Future<List<ReviewEntity>> getProductReviews(String productId) async {
    try {
      final snapshot =
          await firestore
              .collection('reviews')
              .where('productId', isEqualTo: productId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => ReviewModel.fromDoc(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get reviews: $e');
    }
  }

  @override
  Future<ProductRating> getProductRating(String productId) async {
    try {
      final reviews = await getProductReviews(productId);

      if (reviews.isEmpty) {
        return ProductRating(
          productId: productId,
          averageRating: 0.0,
          totalReviews: 0,
          starDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        );
      }

      // Calculate average rating
      final totalRating = reviews.fold<int>(
        0,
        (sum, review) => sum + review.rating,
      );
      final averageRating = totalRating / reviews.length;

      // Calculate star distribution
      final Map<int, int> starDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      for (var review in reviews) {
        starDistribution[review.rating] =
            (starDistribution[review.rating] ?? 0) + 1;
      }

      return ProductRating(
        productId: productId,
        averageRating: averageRating,
        totalReviews: reviews.length,
        starDistribution: starDistribution,
      );
    } catch (e) {
      throw Exception('Failed to get product rating: $e');
    }
  }

  @override
  Future<bool> hasUserReviewedProduct(String userId, String productId) async {
    try {
      final snapshot =
          await firestore
              .collection('reviews')
              .where('userId', isEqualTo: userId)
              .where('productId', isEqualTo: productId)
              .limit(1)
              .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateReview(ReviewEntity review) async {
    try {
      await firestore.collection('reviews').doc(review.id).update({
        'rating': review.rating,
        'comment': review.comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}
