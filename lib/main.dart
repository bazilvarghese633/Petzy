import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:petzy/features/core/colors.dart';
import 'package:petzy/features/data/data_source/auth_remote_datasource.dart';
import 'package:petzy/features/data/data_source/cart_remote_data_source.dart';
import 'package:petzy/features/data/data_source/profile_remote_datasource.dart';
import 'package:petzy/features/data/repository/address_repository_impl.dart';
import 'package:petzy/features/data/repository/auth_repository_impl.dart';
import 'package:petzy/features/data/repository/favorites_repository.dart';
import 'package:petzy/features/data/repository/profile_repository_impl.dart';
import 'package:petzy/features/data/repository/product_repository_impl.dart';
import 'package:petzy/features/data/repository/cart_repository_impl.dart';

import 'package:petzy/features/domain/repository/address_repository.dart';
import 'package:petzy/features/domain/repository/auth_repository.dart';
import 'package:petzy/features/domain/repository/profile_repository.dart';
import 'package:petzy/features/domain/repository/product_repository.dart';
import 'package:petzy/features/domain/repository/cart_repository.dart';
import 'package:petzy/features/domain/usecase/add_to_cart.dart';
import 'package:petzy/features/domain/usecase/get_cart_items.dart';

import 'package:petzy/features/domain/usecase/get_profile.dart';
import 'package:petzy/features/domain/usecase/update_profile.dart';
import 'package:petzy/features/domain/usecase/fetch_products_usecase.dart';
import 'package:petzy/features/domain/usecase/fetch_categories_usecase.dart';
import 'package:petzy/features/domain/usecase/update_quantity.dart';

import 'package:petzy/features/presentation/bloc/address_bloc.dart';
import 'package:petzy/features/presentation/bloc/address_event.dart';
import 'package:petzy/features/presentation/bloc/auth_bloc.dart';
import 'package:petzy/features/presentation/bloc/auth_event.dart';
import 'package:petzy/features/presentation/bloc/cart_bloc.dart';
import 'package:petzy/features/presentation/bloc/cart_event.dart';
import 'package:petzy/features/presentation/bloc/categories_bloc.dart';
import 'package:petzy/features/presentation/bloc/cubit/favorites_cubit.dart';
import 'package:petzy/features/presentation/bloc/filter_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_bloc.dart';
import 'package:petzy/features/presentation/bloc/product_event.dart';
import 'package:petzy/features/presentation/bloc/profile_bloc.dart';

import 'package:petzy/features/presentation/screens/auth_warper/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create:
              (_) =>
                  AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource()),
        ),
        RepositoryProvider<ProfileRepository>(
          create:
              (_) => ProfileRepositoryImpl(
                ProfileRemoteDataSource(
                  firestore: firestore,
                  auth: firebaseAuth,
                ),
              ),
        ),
        RepositoryProvider<ProductRepository>(
          create: (_) => ProductRepositoryImpl(firestore),
        ),
        RepositoryProvider<AddressRepository>(
          create:
              (_) => AddressRepositoryImpl(
                firestore: firestore,
                auth: firebaseAuth,
              ),
        ),
        RepositoryProvider<CartRepository>(
          create:
              (_) => CartRepositoryImpl(
                CartRemoteDataSource(firestore: firestore, auth: firebaseAuth),
              ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create:
                (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(CheckLoginEvent()),
          ),
          BlocProvider<ProfileBloc>(
            create:
                (context) => ProfileBloc(
                  getProfileUseCase: GetProfileUseCase(
                    context.read<ProfileRepository>(),
                  ),
                  updateProfileUseCase: UpdateProfileUseCase(
                    context.read<ProfileRepository>(),
                  ),
                  firebaseAuth: firebaseAuth,
                ),
          ),
          BlocProvider<ProductBloc>(
            create:
                (context) => ProductBloc(
                  FetchProductsUseCase(context.read<ProductRepository>()),
                )..add(LoadProducts()),
          ),
          BlocProvider<CategoriesBloc>(
            create:
                (context) => CategoriesBloc(
                  FetchCategoriesUseCase(context.read<ProductRepository>()),
                )..add(LoadCategories()),
          ),
          BlocProvider(
            create:
                (_) => FavoritesCubit(
                  FavoritesRepository(firestore, firebaseAuth),
                ),
          ),
          BlocProvider<AddressBloc>(
            create:
                (context) =>
                    AddressBloc(context.read<AddressRepository>())
                      ..add(LoadAddresses()),
          ),
          BlocProvider<FilterBloc>(
            create: (context) {
              final maxPrice = context.read<ProductBloc>().maxPrice.toDouble();
              return FilterBloc(absoluteMaxPrice: maxPrice);
            },
          ),
          BlocProvider<CartBloc>(
            create:
                (context) => CartBloc(
                  addToCart: AddToCartUseCase(context.read<CartRepository>()),
                  updateQuantity: UpdateCartQuantityUseCase(
                    context.read<CartRepository>(),
                  ),
                  getCartItems: GetCartItemsUseCase(
                    context.read<CartRepository>(),
                  ),
                )..add(LoadCart()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Petzy',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
            useMaterial3: true,
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
