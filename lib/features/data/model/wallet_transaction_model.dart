import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/domain/entity/wallet_transaction.dart';

class WalletTransactionModel extends WalletTransaction {
  WalletTransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.type,
    required super.description,
    super.orderId,
    required super.createdAt,
  });

  /// Convert entity → Firestore-ready map
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'amount': amount,
    'type': type.name, // stores 'credit' or 'debit' as string
    'description': description,
    'createdAt': FieldValue.serverTimestamp(),
    if (orderId != null) 'orderId': orderId,
  };

  /// Build model from a raw Firestore map + document id
  factory WalletTransactionModel.fromMap(String id, Map<String, dynamic> data) {
    return WalletTransactionModel(
      id: id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      type: TransactionType.values.byName(data['type'] ?? 'credit'),
      description: data['description'] ?? '',
      orderId: data['orderId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Build model directly from a Firestore DocumentSnapshot
  factory WalletTransactionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletTransactionModel.fromMap(doc.id, data);
  }

  /// Convert a plain WalletTransaction entity → WalletTransactionModel
  factory WalletTransactionModel.fromEntity(WalletTransaction entity) {
    return WalletTransactionModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      type: entity.type,
      description: entity.description,
      orderId: entity.orderId,
      createdAt: entity.createdAt,
    );
  }
}
