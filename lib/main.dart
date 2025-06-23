import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:petzy/features/data/data_source/auth_remote_datasource.dart';
import 'package:petzy/features/data/data_source/profile_remote_datasource.dart';
import 'package:petzy/features/data/repository/auth_repository_impl.dart';
import 'package:petzy/features/data/repository/profile_repository_impl.dart';
import 'package:petzy/features/data/repository/product_repository_impl.dart';

import 'package:petzy/features/domain/repository/auth_repository.dart';
import 'package:petzy/features/domain/repository/profile_repository.dart';
import 'package:petzy/features/domain/repository/product_repository.dart';

import 'package:petzy/features/domain/usecase/get_profile.dart';
import 'package:petzy/features/domain/usecase/update_profile.dart';
import 'package:petzy/features/domain/usecase/fetch_products_usecase.dart';
import 'package:petzy/features/domain/usecase/fetch_categories_usecase.dart';

import 'package:petzy/features/presentation/bloc/auth_bloc.dart';
import 'package:petzy/features/presentation/bloc/auth_event.dart';
import 'package:petzy/features/presentation/bloc/categories_bloc.dart';
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
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Petzy',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
