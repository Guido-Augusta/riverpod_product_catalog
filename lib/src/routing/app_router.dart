import 'package:go_router/go_router.dart';
import 'package:product_catalog_app/src/features/product/presentation/screens/product_detail_screen.dart';
import 'package:product_catalog_app/src/features/product/presentation/screens/product_list_screen.dart';
import 'package:product_catalog_app/src/routing/app_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.productList.path,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.productList.path,
        name: AppRoutes.productList.name,
        builder: (context, state) => const ProductListScreen(),
        routes: [
          GoRoute(
            path: 'product/:id',
            name: AppRoutes.productDetail.name,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return ProductDetailScreen(productId: id);
            },
          ),
        ],
      ),
    ],
  );
}
