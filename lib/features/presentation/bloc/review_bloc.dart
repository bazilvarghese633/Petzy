import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/features/domain/entity/review_entity.dart';
import 'package:petzy/features/domain/entity/product_rating.dart';
import 'package:petzy/features/domain/usecase/create_review.dart';
import 'package:petzy/features/domain/usecase/get_product_reviews.dart';
import 'package:petzy/features/domain/usecase/get_product_rating.dart';
import 'package:petzy/features/domain/usecase/get_profile.dart';

// Events
abstract class ReviewEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProductReviews extends ReviewEvent {
  final String productId;
  LoadProductReviews(this.productId);
  @override
  List<Object?> get props => [productId];
}

class LoadProductRating extends ReviewEvent {
  final String productId;
  LoadProductRating(this.productId);
  @override
  List<Object?> get props => [productId];
}

class SubmitReview extends ReviewEvent {
  final String productId;
  final String orderId;
  final int rating;
  final String comment;

  SubmitReview({
    required this.productId,
    required this.orderId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [productId, orderId, rating, comment];
}

// States
abstract class ReviewState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ProductReviewsLoaded extends ReviewState {
  final List<ReviewEntity> reviews;
  final ProductRating rating;

  ProductReviewsLoaded({required this.reviews, required this.rating});
  @override
  List<Object?> get props => [reviews, rating];
}

class ReviewSubmissionLoading extends ReviewState {}

class ReviewSubmitted extends ReviewState {}

class ReviewError extends ReviewState {
  final String message;
  ReviewError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final CreateReviewUseCase createReviewUseCase;
  final GetProductReviewsUseCase getProductReviewsUseCase;
  final GetProductRatingUseCase getProductRatingUseCase;
  final GetProfileUseCase getProfileUseCase;
  final FirebaseAuth firebaseAuth;

  ReviewBloc({
    required this.createReviewUseCase,
    required this.getProductReviewsUseCase,
    required this.getProductRatingUseCase,
    required this.getProfileUseCase,
    required this.firebaseAuth,
  }) : super(ReviewInitial()) {
    on<LoadProductReviews>(_onLoadProductReviews);
    on<LoadProductRating>(_onLoadProductRating);
    on<SubmitReview>(_onSubmitReview);
  }

  Future<void> _onLoadProductReviews(
    LoadProductReviews event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final reviews = await getProductReviewsUseCase(event.productId);
      final rating = await getProductRatingUseCase(event.productId);
      emit(ProductReviewsLoaded(reviews: reviews, rating: rating));
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  Future<void> _onLoadProductRating(
    LoadProductRating event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final rating = await getProductRatingUseCase(event.productId);
      final reviews = await getProductReviewsUseCase(event.productId);
      emit(ProductReviewsLoaded(reviews: reviews, rating: rating));
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmissionLoading());
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        emit(ReviewError('User not authenticated'));
        return;
      }

      // Get user profile for name
      String userName = user.displayName ?? 'Anonymous';
      try {
        final profile = await getProfileUseCase(user.uid);
        if (profile?.name?.isNotEmpty == true) {
          userName = profile!.name!;
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }

      final review = ReviewEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: event.productId,
        userId: user.uid,
        userName: userName,
        userEmail: user.email ?? '',
        rating: event.rating,
        comment: event.comment,
        createdAt: DateTime.now(),
        orderId: event.orderId,
      );

      await createReviewUseCase(review);
      emit(ReviewSubmitted());
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }
}
