class ReviewEntity {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userEmail;
  final int rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;
  final String? orderId; // Optional: link to specific order

  ReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.orderId,
  });

  ReviewEntity copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userEmail,
    int? rating,
    String? comment,
    DateTime? createdAt,
    String? orderId,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
    );
  }
}
