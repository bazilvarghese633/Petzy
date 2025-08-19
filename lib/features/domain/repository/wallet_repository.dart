import 'package:petzy/features/domain/entity/wallet_entity.dart';
import 'package:petzy/features/domain/entity/wallet_transaction.dart';

abstract class WalletRepository {
  Future<WalletEntity?> getWallet(String userId);
  Future<void> createWallet(String userId);
  Future<void> addMoney(
    String userId,
    double amount,
    String description, {
    String? orderId,
  });
  Future<void> deductMoney(
    String userId,
    double amount,
    String description, {
    String? orderId,
  });
  Future<List<WalletTransaction>> getTransactions(String userId);
  Future<bool> hasEnoughBalance(String userId, double amount);
}
