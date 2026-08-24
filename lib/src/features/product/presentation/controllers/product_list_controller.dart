import 'package:dio/dio.dart';
import 'package:product_catalog_app/src/features/product/data/models/product_list_model.dart';
import 'package:product_catalog_app/src/features/product/data/product_repository.dart';
import 'package:product_catalog_app/src/features/product/presentation/controllers/product_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_list_controller.g.dart';

@riverpod
class ProductListController extends _$ProductListController {
  static const int _limit = 30;
  CancelToken? _cancelToken;

  @override
  FutureOr<ProductPaginationState> build() async {
    ref.onDispose(() => _cancelToken?.cancel());

    final productList = await _fetchProducts(skip: 0);
    return ProductPaginationState(
      products: productList.products,
      total: productList.total,
      status: productList.products.length >= productList.total
          ? PaginationStatus.reachedMax
          : PaginationStatus.initial,
    );
  }

  Future<ProductList> _fetchProducts({required int skip}) async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    final repository = ref.read(productRepositoryProvider);
    return repository.fetchProducts(
      limit: _limit,
      skip: skip,
      cancelToken: _cancelToken,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    // Cegah trigger jika sedang loading, error, atau sudah habis
    if (currentState == null ||
        state.isLoading ||
        currentState.status == PaginationStatus.loadingMore ||
        currentState.status == PaginationStatus.reachedMax ||
        currentState.status == PaginationStatus.errorLoadingMore) {
      return;
    }
    // 1. Ubah status menjadi loadingMore
    state = AsyncValue.data(
      currentState.copyWith(status: PaginationStatus.loadingMore),
    );
    try {
      final nextData = await _fetchProducts(skip: currentState.products.length);
      final mergedProducts = [...currentState.products, ...nextData.products];
      final isMax = mergedProducts.length >= currentState.total;
      // 2. Berhasil -> Masukkan data baru dan set status
      state = AsyncValue.data(
        currentState.copyWith(
          products: mergedProducts,
          status: isMax
              ? PaginationStatus.reachedMax
              : PaginationStatus.initial,
        ),
      );
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) return;

      state = AsyncValue.data(
        currentState.copyWith(
          status: PaginationStatus.errorLoadingMore,
          errorMessage: 'Failed to load more data. Please try again.',
        ),
      );
    }
  }

  // Dipanggil saat tombol "Coba Lagi" ditekan
  Future<void> retryLoadMore() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Reset status kembali ke initial agar loadMore bisa berjalan
    state = AsyncValue.data(
      currentState.copyWith(status: PaginationStatus.initial),
    );
    await loadMore();
  }

  // Reset error jika user menjauh dari area bawah
  void resetErrorIfAny() {
    final currentState = state.value;
    if (currentState != null &&
        currentState.status == PaginationStatus.errorLoadingMore) {
      state = AsyncValue.data(
        currentState.copyWith(status: PaginationStatus.initial),
      );
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future; // Menunggu fetch build() yang baru selesai (cocok untuk RefreshIndicator)
  }
}
