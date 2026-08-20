import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_catalog_app/src/routing/app_routes.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Product List'),
            ElevatedButton(
              onPressed: () {
                context.goNamed(
                  AppRoutes.productDetail.name,
                  pathParameters: {'id': '1'},
                );
              },
              child: const Text('Detail'),
            ),
          ],
        ),
      ),
    );
  }
}
