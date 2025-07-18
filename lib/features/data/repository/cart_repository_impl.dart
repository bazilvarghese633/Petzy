import 'package:petzy/features/data/data_source/cart_remote_data_source.dart';
import 'package:petzy/features/domain/entity/cart_item.dart';
import 'package:petzy/features/domain/repository/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> addToCart(CartItem item) {
    return remoteDataSource.addToCart(item);
  }

  @override
  Future<void> updateCartItemQuantity(String productId, int quantity) {
    return remoteDataSource.updateCartItemQuantity(productId, quantity);
  }

  @override
  Stream<List<CartItem>> getCartItems() {
    return remoteDataSource.getCartItems();
  }
}
