import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/domain/entity/review_entity.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.userName,
    required super.userEmail,
    required super.rating,
    required super.comment,
    required super.createdAt,
    super.orderId,
  });

  /// Convert entity → Firestore-ready map
  Map<String, dynamic> toMap() => {
    'productId': productId,
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'rating': rating,
    'comment': comment,
    'createdAt': FieldValue.serverTimestamp(),
    if (orderId != null) 'orderId': orderId,
  };

  /// Build model from a raw Firestore map + document id
  factory ReviewModel.fromMap(String id, Map<String, dynamic> data) {
    return ReviewModel(
      id: id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      rating: (data['rating'] as num).toInt(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      orderId: data['orderId'],
    );
  }

  /// Build model directly from a Firestore DocumentSnapshot
  factory ReviewModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromMap(doc.id, data);
  }

  /// Convert a plain ReviewEntity → ReviewModel
  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      productId: entity.productId,
      userId: entity.userId,
      userName: entity.userName,
      userEmail: entity.userEmail,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt,
      orderId: entity.orderId,
    );
  }
}
