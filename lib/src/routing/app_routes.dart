enum AppRoutes {
  productList('/'),
  productDetail('/products/:id');

  final String path;
  const AppRoutes(this.path);
}
