import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/cart_item.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/domain/repository/order_repository.dart';
import 'package:petzy/features/domain/repository/product_repository.dart';
import 'package:petzy/features/domain/repository/profile_repository.dart';
import 'package:petzy/features/domain/usecase/create_order.dart';
import 'package:petzy/features/domain/usecase/get_profile.dart';
import 'package:petzy/features/domain/usecase/reduce_product_stock.dart';
import 'package:petzy/features/domain/usecase/update_order_status.dart';
import 'package:petzy/features/domain/usecase/deduct_money_usecase.dart';
import 'package:petzy/features/domain/usecase/get_wallet.dart';
import 'package:petzy/features/domain/repository/wallet_repository.dart';
import 'package:petzy/features/presentation/bloc/buy_now_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart' show CartBloc;
import 'package:petzy/features/presentation/bloc/cart_event.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';
import 'package:petzy/features/presentation/screens/buy_now/buy_now_screen.dart';
// ignore: unused_import
import 'package:petzy/features/presentation/screens/cart_screen/cart_screen.dart';
import 'package:petzy/features/presentation/widgets/dailogbox/cutom_dailog.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ProductActionButtons extends StatelessWidget {
  final ProductEntity product;

  const ProductActionButtons({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) {
        // ── Out of Stock ──
        if (product.quantity == 0) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: greyColor,
                foregroundColor: whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Out of Stock',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return Row(
          children: [
            // ── Buy Now ──
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider(
                            create:
                                (context) => BuyNowBloc(
                                  createOrderUseCase: CreateOrderUseCase(
                                    context.read<OrderRepository>(),
                                  ),
                                  updateOrderStatusUseCase:
                                      UpdateOrderStatusUseCase(
                                        context.read<OrderRepository>(),
                                      ),
                                  reduceProductStockUseCase:
                                      ReduceProductStockUseCase(
                                        context.read<ProductRepository>(),
                                      ),
                                  getProfileUseCase: GetProfileUseCase(
                                    context.read<ProfileRepository>(),
                                  ),
                                  deductMoneyUseCase: DeductMoneyUseCase(
                                    context.read<WalletRepository>(),
                                  ),
                                  getWalletUseCase: GetWalletUseCase(
                                    context.read<WalletRepository>(),
                                  ),
                                  razorpay: Razorpay(),
                                  firebaseAuth: FirebaseAuth.instance,
                                ),
                            child: BuyNowScreen(
                              product: product,
                              quantity: state.quantity,
                            ),
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // ── Add to Cart / Already in Cart ──
            Expanded(
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  // Determine if this product already exists in the cart
                  final bool isInCart =
                      cartState is CartLoaded &&
                      cartState.items.any((item) => item.id == product.id);

                  // ✅ Product IS in cart — show dialog on tap
                  if (isInCart) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        CustomCartOutcomeDialog.show(
                          context: context,
                          title: 'Already in Cart!',
                          message:
                              'This item is already in your cart. What would you like to do?',
                          iconData: Icons.shopping_cart_checkout,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: whiteColor,
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text(
                        'In Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  // 🛒 Product NOT in cart — normal Add to Cart
                  return ElevatedButton(
                    onPressed: () async {
                      final cartBloc = context.read<CartBloc>();
                      final currentCartState = cartBloc.state;

                      // Stock limit check
                      if (currentCartState is CartLoaded) {
                        final existingItem =
                            currentCartState.items
                                .where((item) => item.id == product.id)
                                .firstOrNull;

                        final currentCartQty = existingItem?.quantity ?? 0;
                        final totalQty = currentCartQty + state.quantity;

                        if (totalQty > product.quantity) {
                          final remainingStock =
                              product.quantity - currentCartQty;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                remainingStock <= 0
                                    ? 'Maximum quantity (${product.quantity}) already in cart.'
                                    : 'Only $remainingStock more can be added (Stock limit: ${product.quantity})',
                              ),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                      }

                      final cartItem = CartItem(
                        id: product.id,
                        name: product.name,
                        price: product.price.toDouble(),
                        quantity: state.quantity,
                        imageUrl:
                            product.imageUrls.isNotEmpty
                                ? product.imageUrls.first
                                : '',
                      );

                      cartBloc.add(AddCartItem(cartItem));

                      CustomCartOutcomeDialog.show(
                        context: context,
                        title: 'Added to Cart!',
                        message:
                            'Added ${state.quantity} × ${product.name} to cart!',
                        iconData: Icons.check_circle,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteColor,
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
