import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/domain/entity/wallet_entity.dart';
import 'package:petzy/features/domain/entity/wallet_transaction.dart';
import 'package:petzy/features/domain/repository/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  WalletRepositoryImpl({required this.firestore, required this.auth});

  @override
  Future<WalletEntity?> getWallet(String userId) async {
    try {
      final doc = await firestore.collection('wallets').doc(userId).get();

      if (!doc.exists) {
        await createWallet(userId);
        return WalletEntity(
          id: userId,
          userId: userId,
          balance: 0.0,
          lastUpdated: DateTime.now(),
          transactions: [], // Empty list for new wallet
        );
      }

      final data = doc.data()!;

      // Fetch transactions from subcollection
      final transactionsSnapshot =
          await firestore
              .collection('wallets')
              .doc(userId)
              .collection('transactions')
              .orderBy('createdAt', descending: true)
              .limit(10) // Get latest 10 transactions
              .get();

      // Convert transactions to List<Map<String, dynamic>>
      final transactions =
          transactionsSnapshot.docs.map((doc) {
            final transactionData = doc.data();
            return {
              'id': doc.id,
              'amount': transactionData['amount'],
              'type': transactionData['type'],
              'description': transactionData['description'],
              'orderId': transactionData['orderId'],
              'createdAt': (transactionData['createdAt'] as Timestamp).toDate(),
            };
          }).toList();

      return WalletEntity(
        id: doc.id,
        userId: data['userId'],
        balance: (data['balance'] as num).toDouble(),
        lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
        transactions: transactions, // Add transactions here
      );
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  @override
  Future<void> createWallet(String userId) async {
    try {
      await firestore.collection('wallets').doc(userId).set({
        'userId': userId,
        'balance': 0.0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  @override
  Future<void> addMoney(
    String userId,
    double amount,
    String description, {
    String? orderId,
  }) async {
    try {
      await firestore.runTransaction((transaction) async {
        // Update wallet balance
        final walletRef = firestore.collection('wallets').doc(userId);
        final walletDoc = await transaction.get(walletRef);

        final currentBalance =
            walletDoc.exists
                ? (walletDoc.data()!['balance'] as num).toDouble()
                : 0.0;

        transaction.set(walletRef, {
          'userId': userId,
          'balance': currentBalance + amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Add transaction record
        final transactionRef =
            firestore
                .collection('wallets')
                .doc(userId)
                .collection('transactions')
                .doc();

        transaction.set(transactionRef, {
          'id': transactionRef.id,
          'userId': userId,
          'amount': amount,
          'type': 'credit',
          'description': description,
          'orderId': orderId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to add money: $e');
    }
  }

  @override
  Future<void> deductMoney(
    String userId,
    double amount,
    String description, {
    String? orderId,
  }) async {
    try {
      await firestore.runTransaction((transaction) async {
        final walletRef = firestore.collection('wallets').doc(userId);
        final walletDoc = await transaction.get(walletRef);

        if (!walletDoc.exists) {
          throw Exception('Wallet not found');
        }

        final currentBalance = (walletDoc.data()!['balance'] as num).toDouble();

        if (currentBalance < amount) {
          throw Exception('Insufficient balance');
        }

        transaction.update(walletRef, {
          'balance': currentBalance - amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Add transaction record
        final transactionRef =
            firestore
                .collection('wallets')
                .doc(userId)
                .collection('transactions')
                .doc();

        transaction.set(transactionRef, {
          'id': transactionRef.id,
          'userId': userId,
          'amount': amount,
          'type': 'debit',
          'description': description,
          'orderId': orderId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to deduct money: $e');
    }
  }

  @override
  Future<List<WalletTransaction>> getTransactions(String userId) async {
    try {
      final snapshot =
          await firestore
              .collection('wallets')
              .doc(userId)
              .collection('transactions')
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return WalletTransaction(
          id: data['id'],
          userId: data['userId'],
          amount: (data['amount'] as num).toDouble(),
          type:
              data['type'] == 'credit'
                  ? TransactionType.credit
                  : TransactionType.debit,
          description: data['description'],
          orderId: data['orderId'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  @override
  Future<bool> hasEnoughBalance(String userId, double amount) async {
    try {
      final wallet = await getWallet(userId);
      return wallet != null && wallet.balance >= amount;
    } catch (e) {
      return false;
    }
  }
}
