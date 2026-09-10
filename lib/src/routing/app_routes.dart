enum AppRoutes {
  // Auth routes
  splash('/splash'),
  login('/login'),

  // Tab routes
  productList('/products'),
  productCatalog('/catalog'),
  productSearch('/search'),
  profile('/profile'),

  // Product detail
  productDetail('/products/:id');

  final String path;
  const AppRoutes(this.path);
}
