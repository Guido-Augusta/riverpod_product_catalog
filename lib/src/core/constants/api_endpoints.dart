class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String currentUser = '/auth/me';
  static const String refreshToken = '/auth/refresh';

  // Products
  static const String products = '/auth/products';
  static String productDetail(int id) => '/auth/products/$id';
}
