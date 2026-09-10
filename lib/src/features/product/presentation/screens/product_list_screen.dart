import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_catalog_app/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:product_catalog_app/src/features/product/presentation/controllers/product_list_controller.dart';
import 'package:product_catalog_app/src/features/product/presentation/controllers/product_list_state.dart';
import 'package:product_catalog_app/src/features/product/presentation/widgets/product_card.dart';
import 'package:product_catalog_app/src/routing/app_routes.dart';
import 'package:product_catalog_app/src/routing/main_nav_scaffold.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('product list screen build');
    // Dengarkan event tap ulang dari bottom navigation bar tab 0 (Products)
    ref.listen<TabReselectEvent?>(tabReselectNotifierProvider, (
      previous,
      next,
    ) {
      if (next?.tabIndex == 0) {
        _scrollToTop();
      }
    });

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final productListAsync = ref.watch(productListControllerProvider);
    final controller = ref.read(productListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
            icon: Icon(Icons.logout, color: colorScheme.errorContainer),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: _scrollToTop,
        child: const Icon(Icons.keyboard_arrow_up_rounded),
      ),
      body: productListAsync.when(
        skipLoadingOnReload: false,
        skipLoadingOnRefresh: false,
        data: (state) {
          if (state.products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                try {
                  await controller.refresh();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  final pixels = scrollInfo.metrics.pixels;
                  final maxScroll = scrollInfo.metrics.maxScrollExtent;

                  if (pixels < maxScroll - 300) {
                    controller.resetLoadMoreError();
                  }

                  if (pixels >= maxScroll - 200) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(8),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = state.products[index];
                          return ProductCard(
                            product: item,
                            onTap: () {
                              context.pushNamed(
                                AppRoutes.productDetail.name,
                                pathParameters: {'id': item.id.toString()},
                              );
                            },
                          );
                        }, childCount: state.products.length),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: switch (state.status) {
                          PaginationStatus.loadingMore => const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          PaginationStatus.errorLoadingMore => Center(
                            child: GestureDetector(
                              onTap: () => controller.retryLoadMore(),
                              child: Text(
                                state.errorMessage ??
                                    'Failed to load more data. Please try again.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                            ),
                          ),
                          PaginationStatus.reachedMax => Center(
                            child: Text(
                              'Semua produk telah ditampilkan',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ),
                          PaginationStatus.initial => const SizedBox.shrink(),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 8),
              Text(err.toString()),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(productListControllerProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
