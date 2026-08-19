class ApiEndpoints {
  ApiEndpoints._();

  static const String products = '/products';
  static String productDetail(int id) => '/products/$id';
}
