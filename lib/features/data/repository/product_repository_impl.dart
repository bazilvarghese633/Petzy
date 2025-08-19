import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/domain/entity/product_rating.dart';
import 'package:petzy/features/domain/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore firestore;

  ProductRepositoryImpl(this.firestore);

  @override
  Future<List<ProductEntity>> fetchProducts() async {
    try {
      final snapshot = await firestore.collection('products').get();

      List<ProductEntity> products = [];

      // 🔥 Calculate rating for each product
      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Get rating data for this product
        final rating = await _getProductRating(doc.id);

        final product = ProductEntity(
          id: doc.id,
          name: data['name'],
          description: data['description'],
          category: data['category'],
          price: data['price'],
          quantity: data['quantity'],
          unit: data['unit'],
          imageUrls: List<String>.from(data['images'] ?? []),
          averageRating: rating.averageRating, // 👈 Include calculated rating
          totalReviews: rating.totalReviews, // 👈 Include review count
        );

        products.add(product);
      }

      return products;
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<List<String>> fetchCategories() async {
    final snapshot = await firestore.collection('categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  /// ✅ NEW: Fetch product by productId (also with ratings)
  @override
  Future<ProductEntity?> fetchProductById(String productId) async {
    try {
      final doc = await firestore.collection('products').doc(productId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;

      // 🔥 Get rating data for this specific product
      final rating = await _getProductRating(productId);

      return ProductEntity(
        id: doc.id,
        name: data['name'],
        description: data['description'],
        category: data['category'],
        price: data['price'],
        quantity: data['quantity'],
        unit: data['unit'],
        imageUrls: List<String>.from(data['images'] ?? []),
        averageRating: rating.averageRating, // 👈 Include calculated rating
        totalReviews: rating.totalReviews, // 👈 Include review count
      );
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  @override
  Future<void> reduceProductStock(
    String productId,
    int quantityPurchased,
  ) async {
    try {
      await firestore.runTransaction((transaction) async {
        final productRef = firestore.collection('products').doc(productId);
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) {
          throw Exception('Product not found');
        }

        final currentQuantity = (productDoc.data()!['quantity'] as num).toInt();
        final newQuantity = currentQuantity - quantityPurchased;

        if (newQuantity < 0) {
          throw Exception('Insufficient stock');
        }

        transaction.update(productRef, {'quantity': newQuantity});
      });
    } catch (e) {
      throw Exception('Failed to update product stock: $e');
    }
  }

  // In ProductRepositoryImpl
  @override
  Future<void> increaseProductStock(String productId, int quantity) async {
    try {
      await firestore.runTransaction((transaction) async {
        final productRef = firestore.collection('products').doc(productId);
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) {
          throw Exception('Product not found');
        }

        final currentQuantity = (productDoc.data()!['quantity'] as num).toInt();
        final newQuantity = currentQuantity + quantity;

        transaction.update(productRef, {
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to increase product stock: $e');
    }
  }

  @override
  Future<void> decreaseProductStock(String productId, int quantity) async {
    try {
      await firestore.runTransaction((transaction) async {
        final productRef = firestore.collection('products').doc(productId);
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) {
          throw Exception('Product not found');
        }

        final currentQuantity = (productDoc.data()!['quantity'] as num).toInt();
        final newQuantity = currentQuantity - quantity;

        if (newQuantity < 0) {
          throw Exception('Insufficient stock');
        }

        transaction.update(productRef, {
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to decrease product stock: $e');
    }
  }

  // 🔥 NEW: Helper method to calculate product ratings
  Future<ProductRating> _getProductRating(String productId) async {
    try {
      final reviewsSnapshot =
          await firestore
              .collection('reviews')
              .where('productId', isEqualTo: productId)
              .get();

      if (reviewsSnapshot.docs.isEmpty) {
        return ProductRating(
          productId: productId,
          averageRating: 0.0,
          totalReviews: 0,
          starDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        );
      }

      // Calculate average rating
      final reviews = reviewsSnapshot.docs;
      final totalRating = reviews.fold<int>(
        0,
        (sum, doc) => sum + (doc.data()['rating'] as int),
      );

      final averageRating = totalRating / reviews.length;

      // Calculate star distribution (optional but useful)
      final Map<int, int> starDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      for (var doc in reviews) {
        final rating = doc.data()['rating'] as int;
        starDistribution[rating] = (starDistribution[rating] ?? 0) + 1;
      }

      return ProductRating(
        productId: productId,
        averageRating: averageRating,
        totalReviews: reviews.length,
        starDistribution: starDistribution,
      );
    } catch (e) {
      print('Error calculating rating for product $productId: $e');
      // Return default rating if error
      return ProductRating(
        productId: productId,
        averageRating: 0.0,
        totalReviews: 0,
        starDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );
    }
  }
}
