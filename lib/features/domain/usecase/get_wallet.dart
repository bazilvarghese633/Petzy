// domain/usecase/get_wallet.dart
import 'package:petzy/features/domain/entity/wallet_entity.dart';
import 'package:petzy/features/domain/repository/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository repository;
  GetWalletUseCase(this.repository);

  Future<WalletEntity?> call(String userId) => repository.getWallet(userId);
}

class WalletPaymentUseCase {
  final WalletRepository repository;
  WalletPaymentUseCase(this.repository);

  Future<void> call(
    String userId,
    double amount,
    String description, {
    String? orderId,
  }) {
    return repository.deductMoney(
      userId,
      amount,
      description,
      orderId: orderId,
    );
  }
}
