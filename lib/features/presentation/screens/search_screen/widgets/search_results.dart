import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_state.dart';
import 'package:petzy/features/presentation/screens/search_screen/widgets/message_with_image.dart';
import 'package:petzy/features/presentation/screens/search_screen/widgets/product_card.dart';

class SearchResults extends StatelessWidget {
  final TextEditingController controller;

  const SearchResults({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final query = controller.text.trim();

        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductLoaded) {
          final results = state.filteredProducts;

          if (query.isEmpty) {
            return const MessageWithImage(
              imagePath:
                  'assets/images/Screenshot_2025-04-01_at_9.52.47_AM-removebg-preview.png',
              message: "Let's find something!",
              color: Colors.orange,
            );
          }

          if (results.isEmpty) {
            return const MessageWithImage(
              imagePath:
                  'assets/images/Screenshot_2025-04-01_at_9.52.56_AM-removebg-preview.png',
              message: "Nothing found!",
              color: Colors.brown,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return ProductCard(product: results[index]);
            },
          );
        }

        if (state is ProductError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox.shrink();
      },
    );
  }
}
