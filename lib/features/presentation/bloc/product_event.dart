abstract class ProductEvent {}

class LoadProducts extends ProductEvent {}

class SearchProducts extends ProductEvent {
  final String query;
  SearchProducts(this.query);
}

class FilterByCategory extends ProductEvent {
  final String category;
  FilterByCategory(this.category);
}
