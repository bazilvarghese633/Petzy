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
import 'package:petzy/features/presentation/bloc/buy_now_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart' show CartBloc;
import 'package:petzy/features/presentation/bloc/cart_event.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';
import 'package:petzy/features/presentation/screens/buy_now/buy_now_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ProductActionButtons extends StatelessWidget {
  final ProductEntity product;

  const ProductActionButtons({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) {
        if (product.quantity == 0) {
          // Out of stock button
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
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Buy Now screen
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
                                  razorpay: Razorpay(),
                                  firebaseAuth: FirebaseAuth.instance,
                                ),
                            child: BuyNowScreen(
                              product: product,
                              quantity:
                                  state
                                      .quantity, // This gets the selected quantity
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
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // NEW: Check current cart before adding
                  final cartBloc = context.read<CartBloc>();
                  final currentState = cartBloc.state;

                  if (currentState is CartLoaded) {
                    // Find if product already exists in cart
                    final existingItem =
                        currentState.items
                            .where((item) => item.id == product.id)
                            .firstOrNull;

                    final currentCartQuantity = existingItem?.quantity ?? 0;
                    final requestedQuantity = state.quantity;
                    final totalQuantity =
                        currentCartQuantity + requestedQuantity;

                    // NEW: Check if adding would exceed stock
                    if (totalQuantity > product.quantity) {
                      final remainingStock =
                          product.quantity - currentCartQuantity;

                      if (remainingStock <= 0) {
                        // Already have max in cart
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You already have the maximum quantity (${product.quantity}) in your cart.',
                            ),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        // Can add some, but not the full requested amount
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Only $remainingStock more can be added to cart (Stock limit: ${product.quantity})',
                            ),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      return; // Don't add to cart
                    }
                  }

                  // Original code - only runs if under stock limit
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

                  // Dispatch AddCartItem event to CartBloc
                  cartBloc.add(AddCartItem(cartItem));

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added ${state.quantity} ${product.name} to cart!',
                      ),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                    ),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
