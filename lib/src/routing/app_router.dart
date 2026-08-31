import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:product_catalog_app/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:product_catalog_app/src/features/auth/presentation/controllers/auth_state.dart';
import 'package:product_catalog_app/src/features/auth/presentation/screens/login_screen.dart';
import 'package:product_catalog_app/src/features/auth/presentation/screens/splash_screen.dart';
import 'package:product_catalog_app/src/features/product/presentation/screens/product_detail_screen.dart';
import 'package:product_catalog_app/src/features/product/presentation/screens/product_list_screen.dart';
import 'package:product_catalog_app/src/routing/app_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@riverpod
GoRouter goRouter(Ref ref) {
  final authNotifier = ValueNotifier<AuthState>(
    ref.read(authControllerProvider),
  );

  ref.listen(authControllerProvider, (_, next) {
    authNotifier.value = next;
  });

  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.productList.path,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.value;

      // State evaluasi
      final isInitializing = authState is AuthInitial;
      final isAuthenticated = authState is Authenticated;

      final currentPath = state.matchedLocation;
      final isGoingToSplash = currentPath == AppRoutes.splash.path;
      final isGoingToLogin = currentPath == AppRoutes.login.path;
      // KASUS 1: Aplikasi baru buka / sedang cek token
      if (isInitializing) {
        return isGoingToSplash ? null : AppRoutes.splash.path;
      }
      // KASUS 2: User BELUM LOGIN (Unauthenticated)
      if (!isAuthenticated) {
        // Jika sedang menuju login (atau halaman public lainnya), izinkan
        if (isGoingToLogin) return null;

        // Simpan target lokasi awal di query param agar setelah login bisa kembali ke sana
        final fromPath = currentPath == AppRoutes.splash.path
            ? null
            : currentPath;
        return fromPath != null
            ? '${AppRoutes.login.path}?from=${Uri.encodeComponent(fromPath)}'
            : AppRoutes.login.path;
      }
      // KASUS 3: User SUDAH LOGIN (Authenticated)
      // Jika user masih di splash screen atau di login screen, arahkan ke target/home
      if (isGoingToSplash || isGoingToLogin) {
        final from = state.uri.queryParameters['from'];
        if (from != null && from.isNotEmpty) {
          return Uri.decodeComponent(from);
        }
        return AppRoutes.productList.path;
      }
      // KASUS 4: Izinkan navigasi normal
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('404 - Halaman Tidak Ditemukan: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.productList.path),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash.path,
        name: AppRoutes.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.productList.path,
        name: AppRoutes.productList.name,
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: AppRoutes.productDetail.path,
        name: AppRoutes.productDetail.name,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ProductDetailScreen(productId: id);
        },
      ),
    ],
  );
}
