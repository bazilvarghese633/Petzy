import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/core/constants.dart';
import 'package:petzy/features/presentation/bloc/cubit/user_cubit.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_event.dart';
import 'package:petzy/features/presentation/bloc/categories_bloc.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/adbanner.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/appbar_widget.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/category_chips_row.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/custom_navbar.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/home_user_info.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/product_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _onCategorySelected(BuildContext context, String category) {
    context.read<CategoriesBloc>().add(SelectCategory(category));
    context.read<ProductBloc>().add(FilterByCategory(category));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<ProductBloc>().add(LoadProducts());
      // ignore: use_build_context_synchronously
      context.read<CategoriesBloc>().add(LoadCategories());
    });

    return MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>(create: (_) => UserCubit()..fetchUser()),
      ],
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: HomeAppBar(user: user, auth: FirebaseAuth.instance),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (user != null) const HomeUserInfo(),
              const AdBanner(),
              sizedBoxH12,
              CategoryChipsRow(
                onCategorySelected:
                    (category) => _onCategorySelected(context, category),
              ),
              sizedBoxH12,
              const ProductGrid(),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 0,
          onTap: (index) {},
        ),
      ),
    );
  }
}
