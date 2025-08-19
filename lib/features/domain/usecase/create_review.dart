import 'package:petzy/features/domain/entity/review_entity.dart';
import 'package:petzy/features/domain/repository/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository repository;
  CreateReviewUseCase(this.repository);

  Future<String> call(ReviewEntity review) async {
    return await repository.createReview(review);
  }
}
