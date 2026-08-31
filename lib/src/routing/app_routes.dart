enum AppRoutes {
  splash('/splash'),
  login('/login'),
  productList('/products'),
  productDetail('/products/:id');

  final String path;
  const AppRoutes(this.path);
}
