import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/domain/entity/wallet_entity.dart';
import 'package:petzy/features/domain/repository/wallet_repository.dart';

// Events
abstract class WalletEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {}

class RefreshWallet extends WalletEvent {}

// States
abstract class WalletState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletEntity wallet;

  WalletLoaded(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class WalletError extends WalletState {
  final String message;

  WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;
  final FirebaseAuth firebaseAuth;

  WalletBloc({required this.walletRepository, required this.firebaseAuth})
    : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<RefreshWallet>(_onRefreshWallet);
  }

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    await _loadWalletData(emit);
  }

  Future<void> _onRefreshWallet(
    RefreshWallet event,
    Emitter<WalletState> emit,
  ) async {
    await _loadWalletData(emit);
  }

  Future<void> _loadWalletData(Emitter<WalletState> emit) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        emit(WalletError('User not authenticated'));
        return;
      }

      final wallet = await walletRepository.getWallet(userId);
      if (wallet != null) {
        emit(WalletLoaded(wallet));
      } else {
        emit(WalletError('Wallet not found'));
      }
    } catch (e) {
      emit(WalletError('Failed to load wallet: ${e.toString()}'));
    }
  }
}
