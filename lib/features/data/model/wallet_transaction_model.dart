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

  //convert entity to Firestore map
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'amount': amount,
    'type': type.name, 
    'description': description,
    'createdAt': FieldValue.serverTimestamp(),
    if (orderId != null) 'orderId': orderId,
  };

//build model from a raw firesotre map and with document id
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
  
//build model directly from fb documentsnapshot
  factory WalletTransactionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletTransactionModel.fromMap(doc.id, data);
  }


//convert a plain wallettransation enity to wallettransaction model
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
