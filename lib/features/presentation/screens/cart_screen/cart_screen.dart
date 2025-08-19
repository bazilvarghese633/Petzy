import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';
import 'package:petzy/features/presentation/screens/cart_screen/widgets/cart_content.dart';
import 'package:petzy/features/presentation/screens/cart_screen/widgets/cart_state_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey100,
      appBar: _buildAppBar(context),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading || state is CartInitial) {
            return const LoadingWidget();
          }
          if (state is CartError) {
            return CartErrorWidget(message: state.message);
          }
          if (state is CartLoaded) {
            return state.items.isEmpty
                ? const EmptyCartWidget()
                : CartContent(
                  state: state,
                ); // 👈 Removed Column wrapper and checkout button
          }
          return const UnknownErrorWidget();
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: whiteColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: secondaryColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Your Cart',
        style: TextStyle(
          color: appTitleColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }
}
