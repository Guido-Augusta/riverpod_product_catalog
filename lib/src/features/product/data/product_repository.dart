import 'package:dio/dio.dart';
import 'package:product_catalog_app/src/core/constants/api_endpoints.dart';
import 'package:product_catalog_app/src/core/exceptions/app_exceptions.dart';
import 'package:product_catalog_app/src/core/network/dio_provider.dart';
import 'package:product_catalog_app/src/features/product/data/models/product_list_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_repository.g.dart';

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  Future<ProductList> fetchProducts({
    int limit = 30,
    int skip = 0,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.products,
        queryParameters: {'limit': limit, 'skip': skip},
        cancelToken: cancelToken,
      );
      final ProductList productList = ProductList.fromJson(response.data);
      return productList;
    } on DioException catch (e, stackTrace) {
      throw Error.throwWithStackTrace(AppException.fromDioError(e), stackTrace);
    } on TypeError catch (e, stackTrace) {
      throw Error.throwWithStackTrace(const ParsingException(), stackTrace);
    } catch (e, stackTrace) {
      throw Error.throwWithStackTrace(
        AppException.general(e.toString()),
        stackTrace,
      );
    }
  }
}

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ref.watch(dioProvider));
}
