import 'package:product_catalog_app/src/features/product/data/models/product_list_model.dart';

enum PaginationStatus { initial, loadingMore, errorLoadingMore, reachedMax }

class ProductPaginationState {
  final List<Product> products;
  final int total;
  final PaginationStatus status;
  final String? errorMessage;

  const ProductPaginationState({
    this.products = const [],
    this.total = 0,
    this.status = PaginationStatus.initial,
    this.errorMessage,
  });

  bool get hasMore => products.length < total;

  ProductPaginationState copyWith({
    List<Product>? products,
    int? total,
    PaginationStatus? status,
    String? errorMessage,
  }) {
    return ProductPaginationState(
      products: products ?? this.products,
      total: total ?? this.total,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
