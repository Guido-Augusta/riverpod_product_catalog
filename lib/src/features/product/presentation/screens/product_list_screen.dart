import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_catalog_app/src/features/product/presentation/controllers/product_list_controller.dart';
import 'package:product_catalog_app/src/features/product/presentation/controllers/product_list_state.dart';
import 'package:product_catalog_app/src/features/product/presentation/widgets/product_card.dart';
import 'package:product_catalog_app/src/routing/app_routes.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productListAsync = ref.watch(productListControllerProvider);
    final controller = ref.read(productListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          final primaryScroll = PrimaryScrollController.of(context);
          // scroll to top
          if (primaryScroll.hasClients) {
            primaryScroll.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        },
        child: const Icon(Icons.keyboard_arrow_up_rounded),
      ),
      body: productListAsync.when(
        data: (state) {
          if (state.products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => controller.refresh(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  final pixels = scrollInfo.metrics.pixels;
                  final maxScroll = scrollInfo.metrics.maxScrollExtent;

                  if (pixels < maxScroll - 350) {
                    controller.resetErrorIfAny();
                  }

                  if (pixels >= maxScroll - 200) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: CustomScrollView(
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
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          PaginationStatus.reachedMax => const Center(
                            child: Text(
                              'Semua produk telah ditampilkan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
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
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(err.toString()),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => controller.refresh(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
