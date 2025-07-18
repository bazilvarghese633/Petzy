import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/domain/entity/product_entity.dart';
import 'package:petzy/features/presentation/bloc/product_details.dart';
import 'package:petzy/features/presentation/screens/product_details/widgets/product_details_appbar.dart';
import 'package:petzy/features/presentation/screens/product_details/widgets/product_image_carousel.dart';
import 'package:petzy/features/presentation/screens/product_details/widgets/product_stock_and_category.dart';
import 'package:petzy/features/presentation/screens/product_details/widgets/product_quantity_and_price.dart';
import 'package:petzy/features/presentation/screens/product_details/widgets/product_action_buttons.dart';

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
            ],
          );
        },
      ),
    );
  }
}
