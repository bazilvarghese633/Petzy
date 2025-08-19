import 'package:petzy/features/domain/entity/review_entity.dart';
import 'package:petzy/features/domain/repository/review_repository.dart';

class GetProductReviewsUseCase {
  final ReviewRepository repository;
  GetProductReviewsUseCase(this.repository);

  Future<List<ReviewEntity>> call(String productId) async {
    return await repository.getProductReviews(productId);
  }
}
