enum TransactionType { credit, debit }

class WalletTransaction {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String description;
  final String? orderId;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    this.orderId,
    required this.createdAt,
  });
}
