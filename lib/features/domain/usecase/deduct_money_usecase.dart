import 'package:petzy/features/domain/repository/wallet_repository.dart';

class DeductMoneyUseCase {
  final WalletRepository repository;

  DeductMoneyUseCase(this.repository);

  Future<void> call({
    required String userId,
    required double amount,
    required String description,
    String? orderId,
  }) async {
    return repository.deductMoney(
      userId,
      amount,
      description,
      orderId: orderId,
    );
  }
}
