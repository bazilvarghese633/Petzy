import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/domain/entity/order_entity.dart';
import 'package:petzy/features/domain/repository/profile_repository.dart';
import 'package:petzy/features/domain/repository/review_repository.dart';
import 'package:petzy/features/presentation/bloc/order_cancel_bloc.dart';
import 'package:petzy/features/presentation/bloc/review_bloc.dart';
import 'package:petzy/features/presentation/screens/write_review/write_review_screen.dart';
import 'package:petzy/features/domain/usecase/create_review.dart';
import 'package:petzy/features/domain/usecase/get_product_reviews.dart';
import 'package:petzy/features/domain/usecase/get_product_rating.dart';
import 'package:petzy/features/domain/usecase/get_profile.dart';

class OrderActionButtons extends StatelessWidget {
  final OrderEntity order;

  const OrderActionButtons({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCancelBloc, OrderCancelState>(
      builder: (context, cancelState) {
        return Column(
          children: [
            // Write Review Button (for delivered orders)
            if (['completed', 'delivered'].contains(order.status.toLowerCase()))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToWriteReview(context, order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.star_rate),
                  label: const Text(
                    'Write Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            // Cancel Order Button with BLoC state management
            if (_canCancelOrder(order.status)) ...[
              if ([
                'completed',
                'delivered',
              ].contains(order.status.toLowerCase()))
                const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      cancelState is OrderCancelLoading
                          ? null
                          : () => _showCancelOrderDialog(context, order),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color:
                          cancelState is OrderCancelLoading
                              ? Colors.grey
                              : redColor,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon:
                      cancelState is OrderCancelLoading
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey,
                              ),
                            ),
                          )
                          : Icon(Icons.cancel_outlined, color: redColor),
                  label: Text(
                    cancelState is OrderCancelLoading
                        ? 'Cancelling...'
                        : 'Cancel Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          cancelState is OrderCancelLoading
                              ? Colors.grey
                              : redColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _navigateToWriteReview(BuildContext context, OrderEntity order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create:
                  (context) => ReviewBloc(
                    createReviewUseCase: CreateReviewUseCase(
                      context.read<ReviewRepository>(),
                    ),
                    getProductReviewsUseCase: GetProductReviewsUseCase(
                      context.read<ReviewRepository>(),
                    ),
                    getProductRatingUseCase: GetProductRatingUseCase(
                      context.read<ReviewRepository>(),
                    ),
                    getProfileUseCase: GetProfileUseCase(
                      context.read<ProfileRepository>(),
                    ),
                    firebaseAuth: FirebaseAuth.instance,
                  ),
              child: WriteReviewScreen(
                productId: order.product.id,
                orderId: order.id,
                productName: order.product.name,
              ),
            ),
      ),
    );
  }

  bool _canCancelOrder(String status) {
    final cancellableStatuses = ['pending', 'paid', 'accepted'];
    return cancellableStatuses.contains(status.toLowerCase());
  }

  void _showCancelOrderDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Cancel Order'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Are you sure you want to cancel this order?'),
                const SizedBox(height: 8),
                Text(
                  'Order: ${order.product.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Amount: ₹${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wallet, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Refund will be credited to your wallet instantly',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Keep Order', style: TextStyle(color: grey600)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<OrderCancelBloc>().add(
                    CancelOrderRequested(
                      orderId: order.id,
                      refundAmount: order.totalAmount,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  foregroundColor: whiteColor,
                ),
                child: const Text('Cancel Order'),
              ),
            ],
          ),
    );
  }
}
