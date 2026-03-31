import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzy/features/domain/entity/wallet_entity.dart';

class WalletModel extends WalletEntity {
  WalletModel({
    required super.id,
    required super.userId,
    required super.balance,
    required super.lastUpdated,
    super.transactions,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'balance': balance,
    'lastUpdated': FieldValue.serverTimestamp(),
  };

  factory WalletModel.fromMap(String id, Map<String, dynamic> data) {
    return WalletModel(
      id: id,
      userId: data['userId'] ?? '',
      balance: (data['balance'] as num? ?? 0).toDouble(),
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactions:
          data['transactions'] != null
              ? List<Map<String, dynamic>>.from(data['transactions'])
              : null,
    );
  }

  factory WalletModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel.fromMap(doc.id, data);
  }

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      id: entity.id,
      userId: entity.userId,
      balance: entity.balance,
      lastUpdated: entity.lastUpdated,
      transactions: entity.transactions,
    );
  }
}
