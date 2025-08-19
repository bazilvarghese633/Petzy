import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzy/features/domain/entity/cart_item.dart';
import 'package:petzy/features/domain/usecase/add_to_cart.dart';
import 'package:petzy/features/domain/usecase/get_cart_items.dart';
import 'package:petzy/features/domain/usecase/update_quantity.dart';
import 'package:petzy/features/presentation/bloc/cart_event.dart';
import 'package:petzy/features/presentation/bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCartUseCase addToCart;
  final UpdateCartQuantityUseCase updateQuantity;
  final GetCartItemsUseCase getCartItems;

  StreamSubscription<List<CartItem>>? _cartSub;
  StreamSubscription<User?>? _authSub;

  CartBloc({
    required this.addToCart,
    required this.updateQuantity,
    required this.getCartItems,
  }) : super(CartInitial()) {
    // 🔥 UPDATED: Handle quantity merging for existing items
    on<AddCartItem>((event, emit) async {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;

        final cartRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('cart')
            .doc(event.item.id);

        // Check if item already exists in cart
        final docSnapshot = await cartRef.get();

        if (docSnapshot.exists) {
          // Item exists - ADD to existing quantity instead of replacing
          final existingData = docSnapshot.data()!;
          final currentQuantity = existingData['quantity'] ?? 0;
          final newQuantity =
              currentQuantity + event.item.quantity; // 🔥 Key fix!

          await cartRef.update({
            'quantity': newQuantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // New item - use existing use case
          await addToCart(event.item);
        }
      } catch (e) {
        emit(CartError('Failed to add item: $e'));
      }
    });

    on<UpdateCartItemQuantity>((event, emit) async {
      await updateQuantity(event.productId, event.quantity);
    });

    on<CartUpdated>((event, emit) {
      emit(CartLoaded(event.items));
    });

    on<LoadCart>((event, emit) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _subscribeToCart(user.uid);
      }
    });

    on<RemoveCartItem>((event, emit) async {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('cart')
              .doc(event.productId)
              .delete();
        }
      } catch (e) {
        emit(CartError('Failed to remove item: $e'));
      }
    });

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        add(LoadCart());
      } else {
        add(CartUpdated([]));
      }
    });
  }

  void _subscribeToCart(String uid) {
    _cartSub?.cancel();
    _cartSub = getCartItems().listen(
      (items) {
        if (FirebaseAuth.instance.currentUser?.uid == uid && !isClosed) {
          add(CartUpdated(items));
        }
      },
      onError: (e) {
        if (!isClosed)
          addError(CartError('Failed to load cart: $e'), StackTrace.current);
      },
    );
  }

  @override
  Future<void> close() {
    _cartSub?.cancel();
    _authSub?.cancel();
    return super.close();
  }
}
