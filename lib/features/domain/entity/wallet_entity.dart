class WalletEntity {
  final String id;
  final String userId;
  final double balance;
  final DateTime lastUpdated;
  final List<Map<String, dynamic>>? transactions;

  WalletEntity({
    required this.id,
    required this.userId,
    required this.balance,
    required this.lastUpdated,
    this.transactions,
  });

  WalletEntity copyWith({
    String? id,
    String? userId,
    double? balance,
    DateTime? lastUpdated,
    List<Map<String, dynamic>>? transactions, // Add this line
  }) {
    return WalletEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      transactions: transactions ?? this.transactions, // Add this line
    );
  }
}
