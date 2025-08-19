import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/domain/repository/profile_repository.dart';
import 'package:petzy/features/domain/repository/review_repository.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';
import 'package:petzy/features/presentation/bloc/review_bloc.dart';
import 'package:petzy/features/presentation/screens/product_details/widgets/product_details_appbar.dart';
import 'package:petzy/features/presentation/screens/product_details/widgets/product_image_carousel.dart';
import 'package:petzy/features/presentation/screens/product_details/widgets/product_stock_and_category.dart';
import 'package:petzy/features/presentation/screens/product_details/widgets/product_quantity_and_price.dart';
import 'package:petzy/features/presentation/screens/product_details/widgets/product_action_buttons.dart';
import 'package:petzy/features/presentation/screens/write_review/product_review_screen.dart';
import 'package:petzy/features/presentation/widgets/star_rating.dart';
import 'package:petzy/features/domain/usecase/create_review.dart';
import 'package:petzy/features/domain/usecase/get_product_reviews.dart';
import 'package:petzy/features/domain/usecase/get_product_rating.dart';
import 'package:petzy/features/domain/usecase/get_profile.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    if (widget.product.imageUrls.length <= 1) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final bloc = context.read<ProductDetailBloc>();
      final currentIndex = bloc.state.currentPage;
      final nextIndex = (currentIndex + 1) % widget.product.imageUrls.length;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        bloc.add(UpdatePageIndex(nextIndex));
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: ProductAppBar(product: product),
      body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: brownColr,
                ),
              ),
              const SizedBox(height: 4),
              if (product.description != null)
                Text(
                  product.description!,
                  style: const TextStyle(fontSize: 14, color: greyColor),
                ),

              // 🔥 ADD: Rating display right below product name
              _buildProductRating(product),
              sizedBoxH12,

              ProductImageCarousel(
                imageUrls: product.imageUrls,
                pageController: _pageController,
              ),
              sizedBoxH16,

              ProductStockAndCategory(product: product),
              sizedBoxH20,

              ProductQuantityAndPrice(
                product: product,
                quantity: state.quantity,
              ),
              sizedBoxH24,

              ProductActionButtons(product: product),
              sizedBoxH32,

              // 🔥 ADD: Reviews section
              _buildReviewsSection(product),
            ],
          );
        },
      ),
    );
  }

  // 🔥 NEW: Product rating display
  Widget _buildProductRating(ProductEntity product) {
    // Check if product has rating data
    final hasRatings = product.totalReviews > 0;

    if (!hasRatings) {
      return const SizedBox(height: 8);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          StarRating(
            rating: product.averageRating,
            size: 18,
            showRating: false,
          ),
          const SizedBox(width: 8),
          Text(
            '${product.averageRating.toStringAsFixed(1)} (${product.totalReviews} reviews)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: greyColor,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _navigateToAllReviews(product),
            child: const Text(
              'See all reviews',
              style: TextStyle(
                fontSize: 14,
                color: primaryColor,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NEW: Reviews section
  Widget _buildReviewsSection(ProductEntity product) {
    return BlocProvider(
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
          )..add(LoadProductReviews(product.id)),
      child: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          if (state is ReviewLoading) {
            return _buildReviewsLoading();
          } else if (state is ProductReviewsLoaded) {
            return _buildReviewsContent(state, product);
          } else if (state is ReviewError) {
            return _buildReviewsError(state.message, product);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReviewsLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              const Spacer(),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Loading reviews...'),
        ],
      ),
    );
  }

  Widget _buildReviewsContent(
    ProductReviewsLoaded state,
    ProductEntity product,
  ) {
    if (state.reviews.isEmpty) {
      return _buildNoReviews(product);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with rating summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToAllReviews(product),
                child: Text(
                  'View All (${state.reviews.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rating overview
          Row(
            children: [
              Text(
                state.rating.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StarRating(
                    rating: state.rating.averageRating,
                    size: 20,
                    showRating: false,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on ${state.rating.totalReviews} reviews',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent reviews (show first 2-3)
          const Text(
            'Recent Reviews',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 12),

          ...state.reviews.take(2).map((review) => _buildReviewCard(review)),

          if (state.reviews.length > 2)
            Center(
              child: TextButton(
                onPressed: () => _navigateToAllReviews(product),
                child: Text(
                  'View ${state.reviews.length - 2} More Reviews',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoReviews(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToAllReviews(product),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Be the first to review this product!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsError(String message, ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              const Spacer(),
              const Icon(Icons.error_outline, color: Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load reviews: $message',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _navigateToAllReviews(product),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    StarRating(
                      rating: review.rating.toDouble(),
                      size: 14,
                      showRating: false,
                    ),
                  ],
                ),
              ),
              Text(
                _formatReviewDate(review.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 13, height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToAllReviews(ProductEntity product) {
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
              child: ProductReviewsScreen(
                productId: product.id,
                productName: product.name,
              ),
            ),
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
